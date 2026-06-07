package ocean

import "math"

type OceanTuning struct {
	// Runtime-safe. These are packed into the frame uniform buffer every draw.
	HeightScale       float32
	ChopScale         float32
	TimeScale         float32
	NormalDetailScale float32
	FoamAmount        float32
	FoamThreshold     float32
	ReflectionAmount  float32
	Roughness         float32

	// Spectrum-level. Changing these rebuilds h0 and uploads the spectrum buffer.
	WindSpeed        float32
	WindDirectionX   float32
	WindDirectionZ   float32
	SpectrumScale    float32
	ShortWaveDamping float32
}

type OceanPreset int

const (
	PresetCalm OceanPreset = iota
	PresetWoWS
	PresetRough
)

type SpectrumConfig struct {
	WindSpeed        float64
	WindDirectionX   float64
	WindDirectionZ   float64
	Amplitude        float64
	ShortWaveDamping float64
	Seed             int64
}

type spectrumKey struct {
	windSpeed        float32
	windDirectionX   float32
	windDirectionZ   float32
	spectrumScale    float32
	shortWaveDamping float32
}

func DefaultOceanTuning() OceanTuning {
	return WoWSTuning()
}

func CalmTuning() OceanTuning {
	return OceanTuning{
		HeightScale:       0.82,
		ChopScale:         0.52,
		TimeScale:         0.46,
		NormalDetailScale: 1.20,
		FoamAmount:        0.16,
		FoamThreshold:     0.62,
		ReflectionAmount:  0.26,
		Roughness:         0.46,

		WindSpeed:        5.8,
		WindDirectionX:   0.92,
		WindDirectionZ:   0.38,
		SpectrumScale:    0.78,
		ShortWaveDamping: 0.0017,
	}
}

func WoWSTuning() OceanTuning {
	return OceanTuning{
		// WoWS-style baseline: restrained vertical relief, dense normal/slope detail.
		// The water should read as many small reflected facets, not tall rolling hills.
		HeightScale:       1.32,
		ChopScale:         1.30,
		TimeScale:         1.38,
		NormalDetailScale: 3.15,
		FoamAmount:        0.022,
		FoamThreshold:     0.76,
		ReflectionAmount:  0.64,
		Roughness:         0.58,

		WindSpeed:        10.8,
		WindDirectionX:   0.89,
		WindDirectionZ:   0.46,
		SpectrumScale:    0.96,
		ShortWaveDamping: 0.00016,
	}
}

func RoughTuning() OceanTuning {
	return OceanTuning{
		HeightScale:       1.34,
		ChopScale:         1.36,
		TimeScale:         0.70,
		NormalDetailScale: 2.85,
		FoamAmount:        0.40,
		FoamThreshold:     0.22,
		ReflectionAmount:  0.28,
		Roughness:         0.58,

		WindSpeed:        10.8,
		WindDirectionX:   0.89,
		WindDirectionZ:   0.46,
		SpectrumScale:    1.12,
		ShortWaveDamping: 0.00022,
	}
}

func OceanTuningPreset(preset OceanPreset) OceanTuning {
	switch preset {
	case PresetCalm:
		return CalmTuning()
	case PresetRough:
		return RoughTuning()
	default:
		return WoWSTuning()
	}
}

func (t OceanTuning) Clamped() OceanTuning {
	t.HeightScale = clamp32(t.HeightScale, 0.0, 3.0)
	t.ChopScale = clamp32(t.ChopScale, 0.0, 3.0)
	t.TimeScale = clamp32(t.TimeScale, 0.0, 2.0)
	t.NormalDetailScale = clamp32(t.NormalDetailScale, 0.0, 4.0)
	t.FoamAmount = clamp32(t.FoamAmount, 0.0, 2.0)
	t.FoamThreshold = clamp32(t.FoamThreshold, -0.35, 1.25)
	t.ReflectionAmount = clamp32(t.ReflectionAmount, 0.0, 1.2)
	t.Roughness = clamp32(t.Roughness, 0.12, 0.96)

	t.WindSpeed = clamp32(t.WindSpeed, 0.1, 60.0)
	t.SpectrumScale = clamp32(t.SpectrumScale, 0.0, 5.0)
	t.ShortWaveDamping = clamp32(t.ShortWaveDamping, 0.0001, 0.0500)

	var x, z = normalize2f(t.WindDirectionX, t.WindDirectionZ)
	t.WindDirectionX = x
	t.WindDirectionZ = z

	return t
}

func (t OceanTuning) SpectrumConfig(seed int64) SpectrumConfig {
	t = t.Clamped()
	return SpectrumConfig{
		WindSpeed:        float64(t.WindSpeed),
		WindDirectionX:   float64(t.WindDirectionX),
		WindDirectionZ:   float64(t.WindDirectionZ),
		Amplitude:        float64(5.35e-3 * t.SpectrumScale),
		ShortWaveDamping: float64(t.ShortWaveDamping),
		Seed:             seed,
	}
}

func (t OceanTuning) spectrumKey() spectrumKey {
	t = t.Clamped()
	return spectrumKey{
		windSpeed:        t.WindSpeed,
		windDirectionX:   t.WindDirectionX,
		windDirectionZ:   t.WindDirectionZ,
		spectrumScale:    t.SpectrumScale,
		shortWaveDamping: t.ShortWaveDamping,
	}
}

func clamp32(v, lo, hi float32) float32 {
	if v < lo {
		return lo
	}
	if v > hi {
		return hi
	}
	return v
}

func normalize2f(x, z float32) (float32, float32) {
	l := float32(math.Sqrt(float64(x*x + z*z)))
	if l <= 1e-6 {
		return 1, 0
	}
	return x / l, z / l
}
