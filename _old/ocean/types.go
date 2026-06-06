package ocean

import rl "github.com/gen2brain/raylib-go/raylib"

type Config struct {
	// N must be a power of two. Start with 128; use 256 after the base looks right.
	N int

	// SizeMeters is the width/depth of the periodic FFT patch in world units.
	SizeMeters float32

	// RenderSizeMeters is the width/depth of the camera-centered ocean mesh.
	// It can be much larger than SizeMeters because the shader samples the
	// periodic FFT cascades in world space.
	RenderSizeMeters float32

	// WindDirection controls the Phillips spectrum. It is normalized internally.
	WindDirection rl.Vector2

	// WindSpeed controls the largest generated waves through L = V^2 / g.
	WindSpeed float64

	// Amplitude is the Phillips spectrum amplitude. Tiny changes matter.
	Amplitude float64

	// Choppiness controls horizontal spectral displacement. 0 disables it.
	Choppiness float64

	Seed int64

	// SpectralUpdateHz limits expensive FFT/texture updates. 0 updates every
	// frame; 60 is usually enough because rendering still happens every frame.
	SpectralUpdateHz float32

	// Cascades enables Stage 4 multi-scale spectral waves. If empty, the
	// top-level N/SizeMeters/WindSpeed/Amplitude/Choppiness values are used as
	// a single cascade.
	Cascades []CascadeConfig

	// WaterShading controls the physically informed ocean material. Zero values
	// use conservative defaults chosen for the existing cascade setup.
	WaterShading WaterShadingConfig

	ShaderVert string
	ShaderFrag string
}

type WaterShadingConfig struct {
	DeepColor  rl.Vector3
	MidColor   rl.Vector3
	CrestColor rl.Vector3
	FoamColor  rl.Vector3

	FoamSlopeStart     float32
	FoamSlopeEnd       float32
	FoamCurvatureStart float32
	FoamCurvatureEnd   float32
	FoamAmount         float32
	FoamBreakupScale   float32

	SunColor       rl.Vector3
	SunStrength    float32
	RoughnessBase  float32
	RoughnessCrest float32
	F0             float32

	TransmissionColor    rl.Vector3
	TransmissionStrength float32

	MicroNormalStrength float32
	MicroDetailScale    float32
	MicroDetailSpeed    float32
}

type CascadeConfig struct {
	N             int
	SizeMeters    float32
	WindDirection rl.Vector2
	WindSpeed     float64
	Amplitude     float64
	Choppiness    float64
	Seed          int64
}

type Ocean struct {
	cfg                                                       Config
	cascades                                                  []waveCascade
	mesh                                                      rl.Mesh
	material                                                  rl.Material
	shader                                                    rl.Shader
	h0, h0ConjMinus                                           []complex128
	heightSpec, slopeXSpec, slopeZSpec, dispXSpec, dispZSpec  []complex128
	height, slopeX, slopeZ, dispX, dispZ                      []float64
	kx, kz, kLen, omega                                       []float64
	locSunDir, locCameraPos, locDebugMode, locCascadeCount    int32
	locEnvironmentMode, locTime                               int32
	locRenderGridSpacing, locRenderCenter, locRenderHalfSize  int32
	locCascadeHeightDisp, locCascadeSlopeFold, locCascadeSize [maxShaderCascades]int32
	waterUniforms                                             waterUniformLocations
	sunDirUniform, cameraPosUniform, debugModeUniform         []float32
	environmentModeUniform, timeUniform                       []float32
	cascadeCountUniform, renderGridSpacingUniform             []float32
	renderCenterUniform, renderHalfSizeUniform                []float32
	cascadeSizeUniforms                                       [maxShaderCascades][]float32
	waterUniformValues                                        waterUniformValues
	lastUpdateTime                                            float32
	lastSpectralUpdateTime                                    float32
	spectralUpdateInterval                                    float32
	hasUpdateTime                                             bool
	hasSpectralUpdateTime                                     bool
	lastDebugMode                                             int32
}

type waterUniformLocations struct {
	deepColor, midColor, crestColor, foamColor        int32
	foamSlopeStart, foamSlopeEnd                      int32
	foamCurvatureStart, foamCurvatureEnd              int32
	foamAmount, foamBreakupScale                      int32
	sunColor, sunStrength                             int32
	roughnessBase, roughnessCrest, f0                 int32
	transmissionColor, transmissionStrength           int32
	microNormalStrength, microDetailScale, microSpeed int32
}

type waterUniformValues struct {
	deepColor, midColor, crestColor, foamColor []float32
	foamSlopeStart, foamSlopeEnd               []float32
	foamCurvatureStart, foamCurvatureEnd       []float32
	foamAmount, foamBreakupScale               []float32
	sunColor, sunStrength                      []float32
	roughnessBase, roughnessCrest, f0          []float32
	transmissionColor, transmissionStrength    []float32
	microNormalStrength, microDetailScale      []float32
	microSpeed                                 []float32
}

type waveCascade struct {
	cfg                                                      CascadeConfig
	h0, h0ConjMinus                                          []complex128
	heightSpec, slopeXSpec, slopeZSpec, dispXSpec, dispZSpec []complex128
	height, slopeX, slopeZ, dispX, dispZ                     []float64
	heightDispMap, slopeFoldMap                              []float32
	jacobian, folding                                        []float64
	heightDispTexture, slopeFoldTexture                      rl.Texture2D
	kx, kz, kLen, omega                                      []float64
	lastUpdateTime                                           float32
	hasUpdateTime                                            bool
}
