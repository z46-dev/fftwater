package ocean

import (
	"fmt"
	"math"
	"math/cmplx"
	"math/rand"
	"sync"
	"unsafe"

	rl "github.com/gen2brain/raylib-go/raylib"
)

// makeCascade creates a wave cascade based on the provided configuration and defaults.
func makeCascade(cfg CascadeConfig, defaults Config, index int) (cascade waveCascade, err error) {
	if cfg.N == 0 {
		cfg.N = defaults.N
	}

	if cfg.N == 0 {
		cfg.N = 128
	}

	if !isPowerOfTwo(cfg.N) {
		err = fmt.Errorf("cascade %d FFT grid N must be a power of two, got %d", index, cfg.N)
		return
	}

	if cfg.SizeMeters <= 0 {
		cfg.SizeMeters = defaults.SizeMeters
	}

	if cfg.SizeMeters <= 0 {
		cfg.SizeMeters = 260
	}

	if cfg.WindDirection.X == 0 && cfg.WindDirection.Y == 0 {
		cfg.WindDirection = defaults.WindDirection
	}

	if cfg.WindDirection.X == 0 && cfg.WindDirection.Y == 0 {
		cfg.WindDirection = rl.NewVector2(1, 0)
	}

	if cfg.WindSpeed <= 0 {
		cfg.WindSpeed = defaults.WindSpeed
	}

	if cfg.WindSpeed <= 0 {
		cfg.WindSpeed = 10
	}

	if cfg.Amplitude <= 0 {
		cfg.Amplitude = defaults.Amplitude
	}

	if cfg.Amplitude <= 0 {
		cfg.Amplitude = 0.00022
	}

	if cfg.Choppiness < 0 {
		cfg.Choppiness = 0
	}

	if cfg.Seed == 0 {
		cfg.Seed = defaults.Seed + int64(index)
	}

	cascade = waveCascade{cfg: cfg}
	cascade.allocate()
	cascade.precomputeWaveData()
	cascade.generateInitialSpectrum()
	return
}

// allocate initializes all the necessary slices for the wave cascade based on the configuration.
func (c *waveCascade) allocate() {
	var nn int = c.cfg.N * c.cfg.N
	c.h0 = make([]complex128, nn)
	c.h0ConjMinus = make([]complex128, nn)
	c.heightSpec = make([]complex128, nn)
	c.slopeXSpec = make([]complex128, nn)
	c.slopeZSpec = make([]complex128, nn)
	c.dispXSpec = make([]complex128, nn)
	c.dispZSpec = make([]complex128, nn)
	c.height = make([]float64, nn)
	c.slopeX = make([]float64, nn)
	c.slopeZ = make([]float64, nn)
	c.dispX = make([]float64, nn)
	c.dispZ = make([]float64, nn)
	c.heightDispMap = make([]float32, nn*4)
	c.slopeFoldMap = make([]float32, nn*4)
	c.jacobian = make([]float64, nn)
	c.folding = make([]float64, nn)
	c.kx = make([]float64, nn)
	c.kz = make([]float64, nn)
	c.kLen = make([]float64, nn)
	c.omega = make([]float64, nn)
}

// precomputeWaveData calculates the wave vector components, their magnitudes, and angular frequencies for each point in the FFT grid.
func (c *waveCascade) precomputeWaveData() {
	var (
		n    int     = c.cfg.N
		size float64 = float64(c.cfg.SizeMeters)
	)

	for z := range n {
		var nz int = z
		if nz >= n/2 {
			nz -= n
		}

		var kz float64 = 2 * math.Pi * float64(nz) / size
		for x := range n {
			var nx int = x
			if nx >= n/2 {
				nx -= n
			}

			var (
				kx  float64 = 2 * math.Pi * float64(nx) / size
				idx int     = z*n + x
			)

			c.kx[idx] = kx
			c.kz[idx] = kz
			c.kLen[idx] = math.Sqrt(kx*kx + kz*kz)
			c.omega[idx] = omega(c.kLen[idx])
		}
	}
}

// generateInitialSpectrum creates the initial wave spectrum based on the Phillips spectrum and random phases,
// storing both the initial values and their conjugates for later use in time evolution.
func (c *waveCascade) generateInitialSpectrum() {
	var (
		rng  *rand.Rand = rand.New(rand.NewSource(c.cfg.Seed))
		wind rl.Vector2 = c.cfg.WindDirection.Normalize()
		n    int        = c.cfg.N
	)

	for z := range n {
		for x := range n {
			var idx int = z*n + x
			c.h0[idx] = h0FromSpectrum(rng, phillipsSpectrum(c.kx[idx], c.kz[idx], float64(wind.X), float64(wind.Y), c.cfg.WindSpeed, c.cfg.Amplitude))
		}
	}

	for z := range n {
		for x := range n {
			c.h0ConjMinus[z*n+x] = cmplx.Conj(c.h0[negativeWaveIndex(x, z, n)])
		}
	}
}

// evaluate updates the wave spectrum and spatial fields based on the current time, ensuring that redundant calculations are avoided if the time hasn't changed since the last update.
func (c *waveCascade) evaluate(t float32) {
	if c.hasUpdateTime && t == c.lastUpdateTime {
		return
	}

	c.evaluateSpectrum(float64(t))
	c.lastUpdateTime = t
	c.hasUpdateTime = true
}

// evaluateSpectrum computes the wave spectrum at a given time, performs inverse FFTs to obtain spatial fields, and then packs the results into textures for rendering.
func (c *waveCascade) evaluateSpectrum(t float64) {
	var n int = c.cfg.N

	for z := range n {
		for x := range n {
			var idx int = z*n + x
			c.heightSpec[idx], c.slopeXSpec[idx], c.slopeZSpec[idx], c.dispXSpec[idx], c.dispZSpec[idx] = spectralFields(c.h0[idx]*expI(c.omega[idx]*t)+c.h0ConjMinus[idx]*expI(-c.omega[idx]*t), c.kx[idx], c.kz[idx], c.kLen[idx], c.cfg.Choppiness)
		}
	}

	var wg sync.WaitGroup

	wg.Go(func() { fft2D(c.heightSpec, n, true) })
	wg.Go(func() { fft2D(c.slopeXSpec, n, true) })
	wg.Go(func() { fft2D(c.slopeZSpec, n, true) })
	wg.Go(func() { fft2D(c.dispXSpec, n, true) })
	wg.Go(func() { fft2D(c.dispZSpec, n, true) })

	wg.Wait()

	for i := range n * n {
		c.height[i] = real(c.heightSpec[i])
		c.slopeX[i] = real(c.slopeXSpec[i])
		c.slopeZ[i] = real(c.slopeZSpec[i])
		c.dispX[i] = real(c.dispXSpec[i])
		c.dispZ[i] = real(c.dispZSpec[i])
	}

	c.packMaps()
}

// sample retrieves the height, slopes, and displacements at a specific world position by performing bilinear interpolation on the precomputed spatial fields.
func (c *waveCascade) sample(baseX, baseZ float32) (height, slopeX, slopeZ, dispX, dispZ float64) {
	var (
		n                  int     = c.cfg.N
		size               float64 = float64(c.cfg.SizeMeters)
		u, v               float64 = wrap01(float64(baseX)/size + 0.5), wrap01(float64(baseZ)/size + 0.5)
		x, z               float64 = u * float64(n), v * float64(n)
		x0, z0             int     = int(math.Floor(x)) % n, int(math.Floor(z)) % n
		tx, tz             float64 = x - math.Floor(x), z - math.Floor(z)
		x1, z1             int     = (x0 + 1) % n, (z0 + 1) % n
		i00, i10, i01, i11 int     = z0*n + x0, z0*n + x1, z1*n + x0, z1*n + x1
	)

	height = bilerp(c.height[i00], c.height[i10], c.height[i01], c.height[i11], tx, tz)
	slopeX = bilerp(c.slopeX[i00], c.slopeX[i10], c.slopeX[i01], c.slopeX[i11], tx, tz)
	slopeZ = bilerp(c.slopeZ[i00], c.slopeZ[i10], c.slopeZ[i01], c.slopeZ[i11], tx, tz)
	dispX = bilerp(c.dispX[i00], c.dispX[i10], c.dispX[i01], c.dispX[i11], tx, tz)
	dispZ = bilerp(c.dispZ[i00], c.dispZ[i10], c.dispZ[i01], c.dispZ[i11], tx, tz)
	return
}

// packMaps combines the height, slope, and displacement data into packed float32 arrays suitable for uploading to GPU textures,
// while also calculating the Jacobian and folding factors for wave rendering.
func (c *waveCascade) packMaps() {
	var (
		n       int     = c.cfg.N
		spacing float64 = float64(c.cfg.SizeMeters) / float64(n)
	)

	for z := range n {
		for x := range n {
			var (
				idx                        int     = z*n + x
				left, right, down, up      int     = z*n + ((x - 1 + n) % n), z*n + ((x + 1) % n), ((z - 1 + n) % n * n) + x, ((z + 1) % n * n) + x
				ddxDx, ddzDx, ddxDz, ddzDz float64 = (c.dispX[right] - c.dispX[left]) / (2 * spacing), (c.dispZ[right] - c.dispZ[left]) / (2 * spacing), (c.dispX[up] - c.dispX[down]) / (2 * spacing), (c.dispZ[up] - c.dispZ[down]) / (2 * spacing)
				j                          float64 = (1+ddxDx)*(1+ddzDz) - ddzDx*ddxDz
				fold                       float64 = math.Max(0, 1-j)
				packed                     int     = idx * 4
			)

			c.jacobian[idx] = j
			c.folding[idx] = fold

			c.heightDispMap[packed+0] = float32(c.height[idx])
			c.heightDispMap[packed+1] = float32(c.dispX[idx])
			c.heightDispMap[packed+2] = float32(c.dispZ[idx])
			c.heightDispMap[packed+3] = float32(j)

			c.slopeFoldMap[packed+0] = float32(c.slopeX[idx])
			c.slopeFoldMap[packed+1] = float32(c.slopeZ[idx])
			c.slopeFoldMap[packed+2] = float32(fold)
			c.slopeFoldMap[packed+3] = 0
		}
	}
}

// heightDisplacementMap returns the packed height and displacement map for the wave cascade, which can be used for rendering.
func (c *waveCascade) heightDisplacementMap() []float32 {
	return c.heightDispMap
}

// slopeFoldingMap returns the packed slope and folding map for the wave cascade, which can be used for rendering.
func (c *waveCascade) slopeFoldingMap() []float32 {
	return c.slopeFoldMap
}

// loadPackedTextures creates GPU textures for the height/displacement and slope/folding maps, allowing them to be used in shaders for rendering the ocean surface.
func (c *waveCascade) loadPackedTextures() {
	c.heightDispTexture = newFloatMapTexture(c.cfg.N)
	c.slopeFoldTexture = newFloatMapTexture(c.cfg.N)
}

// unloadPackedTextures releases the GPU textures used for the height/displacement and slope/folding maps, freeing up resources when they are no longer needed.
func (c *waveCascade) unloadPackedTextures() {
	if c.heightDispTexture.ID != 0 {
		rl.UnloadTexture(c.heightDispTexture)
		c.heightDispTexture = rl.Texture2D{}
	}

	if c.slopeFoldTexture.ID != 0 {
		rl.UnloadTexture(c.slopeFoldTexture)
		c.slopeFoldTexture = rl.Texture2D{}
	}
}

// uploadPackedTextures updates the GPU textures with the latest height/displacement and slope/folding data, ensuring that the rendered ocean surface reflects the current state of the wave cascade.
func (c *waveCascade) uploadPackedTextures() {
	if c.heightDispTexture.ID != 0 {
		rl.UpdateTexture(c.heightDispTexture, float32Bytes(c.heightDispMap))
	}

	if c.slopeFoldTexture.ID != 0 {
		rl.UpdateTexture(c.slopeFoldTexture, float32Bytes(c.slopeFoldMap))
	}
}

// newFloatMapTexture creates a new GPU texture suitable for storing float data, initializing it with the appropriate format and settings for use in rendering the ocean surface.
func newFloatMapTexture(n int) (texture rl.Texture2D) {
	var image *rl.Image = rl.GenImageColor(n, n, rl.Blank)
	rl.ImageFormat(image, rl.UncompressedR32g32b32a32)

	texture = rl.LoadTextureFromImage(image)
	rl.UnloadImage(image)

	rl.SetTextureFilter(texture, rl.FilterBilinear)
	rl.SetTextureWrap(texture, rl.WrapRepeat)
	return
}

// float32Bytes converts a slice of float32 values into a byte slice, which can be used for uploading data to GPU textures.
func float32Bytes(values []float32) (bytes []byte) {
	if len(values) == 0 {
		bytes = nil
		return
	}

	bytes = unsafe.Slice((*byte)(unsafe.Pointer(&values[0])), len(values)*4)
	return
}

// wrap01 ensures that a value is wrapped within the range [0, 1), which is useful for texture coordinate calculations and periodic wave sampling.
func wrap01(v float64) float64 {
	v = math.Mod(v, 1)
	if v < 0 {
		v += 1
	}

	return v
}

// bilerp performs bilinear interpolation between four values based on the provided fractional offsets, allowing for smooth sampling of the wave fields at arbitrary positions.
func bilerp(v00, v10, v01, v11, tx, tz float64) (x float64) {
	var a, b float64 = v00 + (v10-v00)*tx, v01 + (v11-v01)*tx
	return a + (b-a)*tz
}
