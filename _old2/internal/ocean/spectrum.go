package ocean

import (
	"fmt"
	"math"
	"math/rand"
	"os"
)

const (
	Gravity              = 9.81
	spectrumSampleStride = 8
	cascadeCount         = 4
	spectrumDebugLog     = false
)

type CascadeRuntime struct {
	DomainSize   float32
	HeightWeight float32
	SlopeWeight  float32
	ChopWeight   float32
}

type cascadeSpectrumConfig struct {
	DomainSize     float64
	PeakWavelength float64
	MinWavelength  float64
	MaxWavelength  float64
	Alpha          float64
	Gamma          float64
	SpreadPower    float64
	Amplitude      float64
	CrossWeight    float64
	BackWeight     float64
	Floor          float64
	HeightWeight   float64
	SlopeWeight    float64
	ChopWeight     float64
	SeedOffset     int64
}

type cascadeSpectrumStats struct {
	totalEnergy float64
	rmsEstimate float64
	minP        float64
	maxP        float64
}

// DeepWaterOmega calculates the angular frequency of a deep water wave given its wavenumber k.
func DeepWaterOmega(k float64) (o float64) {
	if k <= 0 {
		return
	}
	return math.Sqrt(Gravity * k)
}

func deepWaterDOmegaDk(k float64) float64 {
	if k <= 1e-6 {
		k = 1e-6
	}
	return 0.5 * math.Sqrt(Gravity/k)
}

// JONSWAP computes a one-dimensional JONSWAP spectrum value.
func JONSWAP(omega, alpha, gamma, peakOmega float64) (val float64) {
	if omega <= 0 || peakOmega <= 0 {
		return
	}

	sigma := 0.09
	if omega <= peakOmega {
		sigma = 0.07
	}

	r := math.Exp(-math.Pow(omega-peakOmega, 2) / (2 * sigma * sigma * peakOmega * peakOmega))
	return alpha * Gravity * Gravity * math.Pow(omega, -5) * math.Exp(-1.25*math.Pow(peakOmega/omega, 4)) * math.Pow(gamma, r)
}

// Phillips computes the Phillips spectrum value for a given wavenumber.
//
// Kept only as a legacy helper for older callers. The renderer now uses
// cascade-aware directional JONSWAP spectra.
func Phillips(kx, kz, windX, windZ, windSpeed, amplitude float64) (val float64) {
	return PhillipsWithDamping(kx, kz, windX, windZ, windSpeed, amplitude, 0.0015)
}

// PhillipsWithDamping is retained as a legacy helper.
func PhillipsWithDamping(kx, kz, windX, windZ, windSpeed, amplitude, shortWaveDamping float64) (val float64) {
	k2 := kx*kx + kz*kz
	if k2 < 1e-8 {
		return
	}

	k := math.Sqrt(k2)
	khatX, khatZ := kx/k, kz/k
	windX, windZ = normalize2(windX, windZ)

	kw := khatX*windX + khatZ*windZ
	L := windSpeed * windSpeed / Gravity
	if L <= 1e-5 {
		return
	}

	damping := math.Exp(-k2 * shortWaveDamping * shortWaveDamping)
	directional := 0.42 + 0.58*math.Pow(math.Abs(kw), 1.35)
	if kw < 0 {
		directional *= 0.62
	}

	longWaveCutoff := 2 * math.Pi / 95.0
	longWaveSuppress := 1.0 - math.Exp(-math.Pow(k/longWaveCutoff, 4.0))

	val = amplitude * math.Exp(-1.0/(k2*L*L)) / (k2 * k2) * directional * damping * longWaveSuppress
	return
}

// GenerateInitialSpectrum returns the first cascade spectrum for compatibility.
func GenerateInitialSpectrum(n int, sizeMeters, windSpeed, amplitude float64, seed int64) (samples []float32) {
	samples, _ = GenerateInitialSpectrumSet(n, SpectrumConfig{
		WindSpeed:        windSpeed,
		WindDirectionX:   0.92,
		WindDirectionZ:   0.38,
		Amplitude:        amplitude,
		ShortWaveDamping: 0.0013,
		Seed:             seed,
	})
	return
}

// GenerateInitialSpectrumWithConfig returns the first cascade spectrum for compatibility.
func GenerateInitialSpectrumWithConfig(n int, cfg SpectrumConfig) (samples []float32) {
	samples, _ = GenerateInitialSpectrumSet(n, cfg)
	return
}

// GenerateInitialSpectrumSet builds four independent FFT cascades rather than
// packing all bands into one domain. This mirrors the layered FFT approach used
// by common Tessendorf/JONSWAP ocean demos: long swell, main wind sea, chop, and
// capillary detail each get their own domain and directional spread.
func GenerateInitialSpectrumSet(n int, cfg SpectrumConfig) (samples []float32, runtimes []CascadeRuntime) {
	if cfg.WindSpeed <= 0 {
		cfg.WindSpeed = 7.4
	}
	if cfg.Amplitude < 0 {
		cfg.Amplitude = 0
	}
	if cfg.ShortWaveDamping <= 0 {
		cfg.ShortWaveDamping = 0.0013
	}

	cascades := defaultCascadeSpectrumConfigs(cfg)
	windX, windZ := normalize2(cfg.WindDirectionX, cfg.WindDirectionZ)
	samples = make([]float32, cascadeCount*n*n*spectrumSampleStride)
	runtimes = make([]CascadeRuntime, 0, cascadeCount)
	stats := make([]cascadeSpectrumStats, 0, cascadeCount)

	for cascadeIndex, cascade := range cascades {
		rng := rand.New(rand.NewSource(cfg.Seed + cascade.SeedOffset))
		h0 := make([]complex128, n*n)
		stat := cascadeSpectrumStats{minP: math.MaxFloat64}

		for z := range n {
			for x := range n {
				kx := 2 * math.Pi * float64(waveNumber(x, n)) / cascade.DomainSize
				kz := 2 * math.Pi * float64(waveNumber(z, n)) / cascade.DomainSize
				p := cascadeDirectionalSpectrum(kx, kz, windX, windZ, cascade, cfg.ShortWaveDamping)
				if p > 0 {
					stat.totalEnergy += p
					if p < stat.minP {
						stat.minP = p
					}
					if p > stat.maxP {
						stat.maxP = p
					}
				}
				h0[z*n+x] = h0FromSpectrum(rng, p)
			}
		}

		if stat.minP == math.MaxFloat64 {
			stat.minP = 0
		}
		stat.rmsEstimate = math.Sqrt(stat.totalEnergy) / float64(n)

		base := cascadeIndex * n * n * spectrumSampleStride
		for z := range n {
			for x := range n {
				i := z*n + x
				out := base + i*spectrumSampleStride
				kx := 2 * math.Pi * float64(waveNumber(x, n)) / cascade.DomainSize
				kz := 2 * math.Pi * float64(waveNumber(z, n)) / cascade.DomainSize
				kLen := math.Sqrt(kx*kx + kz*kz)
				neg := cmplxConj(h0[negativeWaveIndex(x, z, n)])

				samples[out+0] = float32(real(h0[i]))
				samples[out+1] = float32(imag(h0[i]))
				samples[out+2] = float32(real(neg))
				samples[out+3] = float32(imag(neg))
				samples[out+4] = float32(kx)
				samples[out+5] = float32(kz)
				samples[out+6] = float32(kLen)
				samples[out+7] = float32(DeepWaterOmega(kLen))
			}
		}

		runtimes = append(runtimes, CascadeRuntime{
			DomainSize:   float32(cascade.DomainSize),
			HeightWeight: float32(cascade.HeightWeight),
			SlopeWeight:  float32(cascade.SlopeWeight),
			ChopWeight:   float32(cascade.ChopWeight),
		})
		stats = append(stats, stat)
	}

	if spectrumDebugEnabled() {
		for i, cascade := range cascades {
			stat := stats[i]
			fmt.Printf(
				"ocean spectrum cascade=%d domain=%.1fm peakLambda=%.1fm energy=%.6e rms~=%.6f minP=%.6e maxP=%.6e\n",
				i,
				cascade.DomainSize,
				cascade.PeakWavelength,
				stat.totalEnergy,
				stat.rmsEstimate,
				stat.minP,
				stat.maxP,
			)
		}
	}

	return
}

func defaultCascadeSpectrumConfigs(cfg SpectrumConfig) []cascadeSpectrumConfig {
	base := cfg.Amplitude
	if base <= 0 {
		base = 4.6e-5
	}

	return []cascadeSpectrumConfig{
		{
			// Long support only. Keep this visible in the horizon silhouette, but do not
			// let it create the terrain-like rolling hills seen in the latest clip.
			DomainSize:     5200.0,
			PeakWavelength: 78.0,
			MinWavelength:  42.0,
			MaxWavelength:  220.0,
			Alpha:          0.0043,
			Gamma:          1.24,
			SpreadPower:    2.25,
			Amplitude:      base * 0.11,
			CrossWeight:    0.28,
			BackWeight:     0.12,
			Floor:          0.030,
			HeightWeight:   0.26,
			SlopeWeight:    0.36,
			ChopWeight:     0.06,
			SeedOffset:     17,
		},
		{
			// Main wind sea. Shorter peak wavelength and lower height weight make the
			// surface common/choppy instead of sparse and mountainous.
			DomainSize:     2048.0,
			PeakWavelength: 11.8,
			MinWavelength:  5.2,
			MaxWavelength:  44.0,
			Alpha:          0.0360,
			Gamma:          1.82,
			SpreadPower:    0.96,
			Amplitude:      base * 2.05,
			CrossWeight:    0.70,
			BackWeight:     0.42,
			Floor:          0.080,
			HeightWeight:   0.92,
			SlopeWeight:    2.70,
			ChopWeight:     0.90,
			SeedOffset:     53,
		},
		{
			// Short chop. This is mostly slope/normal energy: frequent 3-10m structure
			// with modest height, matching WoWS' busy surface without tall crests.
			DomainSize:     512.0,
			PeakWavelength: 3.2,
			MinWavelength:  1.5,
			MaxWavelength:  13.0,
			Alpha:          0.0820,
			Gamma:          1.22,
			SpreadPower:    0.24,
			Amplitude:      base * 5.65,
			CrossWeight:    0.86,
			BackWeight:     0.55,
			Floor:          0.105,
			HeightWeight:   0.30,
			SlopeWeight:    4.35,
			ChopWeight:     0.56,
			SeedOffset:     97,
		},
		{
			// Capillary/slope domain. No displacement; high slope energy only, so it
			// feeds render facets/sub-pixel detail instead of visible geometry.
			DomainSize:     192.0,
			PeakWavelength: 1.10,
			MinWavelength:  0.72,
			MaxWavelength:  3.4,
			Alpha:          0.0880,
			Gamma:          1.04,
			SpreadPower:    0.12,
			Amplitude:      base * 7.80,
			CrossWeight:    0.92,
			BackWeight:     0.64,
			Floor:          0.130,
			HeightWeight:   0.0,
			SlopeWeight:    4.80,
			ChopWeight:     0.0,
			SeedOffset:     131,
		},
	}
}

func cascadeDirectionalSpectrum(kx, kz, windX, windZ float64, cascade cascadeSpectrumConfig, shortWaveDamping float64) float64 {
	k2 := kx*kx + kz*kz
	if k2 <= 1e-8 {
		return 0
	}

	k := math.Sqrt(k2)
	omega := DeepWaterOmega(k)
	khatX := kx / k
	khatZ := kz / k
	crossX := -windZ
	crossZ := windX

	peakOmega := DeepWaterOmega(2 * math.Pi / cascade.PeakWavelength)
	base := JONSWAP(omega, cascade.Alpha, cascade.Gamma, peakOmega)
	if base <= 0 {
		return 0
	}

	dirDot := khatX*windX + khatZ*windZ
	crossDot := khatX*crossX + khatZ*crossZ
	diagAX, diagAZ := normalize2(windX*0.44+crossX*0.90, windZ*0.44+crossZ*0.90)
	diagBX, diagBZ := normalize2(windX*0.28-crossX*0.96, windZ*0.28-crossZ*0.96)
	diagA := khatX*diagAX + khatZ*diagAZ
	diagB := khatX*diagBX + khatZ*diagBZ

	// 6: confused but not smeared. Crossing/diagonal lobes add chaos; sharper
	// exponents keep visible facet lanes instead of omnidirectional mush.
	main := math.Pow(math.Max(dirDot, 0.0), cascade.SpreadPower)
	cross := cascade.CrossWeight * math.Pow(math.Abs(crossDot), 1.36)
	back := cascade.BackWeight * math.Pow(math.Max(-dirDot, 0.0), 1.78)
	diagonal := 0.26 * (math.Pow(math.Max(diagA, 0.0), 1.36) + math.Pow(math.Max(diagB, 0.0), 1.30))
	directional := (main + cross + back + diagonal + cascade.Floor) / (1.52 + cascade.CrossWeight + cascade.BackWeight + cascade.Floor)

	bandMask := bandWindow(k, cascade.MinWavelength, cascade.MaxWavelength)
	shortSuppress := math.Exp(-k2 * shortWaveDamping * shortWaveDamping)
	// Only remove near-DC water-level drift. The previous cutoff removed too much
	// usable low/mid energy, leaving the rendered ocean almost flat.
	longSuppress := 1.0 - math.Exp(-math.Pow(k/(2.0*math.Pi/900.0), 3.2))

	p := base * directional * bandMask * deepWaterDOmegaDk(k) / math.Max(k, 1e-6)
	p *= cascade.Amplitude * shortSuppress * longSuppress
	if p < 0 {
		return 0
	}
	return p
}

func bandWindow(k, minWavelength, maxWavelength float64) float64 {
	if k <= 1e-8 {
		return 0
	}

	kMin := 2.0 * math.Pi / maxWavelength
	kMax := 2.0 * math.Pi / minWavelength
	highPass := 1.0 - math.Exp(-math.Pow(k/kMin, 4.0))
	lowPass := math.Exp(-math.Pow(k/kMax, 4.0))
	return highPass * lowPass
}

func spectrumDebugEnabled() bool {
	return spectrumDebugLog || os.Getenv("FFT_OCEAN_SPECTRUM_DEBUG") == "1"
}

func gaussian(rng *rand.Rand) (gauss float64) {
	return math.Sqrt(-2*math.Log(math.Max(rng.Float64(), 1e-12))) * math.Cos(2*math.Pi*rng.Float64())
}

func h0FromSpectrum(rng *rand.Rand, p float64) (h0 complex128) {
	if p <= 0 {
		return 0
	}
	scale := math.Sqrt(p) / math.Sqrt2
	return complex(gaussian(rng)*scale, gaussian(rng)*scale)
}

func negativeWaveIndex(x, z, n int) int {
	return ((n-z)%n)*n + ((n - x) % n)
}

func waveNumber(i, n int) int {
	if i < n/2 {
		return i
	}
	return i - n
}

func normalize2(x, z float64) (nx, nz float64) {
	length := math.Sqrt(x*x + z*z)
	if length <= 1e-8 {
		return 1, 0
	}
	return x / length, z / length
}

func cmplxConj(v complex128) complex128 {
	return complex(real(v), -imag(v))
}
