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

const maxShaderCascades = 3

var cascadeHeightMaterialMapSlots = [maxShaderCascades]int32{
	rl.MapAlbedo,
	rl.MapMetalness,
	rl.MapNormal,
}

var cascadeSlopeMaterialMapSlots = [maxShaderCascades]int32{
	rl.MapRoughness,
	rl.MapOcclusion,
	rl.MapEmission,
}

// Creates a new ocean simulation with the given configuration.
// The returned Ocean must be closed with Close() when no longer needed.
func New(cfg Config) (ocean *Ocean, err error) {
	if cfg.N == 0 {
		cfg.N = 128
	}

	if !isPowerOfTwo(cfg.N) {
		err = fmt.Errorf("FFT grid N must be a power of two, got %d", cfg.N)
		return
	}

	if cfg.SizeMeters <= 0 {
		cfg.SizeMeters = 260
	}

	if cfg.WindSpeed <= 0 {
		cfg.WindSpeed = 10
	}

	if cfg.Amplitude <= 0 {
		cfg.Amplitude = 0.00022
	}

	if cfg.Choppiness < 0 {
		cfg.Choppiness = 0
	}

	if cfg.SpectralUpdateHz < 0 {
		cfg.SpectralUpdateHz = 0
	}

	cfg.WaterShading = waterShadingWithDefaults(cfg.WaterShading)

	ocean = &Ocean{
		cfg:                      cfg,
		sunDirUniform:            make([]float32, 3),
		cameraPosUniform:         make([]float32, 3),
		debugModeUniform:         make([]float32, 1),
		environmentModeUniform:   make([]float32, 1),
		timeUniform:              make([]float32, 1),
		cascadeCountUniform:      make([]float32, 1),
		renderGridSpacingUniform: make([]float32, 1),
		waterUniformValues:       makeWaterUniformValues(),
		lastDebugMode:            -1,
	}

	if ocean.cfg.SpectralUpdateHz > 0 {
		ocean.spectralUpdateInterval = 1 / ocean.cfg.SpectralUpdateHz
	}

	if len(ocean.cfg.Cascades) == 0 {
		ocean.cfg.Cascades = []CascadeConfig{{
			N:             ocean.cfg.N,
			SizeMeters:    ocean.cfg.SizeMeters,
			WindDirection: ocean.cfg.WindDirection,
			WindSpeed:     ocean.cfg.WindSpeed,
			Amplitude:     ocean.cfg.Amplitude,
			Choppiness:    ocean.cfg.Choppiness,
			Seed:          ocean.cfg.Seed,
		}}
	}

	if len(ocean.cfg.Cascades) > maxShaderCascades {
		err = fmt.Errorf("shader supports at most %d ocean cascades, got %d", maxShaderCascades, len(ocean.cfg.Cascades))
		ocean = nil
		return
	}

	for i := range ocean.cascadeSizeUniforms {
		ocean.cascadeSizeUniforms[i] = make([]float32, 1)
	}

	ocean.cascades = make([]waveCascade, len(ocean.cfg.Cascades))
	for i, cascadeCfg := range ocean.cfg.Cascades {
		ocean.cascades[i], err = makeCascade(cascadeCfg, ocean.cfg, i)
		if err != nil {
			ocean = nil
			return
		}
	}

	if err = ocean.buildMesh(); err != nil {
		ocean = nil
		return
	}

	if err = ocean.loadMaterial(); err != nil {
		rl.UnloadMesh(&ocean.mesh)
		ocean = nil
		return
	}

	ocean.loadPackedTextures()
	ocean.assignCascadeTexturesToMaterial()
	ocean.Update(0, rl.NewVector3(-0.42, 0.70, -0.57), rl.NewVector3(0, 8, 20), 0)
	return
}

// Close releases resources used by the ocean. After calling Close, the Ocean should not be used.
func (ocean *Ocean) Close() {
	ocean.unloadPackedTextures()
	rl.UnloadMesh(&ocean.mesh)
	rl.UnloadMaterial(ocean.material)
}

// N returns the FFT grid size (N x N).
func (ocean *Ocean) N() (n int) {
	n = ocean.cfg.N
	return
}

// Size returns the width/depth of the periodic FFT patch in world units.
func (ocean *Ocean) Size() (size float32) {
	size = ocean.cfg.SizeMeters
	return
}

// Spacing returns the distance between adjacent vertices in world units.
func (ocean *Ocean) Spacing() (spacing float32) {
	spacing = ocean.cfg.SizeMeters / float32(ocean.cfg.N)
	return
}

func (ocean *Ocean) CascadeCount() int {
	return len(ocean.cascades)
}

// CascadePackedMaps exposes the Stage 5 texture payloads for a cascade.
// heightDisplacement packs RGBA as H, Dx, Dz, Jacobian.
// slopeFolding packs RGBA as dH/dx, dH/dz, folding seed, unused.
func (ocean *Ocean) CascadePackedMaps(index int) (heightDisplacement, slopeFolding []float32, n int, sizeMeters float32, ok bool) {
	if index < 0 || index >= len(ocean.cascades) {
		ok = false
		return
	}

	var cascade *waveCascade = &ocean.cascades[index]
	heightDisplacement, slopeFolding, n, sizeMeters, ok = cascade.heightDisplacementMap(), cascade.slopeFoldingMap(), cascade.cfg.N, cascade.cfg.SizeMeters, true
	return
}

// CascadePackedTextures exposes the GPU texture handles for the packed FFT results of a cascade,
// which can be used for rendering the ocean surface with the provided shader.
func (ocean *Ocean) CascadePackedTextures(index int) (heightDisplacement, slopeFolding rl.Texture2D, ok bool) {
	if index < 0 || index >= len(ocean.cascades) {
		ok = false
		return
	}

	var cascade *waveCascade = &ocean.cascades[index]
	heightDisplacement, slopeFolding = cascade.heightDispTexture, cascade.slopeFoldTexture
	return
}

// loadPackedTextures uploads the initial (empty) data to the GPU textures for all cascades, preparing them for rendering. This should be called after creating the ocean and whenever the cascade configurations change.
func (ocean *Ocean) loadPackedTextures() {
	for i := range ocean.cascades {
		ocean.cascades[i].loadPackedTextures()
	}
}

// unloadPackedTextures releases the GPU textures used for the packed FFT results of all cascades, freeing up GPU resources. This should be called when the ocean is closed or when cascade configurations change.
func (ocean *Ocean) unloadPackedTextures() {
	for i := range ocean.cascades {
		ocean.cascades[i].unloadPackedTextures()
	}
}

// assignCascadeTexturesToMaterial binds the GPU textures from each cascade to the corresponding slots in the ocean material, allowing the shader to sample the correct textures for rendering the ocean surface.
func (ocean *Ocean) assignCascadeTexturesToMaterial() {
	for i := range ocean.cascades {
		if i >= maxShaderCascades {
			break
		}

		ocean.material.GetMap(cascadeHeightMaterialMapSlots[i]).Texture = ocean.cascades[i].heightDispTexture
		ocean.material.GetMap(cascadeSlopeMaterialMapSlots[i]).Texture = ocean.cascades[i].slopeFoldTexture
	}
}

// allocate initializes the slices used for the ocean simulation based on the configured grid size.
func (ocean *Ocean) allocate() {
	var nn int = ocean.cfg.N * ocean.cfg.N
	ocean.h0 = make([]complex128, nn)
	ocean.h0ConjMinus = make([]complex128, nn)
	ocean.heightSpec = make([]complex128, nn)
	ocean.slopeXSpec = make([]complex128, nn)
	ocean.slopeZSpec = make([]complex128, nn)
	ocean.dispXSpec = make([]complex128, nn)
	ocean.dispZSpec = make([]complex128, nn)
	ocean.height = make([]float64, nn)
	ocean.slopeX = make([]float64, nn)
	ocean.slopeZ = make([]float64, nn)
	ocean.dispX = make([]float64, nn)
	ocean.dispZ = make([]float64, nn)
	ocean.kx = make([]float64, nn)
	ocean.kz = make([]float64, nn)
	ocean.kLen = make([]float64, nn)
	ocean.omega = make([]float64, nn)
}

// precomputeWaveData calculates the wave vector components, their magnitudes, and angular frequencies for each point in the FFT grid.
func (ocean *Ocean) precomputeWaveData() {
	var (
		n int     = ocean.cfg.N
		L float64 = float64(ocean.cfg.SizeMeters)
	)

	for z := range n {
		var nz int = z
		if nz >= n/2 {
			nz -= n
		}

		var kz float64 = 2 * math.Pi * float64(nz) / L

		for x := range n {
			var nx int = x
			if nx >= n/2 {
				nx -= n
			}

			var (
				kx  float64 = 2 * math.Pi * float64(nx) / L
				idx int     = z*n + x
			)

			ocean.kx[idx] = kx
			ocean.kz[idx] = kz
			ocean.kLen[idx] = math.Sqrt(kx*kx + kz*kz)
			ocean.omega[idx] = omega(ocean.kLen[idx])
		}
	}
}

// generateInitialSpectrum creates the initial wave height spectrum (h0) based on the Phillips spectrum and a random seed.
// It also precomputes the conjugate of h0 for negative wave vectors, which is used in the time evolution of the spectrum.
func (ocean *Ocean) generateInitialSpectrum() {
	var (
		rng  *rand.Rand = rand.New(rand.NewSource(ocean.cfg.Seed))
		wind rl.Vector2 = ocean.cfg.WindDirection.Normalize()
		n    int        = ocean.cfg.N
	)

	// Generate h0 from the Phillips spectrum.
	for z := range n {
		for x := range n {
			var (
				idx    int     = z*n + x
				kx, kz float64 = ocean.kx[idx], ocean.kz[idx]
				p      float64 = phillipsSpectrum(kx, kz, float64(wind.X), float64(wind.Y), ocean.cfg.WindSpeed, ocean.cfg.Amplitude)
			)

			ocean.h0[idx] = h0FromSpectrum(rng, p)
		}
	}

	// Precompute conj(h0(-k)).
	for z := range n {
		for x := range n {
			ocean.h0ConjMinus[z*n+x] = cmplx.Conj(ocean.h0[negativeWaveIndex(x, z, n)])
		}
	}
}

// buildMesh creates a static periodic ocean grid.
// The vertex shader samples packed FFT textures to displace it at draw time.
func (ocean *Ocean) buildMesh() (err error) {
	var n int = ocean.cfg.N
	ocean.mesh = rl.GenMeshPlane(ocean.cfg.SizeMeters, ocean.cfg.SizeMeters, n, n)
	return
}

// loadMaterial loads the shader for the ocean surface and sets up the material.
// It also retrieves uniform locations for later use.
func (ocean *Ocean) loadMaterial() (err error) {
	ocean.shader = rl.LoadShader(ocean.cfg.ShaderVert, ocean.cfg.ShaderFrag)
	if ocean.shader.ID == 0 {
		err = fmt.Errorf("failed to load ocean shader")
		return
	}

	ocean.locSunDir = rl.GetShaderLocation(ocean.shader, "sunDirection")
	ocean.locCameraPos = rl.GetShaderLocation(ocean.shader, "cameraPosition")
	ocean.locDebugMode = rl.GetShaderLocation(ocean.shader, "debugMode")
	ocean.locEnvironmentMode = rl.GetShaderLocation(ocean.shader, "environmentMode")
	ocean.locTime = rl.GetShaderLocation(ocean.shader, "time")
	ocean.locCascadeCount = rl.GetShaderLocation(ocean.shader, "cascadeCount")
	ocean.locRenderGridSpacing = rl.GetShaderLocation(ocean.shader, "renderGridSpacing")
	ocean.cacheWaterUniformLocations()
	for i := range maxShaderCascades {
		ocean.locCascadeHeightDisp[i] = rl.GetShaderLocation(ocean.shader, fmt.Sprintf("cascadeHeightDisp%d", i))
		ocean.locCascadeSlopeFold[i] = rl.GetShaderLocation(ocean.shader, fmt.Sprintf("cascadeSlopeFold%d", i))
		ocean.locCascadeSize[i] = rl.GetShaderLocation(ocean.shader, fmt.Sprintf("cascadeSize%d", i))
		setShaderLocation(ocean.shader, rl.ShaderLocMapAlbedo+int32(i), ocean.locCascadeHeightDisp[i])
		setShaderLocation(ocean.shader, rl.ShaderLocMapRoughness+int32(i), ocean.locCascadeSlopeFold[i])
	}

	ocean.material = rl.LoadMaterialDefault()
	ocean.material.Shader = ocean.shader
	return
}

// Update advances the ocean simulation to time t, uploads packed FFT textures,
// and sets shader uniforms for the sun direction, camera, and cascades.
func (ocean *Ocean) Update(t float32, sunDir rl.Vector3, cameraPos rl.Vector3, environmentMode int32) {
	if ocean.shouldUpdateSpectra(t) {
		var wg sync.WaitGroup
		for i := range ocean.cascades {
			wg.Go(func() { ocean.cascades[i].evaluate(t) })
		}

		wg.Wait()

		for i := range ocean.cascades {
			ocean.cascades[i].uploadPackedTextures()
		}

		ocean.lastSpectralUpdateTime = t
		ocean.hasSpectralUpdateTime = true
	}

	ocean.lastUpdateTime = t
	ocean.hasUpdateTime = true

	ocean.sunDirUniform[0] = sunDir.X
	ocean.sunDirUniform[1] = sunDir.Y
	ocean.sunDirUniform[2] = sunDir.Z
	ocean.cameraPosUniform[0] = cameraPos.X
	ocean.cameraPosUniform[1] = cameraPos.Y
	ocean.cameraPosUniform[2] = cameraPos.Z
	ocean.environmentModeUniform[0] = float32(environmentMode)
	ocean.timeUniform[0] = t

	setShaderVec3(ocean.shader, ocean.locSunDir, ocean.sunDirUniform)
	setShaderVec3(ocean.shader, ocean.locCameraPos, ocean.cameraPosUniform)
	setShaderFloat(ocean.shader, ocean.locEnvironmentMode, ocean.environmentModeUniform)
	setShaderFloat(ocean.shader, ocean.locTime, ocean.timeUniform)
	ocean.setWaterShaderValues()
	ocean.setCascadeShaderValues()
}

// shouldUpdateSpectra determines whether the wave spectra need to be recomputed based on the elapsed time and the configured spectral update interval.
func (ocean *Ocean) shouldUpdateSpectra(t float32) bool {
	if !ocean.hasSpectralUpdateTime {
		return true
	}

	if t == ocean.lastSpectralUpdateTime {
		return false
	}

	return ocean.spectralUpdateInterval <= 0 || t-ocean.lastSpectralUpdateTime >= ocean.spectralUpdateInterval
}

// evaluateSpectrum computes the wave height, slope, and displacement spectra at time t based on the initial spectrum and the wave evolution equations.
// It then performs inverse FFTs to get the spatial domain height, slope, and displacement values.
func (ocean *Ocean) evaluateSpectrum(t float64) {
	var (
		n    int     = ocean.cfg.N
		chop float64 = ocean.cfg.Choppiness
	)

	for z := range n {
		for x := range n {
			var (
				idx             int        = z*n + x
				kx, kz, kLen, w float64    = ocean.kx[idx], ocean.kz[idx], ocean.kLen[idx], ocean.omega[idx]
				h               complex128 = ocean.h0[idx]*expI(w*t) + ocean.h0ConjMinus[idx]*expI(-w*t)
			)

			ocean.heightSpec[idx], ocean.slopeXSpec[idx], ocean.slopeZSpec[idx], ocean.dispXSpec[idx], ocean.dispZSpec[idx] = spectralFields(h, kx, kz, kLen, chop)
		}
	}

	fft2D(ocean.heightSpec, n, true)
	fft2D(ocean.slopeXSpec, n, true)
	fft2D(ocean.slopeZSpec, n, true)
	fft2D(ocean.dispXSpec, n, true)
	fft2D(ocean.dispZSpec, n, true)

	for i := range n * n {
		// The spectrum is stored in standard FFT order: [0..N/2, negative frequencies].
		// Therefore no checkerboard sign flip is applied after the inverse FFT.
		ocean.height[i] = real(ocean.heightSpec[i])
		ocean.slopeX[i] = real(ocean.slopeXSpec[i])
		ocean.slopeZ[i] = real(ocean.slopeZSpec[i])
		ocean.dispX[i] = real(ocean.dispXSpec[i])
		ocean.dispZ[i] = real(ocean.dispZSpec[i])
	}
}

// basePosition calculates the world space position of the vertex at grid coordinates (x, z) in the ocean mesh.
func (ocean *Ocean) basePosition(x, z int) (baseX, baseZ float32) {
	var (
		half    float32 = ocean.cfg.SizeMeters * 0.5
		spacing float32 = ocean.Spacing()
	)

	baseX = float32(x)*spacing - half
	baseZ = float32(z)*spacing - half
	return
}

func periodicSampleIndex(x, z, n int) int {
	return (z%n)*n + (x % n)
}

// negativeWaveIndex calculates the index of the wave vector that is the negative of the one at (x, z) in the FFT grid,
// which is used for computing the conjugate spectrum.
func (ocean *Ocean) setCascadeShaderValues() {
	ocean.cascadeCountUniform[0] = float32(len(ocean.cascades))
	ocean.renderGridSpacingUniform[0] = ocean.Spacing()

	setShaderFloat(ocean.shader, ocean.locCascadeCount, ocean.cascadeCountUniform)
	setShaderFloat(ocean.shader, ocean.locRenderGridSpacing, ocean.renderGridSpacingUniform)

	for i := range maxShaderCascades {
		var size float32 = float32(1)
		if i < len(ocean.cascades) {
			size = ocean.cascades[i].cfg.SizeMeters
		}

		ocean.cascadeSizeUniforms[i][0] = size
		setShaderFloat(ocean.shader, ocean.locCascadeSize[i], ocean.cascadeSizeUniforms[i])
	}
}

// defaultWaterShadingConfig returns a WaterShadingConfig struct populated with default values for all shading parameters
func defaultWaterShadingConfig() WaterShadingConfig {
	return WaterShadingConfig{
		DeepColor:  rl.NewVector3(0.012, 0.078, 0.110),
		MidColor:   rl.NewVector3(0.024, 0.135, 0.160),
		CrestColor: rl.NewVector3(0.095, 0.205, 0.215),
		FoamColor:  rl.NewVector3(0.740, 0.840, 0.865),

		FoamSlopeStart:     0.58,
		FoamSlopeEnd:       1.42,
		FoamCurvatureStart: 0.060,
		FoamCurvatureEnd:   0.240,
		FoamAmount:         0.38,
		FoamBreakupScale:   0.095,

		SunColor:       rl.NewVector3(1.000, 0.910, 0.700),
		SunStrength:    1.10,
		RoughnessBase:  0.055,
		RoughnessCrest: 0.185,
		F0:             0.020,

		TransmissionColor:    rl.NewVector3(0.075, 0.280, 0.255),
		TransmissionStrength: 0.23,

		MicroNormalStrength: 0.105,
		MicroDetailScale:    1.85,
		MicroDetailSpeed:    0.75,
	}
}

// waterShadingWithDefaults takes a WaterShadingConfig and fills in any zero or non-positive values with defaults from defaultWaterShadingConfig.
// This allows users to specify only the parameters they want to customize while ensuring all necessary values are set for the shader.
func waterShadingWithDefaults(cfg WaterShadingConfig) WaterShadingConfig {
	var defaults = defaultWaterShadingConfig()

	if isZeroVector3(cfg.DeepColor) {
		cfg.DeepColor = defaults.DeepColor
	}

	if isZeroVector3(cfg.MidColor) {
		cfg.MidColor = defaults.MidColor
	}

	if isZeroVector3(cfg.CrestColor) {
		cfg.CrestColor = defaults.CrestColor
	}

	if isZeroVector3(cfg.FoamColor) {
		cfg.FoamColor = defaults.FoamColor
	}

	if cfg.FoamSlopeStart <= 0 {
		cfg.FoamSlopeStart = defaults.FoamSlopeStart
	}

	if cfg.FoamSlopeEnd <= 0 {
		cfg.FoamSlopeEnd = defaults.FoamSlopeEnd
	}

	if cfg.FoamCurvatureStart <= 0 {
		cfg.FoamCurvatureStart = defaults.FoamCurvatureStart
	}

	if cfg.FoamCurvatureEnd <= 0 {
		cfg.FoamCurvatureEnd = defaults.FoamCurvatureEnd
	}

	if cfg.FoamAmount <= 0 {
		cfg.FoamAmount = defaults.FoamAmount
	}

	if cfg.FoamBreakupScale <= 0 {
		cfg.FoamBreakupScale = defaults.FoamBreakupScale
	}

	if isZeroVector3(cfg.SunColor) {
		cfg.SunColor = defaults.SunColor
	}

	if cfg.SunStrength <= 0 {
		cfg.SunStrength = defaults.SunStrength
	}

	if cfg.RoughnessBase <= 0 {
		cfg.RoughnessBase = defaults.RoughnessBase
	}

	if cfg.RoughnessCrest <= 0 {
		cfg.RoughnessCrest = defaults.RoughnessCrest
	}

	if cfg.F0 <= 0 {
		cfg.F0 = defaults.F0
	}

	if isZeroVector3(cfg.TransmissionColor) {
		cfg.TransmissionColor = defaults.TransmissionColor
	}

	if cfg.TransmissionStrength <= 0 {
		cfg.TransmissionStrength = defaults.TransmissionStrength
	}

	if cfg.MicroNormalStrength <= 0 {
		cfg.MicroNormalStrength = defaults.MicroNormalStrength
	}

	if cfg.MicroDetailScale <= 0 {
		cfg.MicroDetailScale = defaults.MicroDetailScale
	}

	if cfg.MicroDetailSpeed <= 0 {
		cfg.MicroDetailSpeed = defaults.MicroDetailSpeed
	}

	return cfg
}

func isZeroVector3(v rl.Vector3) bool {
	return v.X == 0 && v.Y == 0 && v.Z == 0
}

func makeWaterUniformValues() waterUniformValues {
	return waterUniformValues{
		deepColor:            make([]float32, 3),
		midColor:             make([]float32, 3),
		crestColor:           make([]float32, 3),
		foamColor:            make([]float32, 3),
		foamSlopeStart:       make([]float32, 1),
		foamSlopeEnd:         make([]float32, 1),
		foamCurvatureStart:   make([]float32, 1),
		foamCurvatureEnd:     make([]float32, 1),
		foamAmount:           make([]float32, 1),
		foamBreakupScale:     make([]float32, 1),
		sunColor:             make([]float32, 3),
		sunStrength:          make([]float32, 1),
		roughnessBase:        make([]float32, 1),
		roughnessCrest:       make([]float32, 1),
		f0:                   make([]float32, 1),
		transmissionColor:    make([]float32, 3),
		transmissionStrength: make([]float32, 1),
		microNormalStrength:  make([]float32, 1),
		microDetailScale:     make([]float32, 1),
		microSpeed:           make([]float32, 1),
	}
}

func (ocean *Ocean) cacheWaterUniformLocations() {
	var uniforms *waterUniformLocations = &ocean.waterUniforms
	uniforms.deepColor = rl.GetShaderLocation(ocean.shader, "uDeepColor")
	uniforms.midColor = rl.GetShaderLocation(ocean.shader, "uMidColor")
	uniforms.crestColor = rl.GetShaderLocation(ocean.shader, "uCrestColor")
	uniforms.foamColor = rl.GetShaderLocation(ocean.shader, "uFoamColor")
	uniforms.foamSlopeStart = rl.GetShaderLocation(ocean.shader, "uFoamSlopeStart")
	uniforms.foamSlopeEnd = rl.GetShaderLocation(ocean.shader, "uFoamSlopeEnd")
	uniforms.foamCurvatureStart = rl.GetShaderLocation(ocean.shader, "uFoamCurvatureStart")
	uniforms.foamCurvatureEnd = rl.GetShaderLocation(ocean.shader, "uFoamCurvatureEnd")
	uniforms.foamAmount = rl.GetShaderLocation(ocean.shader, "uFoamAmount")
	uniforms.foamBreakupScale = rl.GetShaderLocation(ocean.shader, "uFoamBreakupScale")
	uniforms.sunColor = rl.GetShaderLocation(ocean.shader, "uSunColor")
	uniforms.sunStrength = rl.GetShaderLocation(ocean.shader, "uSunStrength")
	uniforms.roughnessBase = rl.GetShaderLocation(ocean.shader, "uRoughnessBase")
	uniforms.roughnessCrest = rl.GetShaderLocation(ocean.shader, "uRoughnessCrest")
	uniforms.f0 = rl.GetShaderLocation(ocean.shader, "uF0")
	uniforms.transmissionColor = rl.GetShaderLocation(ocean.shader, "uTransmissionColor")
	uniforms.transmissionStrength = rl.GetShaderLocation(ocean.shader, "uTransmissionStrength")
	uniforms.microNormalStrength = rl.GetShaderLocation(ocean.shader, "uMicroNormalStrength")
	uniforms.microDetailScale = rl.GetShaderLocation(ocean.shader, "uMicroDetailScale")
	uniforms.microSpeed = rl.GetShaderLocation(ocean.shader, "uMicroDetailSpeed")
}

func (ocean *Ocean) setWaterShaderValues() {
	var (
		cfg    WaterShadingConfig    = ocean.cfg.WaterShading
		loc    waterUniformLocations = ocean.waterUniforms
		values *waterUniformValues   = &ocean.waterUniformValues
	)

	setVectorUniform(values.deepColor, cfg.DeepColor)
	setVectorUniform(values.midColor, cfg.MidColor)
	setVectorUniform(values.crestColor, cfg.CrestColor)
	setVectorUniform(values.foamColor, cfg.FoamColor)
	setVectorUniform(values.sunColor, cfg.SunColor)
	setVectorUniform(values.transmissionColor, cfg.TransmissionColor)

	values.foamSlopeStart[0] = cfg.FoamSlopeStart
	values.foamSlopeEnd[0] = cfg.FoamSlopeEnd
	values.foamCurvatureStart[0] = cfg.FoamCurvatureStart
	values.foamCurvatureEnd[0] = cfg.FoamCurvatureEnd
	values.foamAmount[0] = cfg.FoamAmount
	values.foamBreakupScale[0] = cfg.FoamBreakupScale
	values.sunStrength[0] = cfg.SunStrength
	values.roughnessBase[0] = cfg.RoughnessBase
	values.roughnessCrest[0] = cfg.RoughnessCrest
	values.f0[0] = cfg.F0
	values.transmissionStrength[0] = cfg.TransmissionStrength
	values.microNormalStrength[0] = cfg.MicroNormalStrength
	values.microDetailScale[0] = cfg.MicroDetailScale
	values.microSpeed[0] = cfg.MicroDetailSpeed

	setShaderVec3(ocean.shader, loc.deepColor, values.deepColor)
	setShaderVec3(ocean.shader, loc.midColor, values.midColor)
	setShaderVec3(ocean.shader, loc.crestColor, values.crestColor)
	setShaderVec3(ocean.shader, loc.foamColor, values.foamColor)
	setShaderFloat(ocean.shader, loc.foamSlopeStart, values.foamSlopeStart)
	setShaderFloat(ocean.shader, loc.foamSlopeEnd, values.foamSlopeEnd)
	setShaderFloat(ocean.shader, loc.foamCurvatureStart, values.foamCurvatureStart)
	setShaderFloat(ocean.shader, loc.foamCurvatureEnd, values.foamCurvatureEnd)
	setShaderFloat(ocean.shader, loc.foamAmount, values.foamAmount)
	setShaderFloat(ocean.shader, loc.foamBreakupScale, values.foamBreakupScale)
	setShaderVec3(ocean.shader, loc.sunColor, values.sunColor)
	setShaderFloat(ocean.shader, loc.sunStrength, values.sunStrength)
	setShaderFloat(ocean.shader, loc.roughnessBase, values.roughnessBase)
	setShaderFloat(ocean.shader, loc.roughnessCrest, values.roughnessCrest)
	setShaderFloat(ocean.shader, loc.f0, values.f0)
	setShaderVec3(ocean.shader, loc.transmissionColor, values.transmissionColor)
	setShaderFloat(ocean.shader, loc.transmissionStrength, values.transmissionStrength)
	setShaderFloat(ocean.shader, loc.microNormalStrength, values.microNormalStrength)
	setShaderFloat(ocean.shader, loc.microDetailScale, values.microDetailScale)
	setShaderFloat(ocean.shader, loc.microSpeed, values.microSpeed)
}

func setVectorUniform(dst []float32, v rl.Vector3) {
	dst[0] = v.X
	dst[1] = v.Y
	dst[2] = v.Z
}

// Draw renders the ocean surface using the current mesh and material. It also sets the debug mode uniform for the shader.
func (ocean *Ocean) Draw(debugMode int32, cameraPos rl.Vector3) {
	if debugMode != ocean.lastDebugMode {
		ocean.debugModeUniform[0] = float32(debugMode)
		setShaderFloat(ocean.shader, ocean.locDebugMode, ocean.debugModeUniform)
		ocean.lastDebugMode = debugMode
	}

	// Draw a 3x3 set of periodic FFT patches around the camera.
	// This keeps the boilerplate navigable without implementing real clipmaps yet.
	var (
		size             = ocean.cfg.SizeMeters
		centerX, centerZ = float32(math.Floor(float64(cameraPos.X/size))) * size, float32(math.Floor(float64(cameraPos.Z/size))) * size
	)

	for dz := -1; dz <= 1; dz++ {
		for dx := -1; dx <= 1; dx++ {
			var (
				x, z      float32   = centerX + float32(dx)*size, centerZ + float32(dz)*size
				transform rl.Matrix = rl.MatrixTranslate(x, 0, z)
			)

			rl.DrawMesh(ocean.mesh, ocean.material, transform)
		}
	}
}

func setShaderVec3(shader rl.Shader, loc int32, value []float32) {
	if loc >= 0 {
		rl.SetShaderValue(shader, loc, value, rl.ShaderUniformVec3)
	}
}

func setShaderFloat(shader rl.Shader, loc int32, value []float32) {
	if loc >= 0 {
		rl.SetShaderValue(shader, loc, value, rl.ShaderUniformFloat)
	}
}

func setShaderLocation(shader rl.Shader, index int32, loc int32) {
	if shader.Locs == nil {
		return
	}

	ptr := unsafe.Pointer(uintptr(unsafe.Pointer(shader.Locs)) + uintptr(index)*unsafe.Sizeof(int32(0)))
	*(*int32)(ptr) = loc
}
