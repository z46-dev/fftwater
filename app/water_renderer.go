package app

import (
	"context"
	"fmt"
	"image"
	"image/png"
	"math"
	"os"
	"path/filepath"
	"time"

	"github.com/gogpu/gputypes"
	"github.com/gogpu/wgpu"
	"github.com/z46-dev/fftwater/shader"
	"github.com/z46-dev/fftwater/util"
)

const (
	waterGridCells           uint32  = 160
	waterSpectrumTextureSize uint32  = 256
	waterModeTextureSize     uint32  = 64
	waterModeCascadeCount    uint32  = 4
	waterFFTStageCount               = 6
	waterFrameUniformSize    uint64  = 192
	waterMaxDistance         float32 = 120000.0
	waterGridSnap            float32 = 0.0
	waterChopScale           float32 = 0.66
	waterFoamGain            float32 = 0.82
	waterDetailGain          float32 = 1.44
	waterMotionTimeScale     float32 = 0.80
	// 512² gives a 5m texel over the local field. Per-fragment footprint
	// filtering handles distance aliasing without paying the 2.25x compute and
	// bandwidth cost of the previous 768² field.
	waterInteractionSize        uint32  = 512
	waterInteractionSpan        float32 = 2560.0
	waterInteractionStep        float32 = 1.0 / 30.0
	waterInteractionUniformSize uint64  = 224
	// Height knob for quick tuning. This is packed into water_params1.y and
	// intentionally scales coherent FFT body waves, not high-frequency
	// capillary normal noise. Raise/lower this first when tuning sea state.
	waterHeightScaleDefault float32            = 0.92
	waterSpectrumWorldSize  float32            = 3072.0
	shipDepthFormat         wgpu.TextureFormat = gputypes.TextureFormatDepth32Float
	shipEffectFormat        wgpu.TextureFormat = gputypes.TextureFormatRGBA8Unorm
)

type ShipReflectionQuality int

const (
	ShipReflectionOff ShipReflectionQuality = iota
	ShipReflectionLow
	ShipReflectionMedium
	ShipReflectionHigh
)

func (q ShipReflectionQuality) Label() string {
	switch q {
	case ShipReflectionLow:
		return "low"
	case ShipReflectionMedium:
		return "medium"
	case ShipReflectionHigh:
		return "high"
	default:
		return "off"
	}
}

// WaterFrame contains the per-frame inputs for the projected water grid.
// The uniforms deliberately expose camera basis vectors instead of hiding the
// math behind screen-space tricks. That maps cleanly to the way large-ocean
// renderers usually build a projected grid: reconstruct a camera ray for each
// grid vertex, intersect that ray against the water plane, then displace and
// shade the resulting world-space position.
type WaterFrame struct {
	Width           uint32
	Height          uint32
	Time            float32
	DebugMode       float32
	WaveHeightScale float32

	Aspect      float32
	TanHalfFOVY float32
	ViewProj    Mat4

	CameraPosition Vec3
	CameraForward  Vec3
	CameraRight    Vec3
	CameraUp       Vec3

	SpectrumOriginX    float32
	SpectrumOriginZ    float32
	SpectrumWorldSize  float32
	SpectrumTextureDim float32
	InteractionOriginX float32
	InteractionOriginZ float32
}

func NewWaterFrame(width, height uint32, time, aspect float32, cam *WaterCamera) WaterFrame {
	if cam == nil {
		cam = NewWaterCamera()
	}

	forward, right, up := cam.Basis()

	// Keep the field window camera-centered for precision, but quantize its
	// origin to exactly one field texel. Without this, the field texture slides
	// sub-texel every time the camera moves, which makes the projected grid look
	// like it is swimming even when the underlying spectrum is world-space.
	fieldTexelWorld := waterSpectrumWorldSize / float32(waterSpectrumTextureSize)
	originX := cam.Position.X - waterSpectrumWorldSize*0.5
	originZ := cam.Position.Z - waterSpectrumWorldSize*0.5
	if fieldTexelWorld > 0 {
		originX = float32(math.Floor(float64(originX/fieldTexelWorld))) * fieldTexelWorld
		originZ = float32(math.Floor(float64(originZ/fieldTexelWorld))) * fieldTexelWorld
	}

	return WaterFrame{
		Width:              width,
		Height:             height,
		Time:               time * waterMotionTimeScale,
		Aspect:             aspect,
		TanHalfFOVY:        cam.TanHalfFOVY(),
		ViewProj:           cam.ViewProj(aspect),
		CameraPosition:     cam.Position,
		CameraForward:      forward,
		CameraRight:        right,
		CameraUp:           up,
		SpectrumOriginX:    originX,
		SpectrumOriginZ:    originZ,
		SpectrumWorldSize:  waterSpectrumWorldSize,
		SpectrumTextureDim: float32(waterSpectrumTextureSize),
	}
}

// WaterRenderer owns the low-level WebGPU resources for the water pass.
// It stays in app for now because the renderer is still exploratory and should
// remain easy to patch while the shader model converges.
type WaterRenderer struct {
	device        *wgpu.Device
	surfaceFormat wgpu.TextureFormat
	debugMode     int
	heightScale   float32
	shipAA        bool

	shaderModule            *wgpu.ShaderModule
	skyShaderModule         *wgpu.ShaderModule
	initShaderModule        *wgpu.ShaderModule
	evolveShaderModule      *wgpu.ShaderModule
	fftShaderModule         *wgpu.ShaderModule
	computeShaderModule     *wgpu.ShaderModule
	filterShaderModule      *wgpu.ShaderModule
	waveDataShaderModule    *wgpu.ShaderModule
	foamHistoryShaderModule *wgpu.ShaderModule
	variationShaderModule   *wgpu.ShaderModule
	interactionShaderModule *wgpu.ShaderModule

	shipRenderer           *ShipRenderer
	shipDepthTexture       *wgpu.Texture
	shipDepthView          *wgpu.TextureView
	shipDepthWidth         uint32
	shipDepthHeight        uint32
	shipDepthSamples       uint32
	shipReflections        ShipReflectionQuality
	shipShadows            bool
	reflectionTexture      *wgpu.Texture
	reflectionView         *wgpu.TextureView
	reflectionDepthTexture *wgpu.Texture
	reflectionDepthView    *wgpu.TextureView
	reflectionWidth        uint32
	reflectionHeight       uint32
	shadowTexture          *wgpu.Texture
	shadowView             *wgpu.TextureView
	shadowDepthTexture     *wgpu.Texture
	shadowDepthView        *wgpu.TextureView
	shadowWidth            uint32
	shadowHeight           uint32
	msaaColorTexture       *wgpu.Texture
	msaaColorView          *wgpu.TextureView
	msaaColorWidth         uint32
	msaaColorHeight        uint32

	uniformBuffer            *wgpu.Buffer
	interactionUniformBuffer *wgpu.Buffer

	h0ModeTexture *wgpu.Texture
	h0ModeView    *wgpu.TextureView

	// evolvedModeTexture packs two complex spectra:
	//   RG = height H(k,t)
	//   BA = horizontal displacement X spectrum -i*kx/|k|*H(k,t)
	evolvedModeTexture *wgpu.Texture
	evolvedModeView    *wgpu.TextureView

	// evolvedAuxModeTexture packs the other two complex spectra:
	//   RG = horizontal displacement Z spectrum -i*kz/|k|*H(k,t)
	//   BA = curvature spectrum -|k|^2*H(k,t), used for crest/foam seeding
	evolvedAuxModeTexture *wgpu.Texture
	evolvedAuxModeView    *wgpu.TextureView

	fftPingTexture *wgpu.Texture
	fftPingView    *wgpu.TextureView
	fftPongTexture *wgpu.Texture
	fftPongView    *wgpu.TextureView

	fftAuxPingTexture *wgpu.Texture
	fftAuxPingView    *wgpu.TextureView
	fftAuxPongTexture *wgpu.Texture
	fftAuxPongView    *wgpu.TextureView

	rawSpectrumTexture   *wgpu.Texture
	rawSpectrumView      *wgpu.TextureView
	fieldSpectrumTexture *wgpu.Texture
	fieldSpectrumView    *wgpu.TextureView
	waveDataTexture      *wgpu.Texture
	waveDataView         *wgpu.TextureView
	foamHistoryTextureA  *wgpu.Texture
	foamHistoryViewA     *wgpu.TextureView
	foamHistoryTextureB  *wgpu.Texture
	foamHistoryViewB     *wgpu.TextureView
	variationTexture     *wgpu.Texture
	variationView        *wgpu.TextureView
	interactionTextureA  *wgpu.Texture
	interactionViewA     *wgpu.TextureView
	interactionTextureB  *wgpu.Texture
	interactionViewB     *wgpu.TextureView
	interactionSampler   *wgpu.Sampler

	spectrumInitialized    bool
	variationInitialized   bool
	foamHistoryInitialized bool
	foamHistoryFlip        bool
	interactionInitialized bool
	interactionFlip        bool
	interactionOriginX     float32
	interactionOriginZ     float32
	interactionLastTime    float32

	renderBindGroupLayout      *wgpu.BindGroupLayout
	skyBindGroupLayout         *wgpu.BindGroupLayout
	initBindGroupLayout        *wgpu.BindGroupLayout
	evolveBindGroupLayout      *wgpu.BindGroupLayout
	fftBindGroupLayout         *wgpu.BindGroupLayout
	computeBindGroupLayout     *wgpu.BindGroupLayout
	filterBindGroupLayout      *wgpu.BindGroupLayout
	waveDataBindGroupLayout    *wgpu.BindGroupLayout
	foamHistoryBindGroupLayout *wgpu.BindGroupLayout
	variationBindGroupLayout   *wgpu.BindGroupLayout
	interactionBindGroupLayout *wgpu.BindGroupLayout

	renderPipelineLayout      *wgpu.PipelineLayout
	skyPipelineLayout         *wgpu.PipelineLayout
	initPipelineLayout        *wgpu.PipelineLayout
	evolvePipelineLayout      *wgpu.PipelineLayout
	fftPipelineLayout         *wgpu.PipelineLayout
	computePipelineLayout     *wgpu.PipelineLayout
	filterPipelineLayout      *wgpu.PipelineLayout
	waveDataPipelineLayout    *wgpu.PipelineLayout
	foamHistoryPipelineLayout *wgpu.PipelineLayout
	variationPipelineLayout   *wgpu.PipelineLayout
	interactionPipelineLayout *wgpu.PipelineLayout

	renderBindGroupAA *wgpu.BindGroup
	renderBindGroupAB *wgpu.BindGroup
	renderBindGroupBA *wgpu.BindGroup
	renderBindGroupBB *wgpu.BindGroup
	skyBindGroup      *wgpu.BindGroup
	initBindGroup     *wgpu.BindGroup
	evolveBindGroup   *wgpu.BindGroup

	fftEvolvedToPingBindGroup *wgpu.BindGroup
	fftPingToPongBindGroup    *wgpu.BindGroup
	fftPongToPingBindGroup    *wgpu.BindGroup

	fftAuxEvolvedToPingBindGroup *wgpu.BindGroup
	fftAuxPingToPongBindGroup    *wgpu.BindGroup
	fftAuxPongToPingBindGroup    *wgpu.BindGroup

	computeBindGroup     *wgpu.BindGroup
	filterBindGroup      *wgpu.BindGroup
	waveDataBindGroup    *wgpu.BindGroup
	foamHistoryAToBGroup *wgpu.BindGroup
	foamHistoryBToAGroup *wgpu.BindGroup
	variationBindGroup   *wgpu.BindGroup
	interactionAToBGroup *wgpu.BindGroup
	interactionBToAGroup *wgpu.BindGroup

	renderPipeline                  *wgpu.RenderPipeline
	renderPipelineMSAA              *wgpu.RenderPipeline
	skyPipeline                     *wgpu.RenderPipeline
	skyPipelineMSAA                 *wgpu.RenderPipeline
	initPipeline                    *wgpu.ComputePipeline
	evolvePipeline                  *wgpu.ComputePipeline
	fftBitReverseHorizontalPipeline *wgpu.ComputePipeline
	fftBitReverseVerticalPipeline   *wgpu.ComputePipeline
	fftHorizontalPipelines          [waterFFTStageCount]*wgpu.ComputePipeline
	fftVerticalPipelines            [waterFFTStageCount]*wgpu.ComputePipeline
	computePipeline                 *wgpu.ComputePipeline
	filterPipeline                  *wgpu.ComputePipeline
	waveDataPipeline                *wgpu.ComputePipeline
	foamHistoryPipeline             *wgpu.ComputePipeline
	foamHistoryClearPipeline        *wgpu.ComputePipeline
	variationPipeline               *wgpu.ComputePipeline
	interactionPipeline             *wgpu.ComputePipeline
}

func (r *WaterRenderer) SetDebugMode(mode int) {
	if mode < 0 {
		mode = 0
	}
	r.debugMode = mode
}

func (r *WaterRenderer) SetWaveHeightScale(scale float32) {
	if scale < 0.20 {
		scale = 0.20
	} else if scale > 3.00 {
		scale = 3.00
	}
	r.heightScale = scale
}

func (r *WaterRenderer) WaveHeightScale() float32 {
	if r == nil || r.heightScale <= 0 {
		return waterHeightScaleDefault
	}
	return r.heightScale
}

func (r *WaterRenderer) SetShipAA(enabled bool) {
	if r != nil {
		r.shipAA = enabled
	}
}

func (r *WaterRenderer) ShipAAEnabled() bool {
	return r != nil && r.shipAA
}

func (r *WaterRenderer) SetShipReflectionQuality(quality ShipReflectionQuality) {
	if r == nil {
		return
	}
	if quality < ShipReflectionOff {
		quality = ShipReflectionOff
	} else if quality > ShipReflectionHigh {
		quality = ShipReflectionHigh
	}
	if r.shipReflections != quality {
		r.shipReflections = quality
		r.reflectionWidth = 0
		r.reflectionHeight = 0
	}
}

func (r *WaterRenderer) ShipReflectionQuality() ShipReflectionQuality {
	if r == nil {
		return ShipReflectionOff
	}
	return r.shipReflections
}

func (r *WaterRenderer) SetShipShadows(enabled bool) {
	if r != nil && r.shipShadows != enabled {
		r.shipShadows = enabled
		r.shadowWidth = 0
		r.shadowHeight = 0
	}
}

func (r *WaterRenderer) ShipShadowsEnabled() bool {
	return r != nil && r.shipShadows
}

func NewWaterRenderer(device *wgpu.Device, surfaceFormat wgpu.TextureFormat) (*WaterRenderer, error) {
	if device == nil {
		return nil, fmt.Errorf("nil wgpu device")
	}

	r := &WaterRenderer{
		device:        device,
		surfaceFormat: surfaceFormat,
		heightScale:   waterHeightScaleDefault,
	}

	var err error
	if err = r.createResources(); err != nil {
		r.Release()
		return nil, err
	}

	return r, nil
}

func (r *WaterRenderer) createRGBA32FloatTexture(label string, width, height uint32) (*wgpu.Texture, *wgpu.TextureView, error) {
	return r.createFloatTexture(label, width, height, gputypes.TextureFormatRGBA32Float)
}

func (r *WaterRenderer) createFloatTexture(label string, width, height uint32, format wgpu.TextureFormat) (*wgpu.Texture, *wgpu.TextureView, error) {
	tex, err := r.device.CreateTexture(&wgpu.TextureDescriptor{
		Label: label,
		Size: wgpu.Extent3D{
			Width:              width,
			Height:             height,
			DepthOrArrayLayers: 1,
		},
		MipLevelCount: 1,
		SampleCount:   1,
		Dimension:     wgpu.TextureDimension2D,
		Format:        format,
		Usage:         wgpu.TextureUsageStorageBinding | wgpu.TextureUsageTextureBinding,
	})
	if err != nil {
		return nil, nil, err
	}

	view, err := r.device.CreateTextureView(tex, &wgpu.TextureViewDescriptor{
		Label:           label + " view",
		Format:          format,
		Dimension:       gputypes.TextureViewDimension2D,
		Aspect:          gputypes.TextureAspectAll,
		BaseMipLevel:    0,
		MipLevelCount:   1,
		BaseArrayLayer:  0,
		ArrayLayerCount: 1,
	})
	if err != nil {
		tex.Release()
		return nil, nil, err
	}

	return tex, view, nil
}

func (r *WaterRenderer) createSpectrumTexture(label string) (*wgpu.Texture, *wgpu.TextureView, error) {
	return r.createRGBA32FloatTexture(label, waterSpectrumTextureSize, waterSpectrumTextureSize)
}

func (r *WaterRenderer) createModeTexture(label string) (*wgpu.Texture, *wgpu.TextureView, error) {
	return r.createRGBA32FloatTexture(label, waterModeTextureSize, waterModeTextureSize*waterModeCascadeCount)
}

func uniformLayoutEntry(visibility wgpu.ShaderStages) wgpu.BindGroupLayoutEntry {
	return wgpu.BindGroupLayoutEntry{
		Binding:    0,
		Visibility: visibility,
		Buffer: &gputypes.BufferBindingLayout{
			Type:           gputypes.BufferBindingTypeUniform,
			MinBindingSize: waterFrameUniformSize,
		},
	}
}

func sampledFloatTextureLayoutEntry(binding uint32, visibility wgpu.ShaderStages) wgpu.BindGroupLayoutEntry {
	return wgpu.BindGroupLayoutEntry{
		Binding:    binding,
		Visibility: visibility,
		Texture: &gputypes.TextureBindingLayout{
			SampleType:    gputypes.TextureSampleTypeUnfilterableFloat,
			ViewDimension: gputypes.TextureViewDimension2D,
		},
	}
}

func sampledFilterableFloatTextureLayoutEntry(binding uint32, visibility wgpu.ShaderStages) wgpu.BindGroupLayoutEntry {
	return wgpu.BindGroupLayoutEntry{
		Binding:    binding,
		Visibility: visibility,
		Texture: &gputypes.TextureBindingLayout{
			SampleType:    gputypes.TextureSampleTypeFloat,
			ViewDimension: gputypes.TextureViewDimension2D,
		},
	}
}

func writeFloatStorageTextureLayoutEntry(binding uint32, visibility wgpu.ShaderStages, format wgpu.TextureFormat) wgpu.BindGroupLayoutEntry {
	return wgpu.BindGroupLayoutEntry{
		Binding:    binding,
		Visibility: visibility,
		StorageTexture: &gputypes.StorageTextureBindingLayout{
			Access:        gputypes.StorageTextureAccessWriteOnly,
			Format:        format,
			ViewDimension: gputypes.TextureViewDimension2D,
		},
	}
}

func writeRGBA32StorageTextureLayoutEntry(binding uint32, visibility wgpu.ShaderStages) wgpu.BindGroupLayoutEntry {
	return writeFloatStorageTextureLayoutEntry(binding, visibility, gputypes.TextureFormatRGBA32Float)
}

func (r *WaterRenderer) createResources() error {
	var err error

	r.shaderModule, err = r.device.CreateShaderModule(&wgpu.ShaderModuleDescriptor{
		Label: "water projected-grid shader",
		WGSL:  shader.WaterWGSL,
	})
	if err != nil {
		return fmt.Errorf("create water shader module: %w", err)
	}

	r.skyShaderModule, err = r.device.CreateShaderModule(&wgpu.ShaderModuleDescriptor{
		Label: "procedural skybox shader",
		WGSL:  shader.SkyWGSL,
	})
	if err != nil {
		return fmt.Errorf("create skybox shader module: %w", err)
	}

	r.initShaderModule, err = r.device.CreateShaderModule(&wgpu.ShaderModuleDescriptor{
		Label: "water h0 spectrum init shader",
		WGSL:  shader.OceanInitWGSL,
	})
	if err != nil {
		return fmt.Errorf("create water h0 init shader module: %w", err)
	}

	r.evolveShaderModule, err = r.device.CreateShaderModule(&wgpu.ShaderModuleDescriptor{
		Label: "water spectral vector evolution shader",
		WGSL:  shader.OceanEvolveWGSL,
	})
	if err != nil {
		return fmt.Errorf("create water spectral evolution shader module: %w", err)
	}

	r.fftShaderModule, err = r.device.CreateShaderModule(&wgpu.ShaderModuleDescriptor{
		Label: "water packed vector inverse FFT shader",
		WGSL:  shader.OceanFFTWGSL,
	})
	if err != nil {
		return fmt.Errorf("create water staged inverse FFT shader module: %w", err)
	}

	r.computeShaderModule, err = r.device.CreateShaderModule(&wgpu.ShaderModuleDescriptor{
		Label: "water FFT tile expansion compute shader",
		WGSL:  shader.OceanSpectrumWGSL,
	})
	if err != nil {
		return fmt.Errorf("create water spatial inverse shader module: %w", err)
	}

	r.filterShaderModule, err = r.device.CreateShaderModule(&wgpu.ShaderModuleDescriptor{
		Label: "water spectrum filter shader",
		WGSL:  shader.OceanFilterWGSL,
	})
	if err != nil {
		return fmt.Errorf("create water spectrum filter shader module: %w", err)
	}

	r.waveDataShaderModule, err = r.device.CreateShaderModule(&wgpu.ShaderModuleDescriptor{
		Label: "water wave-data/moments shader",
		WGSL:  shader.OceanWaveDataWGSL,
	})
	if err != nil {
		return fmt.Errorf("create water wave-data shader module: %w", err)
	}

	r.foamHistoryShaderModule, err = r.device.CreateShaderModule(&wgpu.ShaderModuleDescriptor{
		Label: "water temporal foam history shader",
		WGSL:  shader.OceanFoamHistoryWGSL,
	})
	if err != nil {
		return fmt.Errorf("create water temporal foam history shader module: %w", err)
	}

	r.variationShaderModule, err = r.device.CreateShaderModule(&wgpu.ShaderModuleDescriptor{
		Label: "water variation and foam-breakup shader",
		WGSL:  shader.OceanVariationWGSL,
	})
	if err != nil {
		return fmt.Errorf("create water variation shader module: %w", err)
	}
	r.interactionShaderModule, err = r.device.CreateShaderModule(&wgpu.ShaderModuleDescriptor{
		Label: "water ship interaction shader",
		WGSL:  shader.OceanInteractionWGSL,
	})
	if err != nil {
		return fmt.Errorf("create water interaction shader module: %w", err)
	}

	r.uniformBuffer, err = r.device.CreateBuffer(&wgpu.BufferDescriptor{
		Label: "water frame uniforms",
		Size:  waterFrameUniformSize,
		Usage: wgpu.BufferUsageUniform | wgpu.BufferUsageCopyDst,
	})
	if err != nil {
		return fmt.Errorf("create water uniform buffer: %w", err)
	}
	r.interactionUniformBuffer, err = r.device.CreateBuffer(&wgpu.BufferDescriptor{
		Label: "water interaction uniforms", Size: waterInteractionUniformSize,
		Usage: wgpu.BufferUsageUniform | wgpu.BufferUsageCopyDst,
	})
	if err != nil {
		return fmt.Errorf("create water interaction uniform buffer: %w", err)
	}

	r.h0ModeTexture, r.h0ModeView, err = r.createModeTexture("water persistent h0 spectral modes texture")
	if err != nil {
		return fmt.Errorf("create water h0 spectral modes texture: %w", err)
	}

	r.evolvedModeTexture, r.evolvedModeView, err = r.createModeTexture("water evolved height-dx modes texture")
	if err != nil {
		return fmt.Errorf("create water evolved height-dx modes texture: %w", err)
	}

	r.evolvedAuxModeTexture, r.evolvedAuxModeView, err = r.createModeTexture("water evolved dz-curvature modes texture")
	if err != nil {
		return fmt.Errorf("create water evolved dz-curvature modes texture: %w", err)
	}

	r.fftPingTexture, r.fftPingView, err = r.createModeTexture("water FFT primary ping texture")
	if err != nil {
		return fmt.Errorf("create water FFT primary ping texture: %w", err)
	}

	r.fftPongTexture, r.fftPongView, err = r.createModeTexture("water FFT primary pong texture")
	if err != nil {
		return fmt.Errorf("create water FFT primary pong texture: %w", err)
	}

	r.fftAuxPingTexture, r.fftAuxPingView, err = r.createModeTexture("water FFT auxiliary ping texture")
	if err != nil {
		return fmt.Errorf("create water FFT auxiliary ping texture: %w", err)
	}

	r.fftAuxPongTexture, r.fftAuxPongView, err = r.createModeTexture("water FFT auxiliary pong texture")
	if err != nil {
		return fmt.Errorf("create water FFT auxiliary pong texture: %w", err)
	}

	r.rawSpectrumTexture, r.rawSpectrumView, err = r.createSpectrumTexture("water raw spectrum field texture")
	if err != nil {
		return fmt.Errorf("create raw water spectrum texture: %w", err)
	}

	r.fieldSpectrumTexture, r.fieldSpectrumView, err = r.createSpectrumTexture("water filtered spectrum field texture")
	if err != nil {
		return fmt.Errorf("create filtered water spectrum texture: %w", err)
	}

	r.waveDataTexture, r.waveDataView, err = r.createSpectrumTexture("water wave-data moments texture")
	if err != nil {
		return fmt.Errorf("create water wave-data moments texture: %w", err)
	}

	r.foamHistoryTextureA, r.foamHistoryViewA, err = r.createSpectrumTexture("water temporal foam history A texture")
	if err != nil {
		return fmt.Errorf("create water temporal foam history A texture: %w", err)
	}

	r.foamHistoryTextureB, r.foamHistoryViewB, err = r.createSpectrumTexture("water temporal foam history B texture")
	if err != nil {
		return fmt.Errorf("create water temporal foam history B texture: %w", err)
	}

	r.variationTexture, r.variationView, err = r.createSpectrumTexture("water variation foam breakup texture")
	if err != nil {
		return fmt.Errorf("create water variation foam breakup texture: %w", err)
	}
	r.interactionTextureA, r.interactionViewA, err = r.createFloatTexture("water interaction field A", waterInteractionSize, waterInteractionSize, gputypes.TextureFormatRGBA16Float)
	if err != nil {
		return fmt.Errorf("create water interaction A: %w", err)
	}
	r.interactionTextureB, r.interactionViewB, err = r.createFloatTexture("water interaction field B", waterInteractionSize, waterInteractionSize, gputypes.TextureFormatRGBA16Float)
	if err != nil {
		return fmt.Errorf("create water interaction B: %w", err)
	}
	r.interactionSampler, err = r.device.CreateSampler(&wgpu.SamplerDescriptor{
		Label:        "water interaction linear clamp sampler",
		AddressModeU: gputypes.AddressModeClampToEdge,
		AddressModeV: gputypes.AddressModeClampToEdge,
		AddressModeW: gputypes.AddressModeClampToEdge,
		MagFilter:    gputypes.FilterModeLinear,
		MinFilter:    gputypes.FilterModeLinear,
		MipmapFilter: gputypes.FilterModeNearest,
		LodMinClamp:  0,
		LodMaxClamp:  0,
	})
	if err != nil {
		return fmt.Errorf("create water interaction sampler: %w", err)
	}

	r.renderBindGroupLayout, err = r.device.CreateBindGroupLayout(&wgpu.BindGroupLayoutDescriptor{
		Label: "water render bind group layout",
		Entries: []wgpu.BindGroupLayoutEntry{
			uniformLayoutEntry(wgpu.ShaderStageVertex | wgpu.ShaderStageFragment),
			sampledFloatTextureLayoutEntry(1, wgpu.ShaderStageVertex|wgpu.ShaderStageFragment),
			sampledFloatTextureLayoutEntry(2, wgpu.ShaderStageVertex|wgpu.ShaderStageFragment),
			sampledFloatTextureLayoutEntry(3, wgpu.ShaderStageVertex|wgpu.ShaderStageFragment),
			sampledFloatTextureLayoutEntry(4, wgpu.ShaderStageVertex|wgpu.ShaderStageFragment),
			sampledFloatTextureLayoutEntry(5, wgpu.ShaderStageVertex|wgpu.ShaderStageFragment),
			sampledFloatTextureLayoutEntry(6, wgpu.ShaderStageVertex|wgpu.ShaderStageFragment),
			sampledFilterableFloatTextureLayoutEntry(7, wgpu.ShaderStageVertex|wgpu.ShaderStageFragment),
			sampledFloatTextureLayoutEntry(8, wgpu.ShaderStageFragment),
			sampledFloatTextureLayoutEntry(9, wgpu.ShaderStageFragment),
			{Binding: 10, Visibility: wgpu.ShaderStageVertex | wgpu.ShaderStageFragment, Sampler: &gputypes.SamplerBindingLayout{Type: gputypes.SamplerBindingTypeFiltering}},
		},
	})
	if err != nil {
		return fmt.Errorf("create water render bind group layout: %w", err)
	}

	r.skyBindGroupLayout, err = r.device.CreateBindGroupLayout(&wgpu.BindGroupLayoutDescriptor{
		Label: "skybox render bind group layout",
		Entries: []wgpu.BindGroupLayoutEntry{
			uniformLayoutEntry(wgpu.ShaderStageVertex | wgpu.ShaderStageFragment),
		},
	})
	if err != nil {
		return fmt.Errorf("create skybox render bind group layout: %w", err)
	}

	r.initBindGroupLayout, err = r.device.CreateBindGroupLayout(&wgpu.BindGroupLayoutDescriptor{
		Label: "water h0 init bind group layout",
		Entries: []wgpu.BindGroupLayoutEntry{
			uniformLayoutEntry(wgpu.ShaderStageCompute),
			writeRGBA32StorageTextureLayoutEntry(1, wgpu.ShaderStageCompute),
		},
	})
	if err != nil {
		return fmt.Errorf("create water h0 init bind group layout: %w", err)
	}

	r.evolveBindGroupLayout, err = r.device.CreateBindGroupLayout(&wgpu.BindGroupLayoutDescriptor{
		Label: "water spectral vector evolution bind group layout",
		Entries: []wgpu.BindGroupLayoutEntry{
			uniformLayoutEntry(wgpu.ShaderStageCompute),
			sampledFilterableFloatTextureLayoutEntry(1, wgpu.ShaderStageCompute),
			writeFloatStorageTextureLayoutEntry(2, wgpu.ShaderStageCompute, gputypes.TextureFormatRGBA16Float),
			writeRGBA32StorageTextureLayoutEntry(3, wgpu.ShaderStageCompute),
		},
	})
	if err != nil {
		return fmt.Errorf("create water spectral evolution bind group layout: %w", err)
	}

	r.fftBindGroupLayout, err = r.device.CreateBindGroupLayout(&wgpu.BindGroupLayoutDescriptor{
		Label: "water staged inverse FFT bind group layout",
		Entries: []wgpu.BindGroupLayoutEntry{
			uniformLayoutEntry(wgpu.ShaderStageCompute),
			sampledFloatTextureLayoutEntry(1, wgpu.ShaderStageCompute),
			writeRGBA32StorageTextureLayoutEntry(2, wgpu.ShaderStageCompute),
		},
	})
	if err != nil {
		return fmt.Errorf("create water staged inverse FFT bind group layout: %w", err)
	}

	r.computeBindGroupLayout, err = r.device.CreateBindGroupLayout(&wgpu.BindGroupLayoutDescriptor{
		Label: "water FFT tile expansion bind group layout",
		Entries: []wgpu.BindGroupLayoutEntry{
			uniformLayoutEntry(wgpu.ShaderStageCompute),
			sampledFloatTextureLayoutEntry(1, wgpu.ShaderStageCompute),
			sampledFloatTextureLayoutEntry(2, wgpu.ShaderStageCompute),
			writeRGBA32StorageTextureLayoutEntry(3, wgpu.ShaderStageCompute),
		},
	})
	if err != nil {
		return fmt.Errorf("create water spatial inverse bind group layout: %w", err)
	}

	r.filterBindGroupLayout, err = r.device.CreateBindGroupLayout(&wgpu.BindGroupLayoutDescriptor{
		Label: "water spectrum filter bind group layout",
		Entries: []wgpu.BindGroupLayoutEntry{
			uniformLayoutEntry(wgpu.ShaderStageCompute),
			sampledFloatTextureLayoutEntry(1, wgpu.ShaderStageCompute),
			writeRGBA32StorageTextureLayoutEntry(2, wgpu.ShaderStageCompute),
		},
	})
	if err != nil {
		return fmt.Errorf("create water filter bind group layout: %w", err)
	}

	r.waveDataBindGroupLayout, err = r.device.CreateBindGroupLayout(&wgpu.BindGroupLayoutDescriptor{
		Label: "water wave-data bind group layout",
		Entries: []wgpu.BindGroupLayoutEntry{
			uniformLayoutEntry(wgpu.ShaderStageCompute),
			sampledFloatTextureLayoutEntry(1, wgpu.ShaderStageCompute),
			writeRGBA32StorageTextureLayoutEntry(2, wgpu.ShaderStageCompute),
		},
	})
	if err != nil {
		return fmt.Errorf("create water wave-data bind group layout: %w", err)
	}

	r.foamHistoryBindGroupLayout, err = r.device.CreateBindGroupLayout(&wgpu.BindGroupLayoutDescriptor{
		Label: "water temporal foam history bind group layout",
		Entries: []wgpu.BindGroupLayoutEntry{
			uniformLayoutEntry(wgpu.ShaderStageCompute),
			sampledFloatTextureLayoutEntry(1, wgpu.ShaderStageCompute),
			sampledFloatTextureLayoutEntry(2, wgpu.ShaderStageCompute),
			writeRGBA32StorageTextureLayoutEntry(3, wgpu.ShaderStageCompute),
		},
	})
	if err != nil {
		return fmt.Errorf("create water temporal foam history bind group layout: %w", err)
	}

	r.variationBindGroupLayout, err = r.device.CreateBindGroupLayout(&wgpu.BindGroupLayoutDescriptor{
		Label: "water variation foam-breakup bind group layout",
		Entries: []wgpu.BindGroupLayoutEntry{
			writeRGBA32StorageTextureLayoutEntry(0, wgpu.ShaderStageCompute),
		},
	})
	if err != nil {
		return fmt.Errorf("create water variation bind group layout: %w", err)
	}
	r.interactionBindGroupLayout, err = r.device.CreateBindGroupLayout(&wgpu.BindGroupLayoutDescriptor{
		Label: "water interaction bind group layout",
		Entries: []wgpu.BindGroupLayoutEntry{
			{Binding: 0, Visibility: wgpu.ShaderStageCompute, Buffer: &gputypes.BufferBindingLayout{Type: gputypes.BufferBindingTypeUniform, MinBindingSize: waterInteractionUniformSize}},
			sampledFloatTextureLayoutEntry(1, wgpu.ShaderStageCompute),
			writeRGBA32StorageTextureLayoutEntry(2, wgpu.ShaderStageCompute),
		},
	})
	if err != nil {
		return fmt.Errorf("create interaction bind group layout: %w", err)
	}

	r.renderPipelineLayout, err = r.device.CreatePipelineLayout(&wgpu.PipelineLayoutDescriptor{
		Label:            "water render pipeline layout",
		BindGroupLayouts: []*wgpu.BindGroupLayout{r.renderBindGroupLayout},
	})
	if err != nil {
		return fmt.Errorf("create water render pipeline layout: %w", err)
	}

	r.skyPipelineLayout, err = r.device.CreatePipelineLayout(&wgpu.PipelineLayoutDescriptor{
		Label:            "skybox render pipeline layout",
		BindGroupLayouts: []*wgpu.BindGroupLayout{r.skyBindGroupLayout},
	})
	if err != nil {
		return fmt.Errorf("create skybox render pipeline layout: %w", err)
	}

	r.initPipelineLayout, err = r.device.CreatePipelineLayout(&wgpu.PipelineLayoutDescriptor{
		Label:            "water h0 init pipeline layout",
		BindGroupLayouts: []*wgpu.BindGroupLayout{r.initBindGroupLayout},
	})
	if err != nil {
		return fmt.Errorf("create water h0 init pipeline layout: %w", err)
	}

	r.evolvePipelineLayout, err = r.device.CreatePipelineLayout(&wgpu.PipelineLayoutDescriptor{
		Label:            "water spectral vector evolution pipeline layout",
		BindGroupLayouts: []*wgpu.BindGroupLayout{r.evolveBindGroupLayout},
	})
	if err != nil {
		return fmt.Errorf("create water spectral evolution pipeline layout: %w", err)
	}

	r.fftPipelineLayout, err = r.device.CreatePipelineLayout(&wgpu.PipelineLayoutDescriptor{
		Label:            "water staged inverse FFT pipeline layout",
		BindGroupLayouts: []*wgpu.BindGroupLayout{r.fftBindGroupLayout},
	})
	if err != nil {
		return fmt.Errorf("create water staged inverse FFT pipeline layout: %w", err)
	}

	r.computePipelineLayout, err = r.device.CreatePipelineLayout(&wgpu.PipelineLayoutDescriptor{
		Label:            "water FFT tile expansion pipeline layout",
		BindGroupLayouts: []*wgpu.BindGroupLayout{r.computeBindGroupLayout},
	})
	if err != nil {
		return fmt.Errorf("create water spatial inverse pipeline layout: %w", err)
	}

	r.filterPipelineLayout, err = r.device.CreatePipelineLayout(&wgpu.PipelineLayoutDescriptor{
		Label:            "water spectrum filter pipeline layout",
		BindGroupLayouts: []*wgpu.BindGroupLayout{r.filterBindGroupLayout},
	})
	if err != nil {
		return fmt.Errorf("create water filter pipeline layout: %w", err)
	}

	r.waveDataPipelineLayout, err = r.device.CreatePipelineLayout(&wgpu.PipelineLayoutDescriptor{
		Label:            "water wave-data pipeline layout",
		BindGroupLayouts: []*wgpu.BindGroupLayout{r.waveDataBindGroupLayout},
	})
	if err != nil {
		return fmt.Errorf("create water wave-data pipeline layout: %w", err)
	}

	r.foamHistoryPipelineLayout, err = r.device.CreatePipelineLayout(&wgpu.PipelineLayoutDescriptor{
		Label:            "water temporal foam history pipeline layout",
		BindGroupLayouts: []*wgpu.BindGroupLayout{r.foamHistoryBindGroupLayout},
	})
	if err != nil {
		return fmt.Errorf("create water temporal foam history pipeline layout: %w", err)
	}

	r.variationPipelineLayout, err = r.device.CreatePipelineLayout(&wgpu.PipelineLayoutDescriptor{
		Label:            "water variation foam-breakup pipeline layout",
		BindGroupLayouts: []*wgpu.BindGroupLayout{r.variationBindGroupLayout},
	})
	if err != nil {
		return fmt.Errorf("create water variation pipeline layout: %w", err)
	}
	r.interactionPipelineLayout, err = r.device.CreatePipelineLayout(&wgpu.PipelineLayoutDescriptor{
		Label: "water interaction pipeline layout", BindGroupLayouts: []*wgpu.BindGroupLayout{r.interactionBindGroupLayout},
	})
	if err != nil {
		return fmt.Errorf("create interaction pipeline layout: %w", err)
	}

	r.initBindGroup, err = r.device.CreateBindGroup(&wgpu.BindGroupDescriptor{
		Label:  "water h0 init bind group",
		Layout: r.initBindGroupLayout,
		Entries: []wgpu.BindGroupEntry{
			{Binding: 0, Buffer: r.uniformBuffer, Size: waterFrameUniformSize},
			{Binding: 1, TextureView: r.h0ModeView},
		},
	})
	if err != nil {
		return fmt.Errorf("create water h0 init bind group: %w", err)
	}

	r.evolveBindGroup, err = r.device.CreateBindGroup(&wgpu.BindGroupDescriptor{
		Label:  "water spectral vector evolution bind group",
		Layout: r.evolveBindGroupLayout,
		Entries: []wgpu.BindGroupEntry{
			{Binding: 0, Buffer: r.uniformBuffer, Size: waterFrameUniformSize},
			{Binding: 1, TextureView: r.h0ModeView},
			{Binding: 2, TextureView: r.evolvedModeView},
			{Binding: 3, TextureView: r.evolvedAuxModeView},
		},
	})
	if err != nil {
		return fmt.Errorf("create water spectral evolution bind group: %w", err)
	}

	r.fftEvolvedToPingBindGroup, err = r.createFFTBindGroup("water FFT primary evolved-to-ping bind group", r.evolvedModeView, r.fftPingView)
	if err != nil {
		return fmt.Errorf("create water FFT primary evolved-to-ping bind group: %w", err)
	}

	r.fftPingToPongBindGroup, err = r.createFFTBindGroup("water FFT primary ping-to-pong bind group", r.fftPingView, r.fftPongView)
	if err != nil {
		return fmt.Errorf("create water FFT primary ping-to-pong bind group: %w", err)
	}

	r.fftPongToPingBindGroup, err = r.createFFTBindGroup("water FFT primary pong-to-ping bind group", r.fftPongView, r.fftPingView)
	if err != nil {
		return fmt.Errorf("create water FFT primary pong-to-ping bind group: %w", err)
	}

	r.fftAuxEvolvedToPingBindGroup, err = r.createFFTBindGroup("water FFT auxiliary evolved-to-ping bind group", r.evolvedAuxModeView, r.fftAuxPingView)
	if err != nil {
		return fmt.Errorf("create water FFT auxiliary evolved-to-ping bind group: %w", err)
	}

	r.fftAuxPingToPongBindGroup, err = r.createFFTBindGroup("water FFT auxiliary ping-to-pong bind group", r.fftAuxPingView, r.fftAuxPongView)
	if err != nil {
		return fmt.Errorf("create water FFT auxiliary ping-to-pong bind group: %w", err)
	}

	r.fftAuxPongToPingBindGroup, err = r.createFFTBindGroup("water FFT auxiliary pong-to-ping bind group", r.fftAuxPongView, r.fftAuxPingView)
	if err != nil {
		return fmt.Errorf("create water FFT auxiliary pong-to-ping bind group: %w", err)
	}

	r.computeBindGroup, err = r.device.CreateBindGroup(&wgpu.BindGroupDescriptor{
		Label:  "water FFT tile expansion bind group",
		Layout: r.computeBindGroupLayout,
		Entries: []wgpu.BindGroupEntry{
			{Binding: 0, Buffer: r.uniformBuffer, Size: waterFrameUniformSize},
			{Binding: 1, TextureView: r.fftPongView},
			{Binding: 2, TextureView: r.fftAuxPongView},
			{Binding: 3, TextureView: r.rawSpectrumView},
		},
	})
	if err != nil {
		return fmt.Errorf("create water spatial inverse bind group: %w", err)
	}

	r.filterBindGroup, err = r.device.CreateBindGroup(&wgpu.BindGroupDescriptor{
		Label:  "water spectrum filter bind group",
		Layout: r.filterBindGroupLayout,
		Entries: []wgpu.BindGroupEntry{
			{Binding: 0, Buffer: r.uniformBuffer, Size: waterFrameUniformSize},
			{Binding: 1, TextureView: r.rawSpectrumView},
			{Binding: 2, TextureView: r.fieldSpectrumView},
		},
	})
	if err != nil {
		return fmt.Errorf("create water filter bind group: %w", err)
	}

	r.waveDataBindGroup, err = r.device.CreateBindGroup(&wgpu.BindGroupDescriptor{
		Label:  "water wave-data bind group",
		Layout: r.waveDataBindGroupLayout,
		Entries: []wgpu.BindGroupEntry{
			{Binding: 0, Buffer: r.uniformBuffer, Size: waterFrameUniformSize},
			{Binding: 1, TextureView: r.fieldSpectrumView},
			{Binding: 2, TextureView: r.waveDataView},
		},
	})
	if err != nil {
		return fmt.Errorf("create water wave-data bind group: %w", err)
	}

	r.foamHistoryAToBGroup, err = r.createFoamHistoryBindGroup("water temporal foam history A-to-B bind group", r.foamHistoryViewA, r.foamHistoryViewB)
	if err != nil {
		return fmt.Errorf("create water temporal foam history A-to-B bind group: %w", err)
	}

	r.foamHistoryBToAGroup, err = r.createFoamHistoryBindGroup("water temporal foam history B-to-A bind group", r.foamHistoryViewB, r.foamHistoryViewA)
	if err != nil {
		return fmt.Errorf("create water temporal foam history B-to-A bind group: %w", err)
	}

	r.variationBindGroup, err = r.device.CreateBindGroup(&wgpu.BindGroupDescriptor{
		Label:  "water variation foam-breakup bind group",
		Layout: r.variationBindGroupLayout,
		Entries: []wgpu.BindGroupEntry{
			{Binding: 0, TextureView: r.variationView},
		},
	})
	if err != nil {
		return fmt.Errorf("create water variation bind group: %w", err)
	}
	r.interactionAToBGroup, err = r.createInteractionBindGroup("water interaction A-to-B", r.interactionViewA, r.interactionViewB)
	if err != nil {
		return fmt.Errorf("create interaction A-to-B group: %w", err)
	}
	r.interactionBToAGroup, err = r.createInteractionBindGroup("water interaction B-to-A", r.interactionViewB, r.interactionViewA)
	if err != nil {
		return fmt.Errorf("create interaction B-to-A group: %w", err)
	}

	r.skyBindGroup, err = r.device.CreateBindGroup(&wgpu.BindGroupDescriptor{
		Label:  "skybox render bind group",
		Layout: r.skyBindGroupLayout,
		Entries: []wgpu.BindGroupEntry{
			{Binding: 0, Buffer: r.uniformBuffer, Size: waterFrameUniformSize},
		},
	})
	if err != nil {
		return fmt.Errorf("create skybox render bind group: %w", err)
	}

	r.initPipeline, err = r.device.CreateComputePipeline(&wgpu.ComputePipelineDescriptor{
		Label:      "water h0 init pipeline",
		Layout:     r.initPipelineLayout,
		Module:     r.initShaderModule,
		EntryPoint: "cs_main",
	})
	if err != nil {
		return fmt.Errorf("create water h0 init pipeline: %w", err)
	}

	r.evolvePipeline, err = r.device.CreateComputePipeline(&wgpu.ComputePipelineDescriptor{
		Label:      "water spectral vector evolution pipeline",
		Layout:     r.evolvePipelineLayout,
		Module:     r.evolveShaderModule,
		EntryPoint: "cs_main",
	})
	if err != nil {
		return fmt.Errorf("create water spectral evolution pipeline: %w", err)
	}

	r.fftBitReverseHorizontalPipeline, err = r.device.CreateComputePipeline(&wgpu.ComputePipelineDescriptor{
		Label:      "water FFT horizontal bit-reversal pipeline",
		Layout:     r.fftPipelineLayout,
		Module:     r.fftShaderModule,
		EntryPoint: "cs_bitrev_h",
	})
	if err != nil {
		return fmt.Errorf("create water FFT horizontal bit-reversal pipeline: %w", err)
	}

	r.fftBitReverseVerticalPipeline, err = r.device.CreateComputePipeline(&wgpu.ComputePipelineDescriptor{
		Label:      "water FFT vertical bit-reversal pipeline",
		Layout:     r.fftPipelineLayout,
		Module:     r.fftShaderModule,
		EntryPoint: "cs_bitrev_v",
	})
	if err != nil {
		return fmt.Errorf("create water FFT vertical bit-reversal pipeline: %w", err)
	}

	for i, entry := range []string{"cs_stage_h0", "cs_stage_h1", "cs_stage_h2", "cs_stage_h3", "cs_stage_h4", "cs_stage_h5"} {
		r.fftHorizontalPipelines[i], err = r.device.CreateComputePipeline(&wgpu.ComputePipelineDescriptor{
			Label:      fmt.Sprintf("water FFT horizontal stage %d pipeline", i),
			Layout:     r.fftPipelineLayout,
			Module:     r.fftShaderModule,
			EntryPoint: entry,
		})
		if err != nil {
			return fmt.Errorf("create water FFT horizontal stage %d pipeline: %w", i, err)
		}
	}

	for i, entry := range []string{"cs_stage_v0", "cs_stage_v1", "cs_stage_v2", "cs_stage_v3", "cs_stage_v4", "cs_stage_v5"} {
		r.fftVerticalPipelines[i], err = r.device.CreateComputePipeline(&wgpu.ComputePipelineDescriptor{
			Label:      fmt.Sprintf("water FFT vertical stage %d pipeline", i),
			Layout:     r.fftPipelineLayout,
			Module:     r.fftShaderModule,
			EntryPoint: entry,
		})
		if err != nil {
			return fmt.Errorf("create water FFT vertical stage %d pipeline: %w", i, err)
		}
	}

	r.computePipeline, err = r.device.CreateComputePipeline(&wgpu.ComputePipelineDescriptor{
		Label:      "water FFT tile expansion pipeline",
		Layout:     r.computePipelineLayout,
		Module:     r.computeShaderModule,
		EntryPoint: "cs_main",
	})
	if err != nil {
		return fmt.Errorf("create water spatial inverse pipeline: %w", err)
	}

	r.filterPipeline, err = r.device.CreateComputePipeline(&wgpu.ComputePipelineDescriptor{
		Label:      "water spectrum filter pipeline",
		Layout:     r.filterPipelineLayout,
		Module:     r.filterShaderModule,
		EntryPoint: "cs_main",
	})
	if err != nil {
		return fmt.Errorf("create water filter pipeline: %w", err)
	}

	r.waveDataPipeline, err = r.device.CreateComputePipeline(&wgpu.ComputePipelineDescriptor{
		Label:      "water wave-data/moments pipeline",
		Layout:     r.waveDataPipelineLayout,
		Module:     r.waveDataShaderModule,
		EntryPoint: "cs_main",
	})
	if err != nil {
		return fmt.Errorf("create water wave-data pipeline: %w", err)
	}

	r.foamHistoryPipeline, err = r.device.CreateComputePipeline(&wgpu.ComputePipelineDescriptor{
		Label:      "water temporal foam history pipeline",
		Layout:     r.foamHistoryPipelineLayout,
		Module:     r.foamHistoryShaderModule,
		EntryPoint: "cs_main",
	})
	if err != nil {
		return fmt.Errorf("create water temporal foam history pipeline: %w", err)
	}

	r.foamHistoryClearPipeline, err = r.device.CreateComputePipeline(&wgpu.ComputePipelineDescriptor{
		Label:      "water temporal foam history clear pipeline",
		Layout:     r.foamHistoryPipelineLayout,
		Module:     r.foamHistoryShaderModule,
		EntryPoint: "cs_clear",
	})
	if err != nil {
		return fmt.Errorf("create water temporal foam history clear pipeline: %w", err)
	}

	r.shipRenderer, err = NewShipRenderer(r.device, r.surfaceFormat, DefaultShips())
	if err != nil {
		return fmt.Errorf("create ship renderer: %w", err)
	}

	r.variationPipeline, err = r.device.CreateComputePipeline(&wgpu.ComputePipelineDescriptor{
		Label:      "water variation foam-breakup pipeline",
		Layout:     r.variationPipelineLayout,
		Module:     r.variationShaderModule,
		EntryPoint: "cs_main",
	})
	if err != nil {
		return fmt.Errorf("create water variation pipeline: %w", err)
	}
	r.interactionPipeline, err = r.device.CreateComputePipeline(&wgpu.ComputePipelineDescriptor{
		Label: "water ship interaction pipeline", Layout: r.interactionPipelineLayout,
		Module: r.interactionShaderModule, EntryPoint: "cs_main",
	})
	if err != nil {
		return fmt.Errorf("create interaction pipeline: %w", err)
	}

	r.skyPipeline, err = r.createSkyPipeline(1)
	if err != nil {
		return err
	}
	r.skyPipelineMSAA, err = r.createSkyPipeline(4)
	if err != nil {
		return err
	}

	r.renderPipeline, err = r.createWaterPipeline(1)
	if err != nil {
		return err
	}
	r.renderPipelineMSAA, err = r.createWaterPipeline(4)
	if err != nil {
		return err
	}

	return nil
}

func (r *WaterRenderer) createSkyPipeline(sampleCount uint32) (*wgpu.RenderPipeline, error) {
	pipeline, err := r.device.CreateRenderPipeline(&wgpu.RenderPipelineDescriptor{
		Label:  fmt.Sprintf("procedural skybox pipeline %dx", sampleCount),
		Layout: r.skyPipelineLayout,
		Vertex: wgpu.VertexState{
			Module:     r.skyShaderModule,
			EntryPoint: "vs_main",
		},
		Primitive: wgpu.PrimitiveState{
			Topology:  gputypes.PrimitiveTopologyTriangleList,
			FrontFace: gputypes.FrontFaceCCW,
			CullMode:  gputypes.CullModeNone,
		},
		Multisample: gputypes.MultisampleState{Count: sampleCount, Mask: 0xFFFFFFFF},
		Fragment: &wgpu.FragmentState{
			Module:     r.skyShaderModule,
			EntryPoint: "fs_main",
			Targets: []wgpu.ColorTargetState{
				{
					Format:    r.surfaceFormat,
					WriteMask: gputypes.ColorWriteMaskAll,
				},
			},
		},
	})
	if err != nil {
		return nil, fmt.Errorf("create skybox %dx render pipeline: %w", sampleCount, err)
	}
	return pipeline, nil
}

func (r *WaterRenderer) createWaterPipeline(sampleCount uint32) (*wgpu.RenderPipeline, error) {
	blend := gputypes.BlendStateAlpha()
	pipeline, err := r.device.CreateRenderPipeline(&wgpu.RenderPipelineDescriptor{
		Label:  fmt.Sprintf("water projected-grid pipeline %dx", sampleCount),
		Layout: r.renderPipelineLayout,
		Vertex: wgpu.VertexState{
			Module:     r.shaderModule,
			EntryPoint: "vs_main",
		},
		Primitive: wgpu.PrimitiveState{
			Topology:  gputypes.PrimitiveTopologyTriangleList,
			FrontFace: gputypes.FrontFaceCCW,
			CullMode:  gputypes.CullModeNone,
		},
		Multisample: gputypes.MultisampleState{Count: sampleCount, Mask: 0xFFFFFFFF},
		Fragment: &wgpu.FragmentState{
			Module:     r.shaderModule,
			EntryPoint: "fs_main",
			Targets: []wgpu.ColorTargetState{
				{
					Format:    r.surfaceFormat,
					Blend:     &blend,
					WriteMask: gputypes.ColorWriteMaskAll,
				},
			},
		},
	})
	if err != nil {
		return nil, fmt.Errorf("create water %dx render pipeline: %w", sampleCount, err)
	}
	return pipeline, nil
}

func (r *WaterRenderer) createFFTBindGroup(label string, input, output *wgpu.TextureView) (*wgpu.BindGroup, error) {
	return r.device.CreateBindGroup(&wgpu.BindGroupDescriptor{
		Label:  label,
		Layout: r.fftBindGroupLayout,
		Entries: []wgpu.BindGroupEntry{
			{Binding: 0, Buffer: r.uniformBuffer, Size: waterFrameUniformSize},
			{Binding: 1, TextureView: input},
			{Binding: 2, TextureView: output},
		},
	})
}

func (r *WaterRenderer) createFoamHistoryBindGroup(label string, previous, output *wgpu.TextureView) (*wgpu.BindGroup, error) {
	return r.device.CreateBindGroup(&wgpu.BindGroupDescriptor{
		Label:  label,
		Layout: r.foamHistoryBindGroupLayout,
		Entries: []wgpu.BindGroupEntry{
			{Binding: 0, Buffer: r.uniformBuffer, Size: waterFrameUniformSize},
			{Binding: 1, TextureView: r.waveDataView},
			{Binding: 2, TextureView: previous},
			{Binding: 3, TextureView: output},
		},
	})
}

func (r *WaterRenderer) createInteractionBindGroup(label string, previous, output *wgpu.TextureView) (*wgpu.BindGroup, error) {
	return r.device.CreateBindGroup(&wgpu.BindGroupDescriptor{
		Label: label, Layout: r.interactionBindGroupLayout,
		Entries: []wgpu.BindGroupEntry{
			{Binding: 0, Buffer: r.interactionUniformBuffer, Size: waterInteractionUniformSize},
			{Binding: 1, TextureView: previous},
			{Binding: 2, TextureView: output},
		},
	})
}

func (r *WaterRenderer) createRenderBindGroup(label string, foamHistory, interaction *wgpu.TextureView) (*wgpu.BindGroup, error) {
	return r.device.CreateBindGroup(&wgpu.BindGroupDescriptor{
		Label:  label,
		Layout: r.renderBindGroupLayout,
		Entries: []wgpu.BindGroupEntry{
			{Binding: 0, Buffer: r.uniformBuffer, Size: waterFrameUniformSize},
			{Binding: 1, TextureView: r.fieldSpectrumView},
			{Binding: 2, TextureView: r.fftPongView},
			{Binding: 3, TextureView: r.fftAuxPongView},
			{Binding: 4, TextureView: r.waveDataView},
			{Binding: 5, TextureView: foamHistory},
			{Binding: 6, TextureView: r.variationView},
			{Binding: 7, TextureView: interaction},
			{Binding: 8, TextureView: r.reflectionView},
			{Binding: 9, TextureView: r.shadowView},
			{Binding: 10, Sampler: r.interactionSampler},
		},
	})
}

func dispatchWaterComputePass(encoder *wgpu.CommandEncoder, label string, pipeline *wgpu.ComputePipeline, bindGroup *wgpu.BindGroup, x, y, z uint32) error {
	pass, err := encoder.BeginComputePass(&wgpu.ComputePassDescriptor{
		Label: label,
	})
	if err != nil {
		return fmt.Errorf("begin %s: %w", label, err)
	}

	pass.SetPipeline(pipeline)
	pass.SetBindGroup(0, bindGroup, nil)
	pass.Dispatch(x, y, z)

	if err = pass.End(); err != nil {
		return fmt.Errorf("end %s: %w", label, err)
	}

	return nil
}

func (r *WaterRenderer) dispatchFFTChain(encoder *wgpu.CommandEncoder, label string, evolvedToPing, pingToPong, pongToPing *wgpu.BindGroup, x, y uint32) error {
	if err := dispatchWaterComputePass(encoder, label+" FFT horizontal bit-reversal pass", r.fftBitReverseHorizontalPipeline, evolvedToPing, x, y, 1); err != nil {
		return err
	}

	for i, pipeline := range r.fftHorizontalPipelines {
		bindGroup := pingToPong
		if i%2 == 1 {
			bindGroup = pongToPing
		}

		if err := dispatchWaterComputePass(encoder, fmt.Sprintf("%s FFT horizontal stage %d pass", label, i), pipeline, bindGroup, x, y, 1); err != nil {
			return err
		}
	}

	// Six horizontal stages leave the completed horizontal IFFT in ping. The
	// previous chain accidentally used pong as the input to vertical bit-reversal,
	// which meant the vertical FFT was operating on the stage-4 intermediate. That
	// produced smeared, weak, blocky water even though all passes were dispatching.
	if err := dispatchWaterComputePass(encoder, label+" FFT vertical bit-reversal pass", r.fftBitReverseVerticalPipeline, pingToPong, x, y, 1); err != nil {
		return err
	}

	for i, pipeline := range r.fftVerticalPipelines {
		bindGroup := pongToPing
		if i%2 == 1 {
			bindGroup = pingToPong
		}

		if err := dispatchWaterComputePass(encoder, fmt.Sprintf("%s FFT vertical stage %d pass", label, i), pipeline, bindGroup, x, y, 1); err != nil {
			return err
		}
	}

	return nil
}

func (r *WaterRenderer) ensureRenderTargets(width, height uint32) error {
	samples := uint32(1)
	if r.shipAA {
		samples = 4
	}
	if r.shipDepthView == nil || r.shipDepthWidth != width || r.shipDepthHeight != height || r.shipDepthSamples != samples {
		releaseTextureView(&r.shipDepthView)
		releaseTexture(&r.shipDepthTexture)
		releaseTextureView(&r.msaaColorView)
		releaseTexture(&r.msaaColorTexture)

		tex, err := r.device.CreateTexture(&wgpu.TextureDescriptor{
			Label: "ship depth texture", Size: wgpu.Extent3D{Width: width, Height: height, DepthOrArrayLayers: 1},
			MipLevelCount: 1, SampleCount: samples, Dimension: wgpu.TextureDimension2D,
			Format: shipDepthFormat, Usage: wgpu.TextureUsageRenderAttachment,
		})
		if err != nil {
			return fmt.Errorf("create ship depth texture: %w", err)
		}
		view, err := r.device.CreateTextureView(tex, nil)
		if err != nil {
			tex.Release()
			return fmt.Errorf("create ship depth view: %w", err)
		}
		r.shipDepthTexture, r.shipDepthView = tex, view
		r.shipDepthWidth, r.shipDepthHeight, r.shipDepthSamples = width, height, samples

		if samples > 1 {
			r.msaaColorTexture, err = r.device.CreateTexture(&wgpu.TextureDescriptor{
				Label: "water MSAA color texture", Size: wgpu.Extent3D{Width: width, Height: height, DepthOrArrayLayers: 1},
				MipLevelCount: 1, SampleCount: samples, Dimension: wgpu.TextureDimension2D,
				Format: r.surfaceFormat, Usage: wgpu.TextureUsageRenderAttachment,
			})
			if err != nil {
				return fmt.Errorf("create water MSAA color texture: %w", err)
			}
			r.msaaColorView, err = r.device.CreateTextureView(r.msaaColorTexture, nil)
			if err != nil {
				return fmt.Errorf("create water MSAA color view: %w", err)
			}
			r.msaaColorWidth, r.msaaColorHeight = width, height
		}
	}

	reflectionWidth, reflectionHeight := uint32(1), uint32(1)
	switch r.shipReflections {
	case ShipReflectionLow:
		reflectionWidth, reflectionHeight = max(width/4, 1), max(height/4, 1)
	case ShipReflectionMedium:
		reflectionWidth, reflectionHeight = max(width/2, 1), max(height/2, 1)
	case ShipReflectionHigh:
		reflectionWidth, reflectionHeight = width, height
	}
	shadowWidth, shadowHeight := uint32(1), uint32(1)
	if r.shipShadows {
		shadowWidth, shadowHeight = max(width/2, 1), max(height/2, 1)
	}
	targetsChanged := r.reflectionView == nil || r.shadowView == nil ||
		r.reflectionWidth != reflectionWidth || r.reflectionHeight != reflectionHeight ||
		r.shadowWidth != shadowWidth || r.shadowHeight != shadowHeight
	if targetsChanged {
		r.releaseWaterRenderBindGroups()
		r.releaseShipEffectTargets()

		var err error
		r.reflectionTexture, r.reflectionView, r.reflectionDepthTexture, r.reflectionDepthView, err =
			r.createShipEffectTarget("ship reflection", reflectionWidth, reflectionHeight)
		if err != nil {
			return err
		}
		r.reflectionWidth, r.reflectionHeight = reflectionWidth, reflectionHeight

		r.shadowTexture, r.shadowView, r.shadowDepthTexture, r.shadowDepthView, err =
			r.createShipEffectTarget("ship shadow", shadowWidth, shadowHeight)
		if err != nil {
			return err
		}
		r.shadowWidth, r.shadowHeight = shadowWidth, shadowHeight
	}
	if r.renderBindGroupAA == nil {
		if err := r.rebuildWaterRenderBindGroups(); err != nil {
			return err
		}
	}
	return nil
}

func (r *WaterRenderer) createShipEffectTarget(label string, width, height uint32) (*wgpu.Texture, *wgpu.TextureView, *wgpu.Texture, *wgpu.TextureView, error) {
	color, err := r.device.CreateTexture(&wgpu.TextureDescriptor{
		Label: label + " color texture", Size: wgpu.Extent3D{Width: width, Height: height, DepthOrArrayLayers: 1},
		MipLevelCount: 1, SampleCount: 1, Dimension: wgpu.TextureDimension2D, Format: shipEffectFormat,
		Usage: wgpu.TextureUsageRenderAttachment | wgpu.TextureUsageTextureBinding,
	})
	if err != nil {
		return nil, nil, nil, nil, fmt.Errorf("create %s color texture: %w", label, err)
	}
	colorView, err := r.device.CreateTextureView(color, nil)
	if err != nil {
		color.Release()
		return nil, nil, nil, nil, fmt.Errorf("create %s color view: %w", label, err)
	}
	depth, err := r.device.CreateTexture(&wgpu.TextureDescriptor{
		Label: label + " depth texture", Size: wgpu.Extent3D{Width: width, Height: height, DepthOrArrayLayers: 1},
		MipLevelCount: 1, SampleCount: 1, Dimension: wgpu.TextureDimension2D, Format: shipDepthFormat,
		Usage: wgpu.TextureUsageRenderAttachment,
	})
	if err != nil {
		colorView.Release()
		color.Release()
		return nil, nil, nil, nil, fmt.Errorf("create %s depth texture: %w", label, err)
	}
	depthView, err := r.device.CreateTextureView(depth, nil)
	if err != nil {
		depth.Release()
		colorView.Release()
		color.Release()
		return nil, nil, nil, nil, fmt.Errorf("create %s depth view: %w", label, err)
	}
	return color, colorView, depth, depthView, nil
}

func (r *WaterRenderer) rebuildWaterRenderBindGroups() error {
	r.releaseWaterRenderBindGroups()
	var err error
	r.renderBindGroupAA, err = r.createRenderBindGroup("water render foam A interaction A", r.foamHistoryViewA, r.interactionViewA)
	if err != nil {
		return fmt.Errorf("create water render bind group AA: %w", err)
	}
	r.renderBindGroupAB, err = r.createRenderBindGroup("water render foam A interaction B", r.foamHistoryViewA, r.interactionViewB)
	if err != nil {
		return fmt.Errorf("create water render bind group AB: %w", err)
	}
	r.renderBindGroupBA, err = r.createRenderBindGroup("water render foam B interaction A", r.foamHistoryViewB, r.interactionViewA)
	if err != nil {
		return fmt.Errorf("create water render bind group BA: %w", err)
	}
	r.renderBindGroupBB, err = r.createRenderBindGroup("water render foam B interaction B", r.foamHistoryViewB, r.interactionViewB)
	if err != nil {
		return fmt.Errorf("create water render bind group BB: %w", err)
	}
	return nil
}

func (r *WaterRenderer) releaseWaterRenderBindGroups() {
	releaseBindGroup(&r.renderBindGroupBB)
	releaseBindGroup(&r.renderBindGroupBA)
	releaseBindGroup(&r.renderBindGroupAB)
	releaseBindGroup(&r.renderBindGroupAA)
}

func (r *WaterRenderer) releaseShipEffectTargets() {
	releaseTextureView(&r.reflectionDepthView)
	releaseTexture(&r.reflectionDepthTexture)
	releaseTextureView(&r.reflectionView)
	releaseTexture(&r.reflectionTexture)
	releaseTextureView(&r.shadowDepthView)
	releaseTexture(&r.shadowDepthTexture)
	releaseTextureView(&r.shadowView)
	releaseTexture(&r.shadowTexture)
}

func selectResolveTarget(enabled bool, target *wgpu.TextureView) *wgpu.TextureView {
	if enabled {
		return target
	}
	return nil
}

func selectStoreOp(multisampled bool) wgpu.StoreOp {
	if multisampled {
		return gputypes.StoreOpDiscard
	}
	return gputypes.StoreOpStore
}

func (r *WaterRenderer) Draw(target *wgpu.TextureView, frame WaterFrame) error {
	if r == nil || r.device == nil {
		return fmt.Errorf("water renderer is not initialized")
	}
	frame.DebugMode = float32(r.debugMode)
	frame.WaveHeightScale = r.WaveHeightScale()

	if target == nil {
		return fmt.Errorf("nil water render target")
	}

	if frame.Width == 0 || frame.Height == 0 {
		return nil
	}
	if err := r.ensureRenderTargets(frame.Width, frame.Height); err != nil {
		return err
	}

	queue := r.device.Queue()
	if queue == nil {
		return fmt.Errorf("nil wgpu queue")
	}

	r.shipRenderer.UpdateMotion(frame.Time)
	originX, originZ := interactionFieldOrigin(r.shipRenderer)
	interactionDT := frame.Time - r.interactionLastTime
	runInteraction := !r.interactionInitialized || interactionDT >= waterInteractionStep
	if !runInteraction {
		// The texture remains expressed in the last simulated field coordinates.
		originX, originZ = r.interactionOriginX, r.interactionOriginZ
	}
	frame.InteractionOriginX = originX
	frame.InteractionOriginZ = originZ
	uniformBytes := packWaterFrame(frame)
	if err := queue.WriteBuffer(r.uniformBuffer, 0, uniformBytes); err != nil {
		return fmt.Errorf("write water uniforms: %w", err)
	}
	if !r.interactionInitialized || interactionDT <= 0 {
		interactionDT = 0
	} else if interactionDT > 0.10 {
		interactionDT = 0.10
	}
	prevX, prevZ := r.interactionOriginX, r.interactionOriginZ
	if !r.interactionInitialized {
		prevX, prevZ = originX+waterInteractionSpan*4, originZ+waterInteractionSpan*4
	}
	if runInteraction {
		if err := queue.WriteBuffer(r.interactionUniformBuffer, 0, packInteractionFrame(r.shipRenderer, originX, originZ, prevX, prevZ, frame.Time, interactionDT)); err != nil {
			return fmt.Errorf("write water interaction uniforms: %w", err)
		}
	}

	encoder, err := r.device.CreateCommandEncoder(&wgpu.CommandEncoderDescriptor{
		Label: "water frame encoder",
	})
	if err != nil {
		return fmt.Errorf("create water command encoder: %w", err)
	}

	didInitSpectrum := false
	didInitVariation := false
	if !r.variationInitialized {
		if err = dispatchWaterComputePass(encoder, "water variation foam-breakup init pass", r.variationPipeline, r.variationBindGroup, (waterSpectrumTextureSize+7)/8, (waterSpectrumTextureSize+7)/8, 1); err != nil {
			encoder.DiscardEncoding()
			return err
		}
		didInitVariation = true
	}

	if !r.spectrumInitialized {
		if err = dispatchWaterComputePass(encoder, "water h0 spectrum init pass", r.initPipeline, r.initBindGroup, (waterModeTextureSize+7)/8, (waterModeTextureSize*waterModeCascadeCount+7)/8, 1); err != nil {
			encoder.DiscardEncoding()
			return err
		}
		didInitSpectrum = true
	}

	if err = dispatchWaterComputePass(encoder, "water spectral vector evolution pass", r.evolvePipeline, r.evolveBindGroup, (waterModeTextureSize+7)/8, (waterModeTextureSize*waterModeCascadeCount+7)/8, 1); err != nil {
		encoder.DiscardEncoding()
		return err
	}

	modeDispatchX := (waterModeTextureSize + 7) / 8
	modeDispatchY := (waterModeTextureSize*waterModeCascadeCount + 7) / 8

	if err = r.dispatchFFTChain(encoder, "water primary height-dx", r.fftEvolvedToPingBindGroup, r.fftPingToPongBindGroup, r.fftPongToPingBindGroup, modeDispatchX, modeDispatchY); err != nil {
		encoder.DiscardEncoding()
		return err
	}

	if err = r.dispatchFFTChain(encoder, "water auxiliary dz-curvature", r.fftAuxEvolvedToPingBindGroup, r.fftAuxPingToPongBindGroup, r.fftAuxPongToPingBindGroup, modeDispatchX, modeDispatchY); err != nil {
		encoder.DiscardEncoding()
		return err
	}

	if err = dispatchWaterComputePass(encoder, "water FFT tile expansion pass", r.computePipeline, r.computeBindGroup, (waterSpectrumTextureSize+7)/8, (waterSpectrumTextureSize+7)/8, 1); err != nil {
		encoder.DiscardEncoding()
		return err
	}

	if err = dispatchWaterComputePass(encoder, "water spectrum filter pass", r.filterPipeline, r.filterBindGroup, (waterSpectrumTextureSize+7)/8, (waterSpectrumTextureSize+7)/8, 1); err != nil {
		encoder.DiscardEncoding()
		return err
	}

	if err = dispatchWaterComputePass(encoder, "water wave-data/moments pass", r.waveDataPipeline, r.waveDataBindGroup, (waterSpectrumTextureSize+7)/8, (waterSpectrumTextureSize+7)/8, 1); err != nil {
		encoder.DiscardEncoding()
		return err
	}

	if !r.foamHistoryInitialized {
		if err = dispatchWaterComputePass(encoder, "water temporal foam history clear B pass", r.foamHistoryClearPipeline, r.foamHistoryAToBGroup, (waterSpectrumTextureSize+7)/8, (waterSpectrumTextureSize+7)/8, 1); err != nil {
			encoder.DiscardEncoding()
			return err
		}
		if err = dispatchWaterComputePass(encoder, "water temporal foam history clear A pass", r.foamHistoryClearPipeline, r.foamHistoryBToAGroup, (waterSpectrumTextureSize+7)/8, (waterSpectrumTextureSize+7)/8, 1); err != nil {
			encoder.DiscardEncoding()
			return err
		}
	}

	foamHistoryBindGroup := r.foamHistoryAToBGroup
	renderFoamB := true
	if r.foamHistoryFlip {
		foamHistoryBindGroup = r.foamHistoryBToAGroup
		renderFoamB = false
	}

	if err = dispatchWaterComputePass(encoder, "water temporal foam history pass", r.foamHistoryPipeline, foamHistoryBindGroup, (waterSpectrumTextureSize+7)/8, (waterSpectrumTextureSize+7)/8, 1); err != nil {
		encoder.DiscardEncoding()
		return err
	}
	renderInteractionB := r.interactionFlip
	if runInteraction {
		interactionGroup := r.interactionAToBGroup
		renderInteractionB = true
		if r.interactionFlip {
			interactionGroup = r.interactionBToAGroup
			renderInteractionB = false
		}
		if err = dispatchWaterComputePass(encoder, "water ship interaction pass", r.interactionPipeline, interactionGroup, (waterInteractionSize+7)/8, (waterInteractionSize+7)/8, 1); err != nil {
			encoder.DiscardEncoding()
			return err
		}
	}

	reflectionPass, err := encoder.BeginRenderPass(&wgpu.RenderPassDescriptor{
		Label: "ship planar reflection pass",
		ColorAttachments: []wgpu.RenderPassColorAttachment{{
			View: r.reflectionView, LoadOp: gputypes.LoadOpClear, StoreOp: gputypes.StoreOpStore,
			ClearValue: gputypes.Color{R: 0, G: 0, B: 0, A: 0},
		}},
		DepthStencilAttachment: &wgpu.RenderPassDepthStencilAttachment{
			View: r.reflectionDepthView, DepthLoadOp: gputypes.LoadOpClear, DepthStoreOp: gputypes.StoreOpDiscard, DepthClearValue: 1.0,
		},
	})
	if err != nil {
		encoder.DiscardEncoding()
		return fmt.Errorf("begin ship reflection pass: %w", err)
	}
	if r.shipReflections != ShipReflectionOff {
		r.shipRenderer.DrawReflection(reflectionPass, frame)
	}
	if err = reflectionPass.End(); err != nil {
		encoder.DiscardEncoding()
		return fmt.Errorf("end ship reflection pass: %w", err)
	}

	shadowPass, err := encoder.BeginRenderPass(&wgpu.RenderPassDescriptor{
		Label: "ship projected shadow pass",
		ColorAttachments: []wgpu.RenderPassColorAttachment{{
			View: r.shadowView, LoadOp: gputypes.LoadOpClear, StoreOp: gputypes.StoreOpStore,
			ClearValue: gputypes.Color{R: 0, G: 0, B: 0, A: 0},
		}},
		DepthStencilAttachment: &wgpu.RenderPassDepthStencilAttachment{
			View: r.shadowDepthView, DepthLoadOp: gputypes.LoadOpClear, DepthStoreOp: gputypes.StoreOpDiscard, DepthClearValue: 1.0,
		},
	})
	if err != nil {
		encoder.DiscardEncoding()
		return fmt.Errorf("begin ship shadow pass: %w", err)
	}
	if r.shipShadows {
		r.shipRenderer.DrawShadow(shadowPass, frame)
	}
	if err = shadowPass.End(); err != nil {
		encoder.DiscardEncoding()
		return fmt.Errorf("end ship shadow pass: %w", err)
	}

	renderBindGroup := r.renderBindGroupAA
	if renderFoamB && renderInteractionB {
		renderBindGroup = r.renderBindGroupBB
	} else if renderFoamB {
		renderBindGroup = r.renderBindGroupBA
	} else if renderInteractionB {
		renderBindGroup = r.renderBindGroupAB
	}

	colorTarget := target
	skyPipeline := r.skyPipeline
	waterPipeline := r.renderPipeline
	if r.shipAA {
		colorTarget = r.msaaColorView
		skyPipeline = r.skyPipelineMSAA
		waterPipeline = r.renderPipelineMSAA
	}

	pass, err := encoder.BeginRenderPass(&wgpu.RenderPassDescriptor{
		Label: "water render pass",
		ColorAttachments: []wgpu.RenderPassColorAttachment{
			{
				View:       colorTarget,
				LoadOp:     gputypes.LoadOpClear,
				StoreOp:    gputypes.StoreOpStore,
				ClearValue: gputypes.Color{R: 0.11, G: 0.18, B: 0.22, A: 1.0},
			},
		},
	})
	if err != nil {
		encoder.DiscardEncoding()
		return fmt.Errorf("begin water render pass: %w", err)
	}

	pass.SetPipeline(skyPipeline)
	pass.SetBindGroup(0, r.skyBindGroup, nil)
	pass.Draw(3, 1, 0, 0)

	pass.SetPipeline(waterPipeline)
	pass.SetBindGroup(0, renderBindGroup, nil)
	pass.Draw(waterGridCells*waterGridCells*6, 1, 0, 0)

	if err = pass.End(); err != nil {
		encoder.DiscardEncoding()
		return fmt.Errorf("end water render pass: %w", err)
	}

	if r.shipRenderer != nil {
		shipPass, err := encoder.BeginRenderPass(&wgpu.RenderPassDescriptor{
			Label: "ship render pass",
			ColorAttachments: []wgpu.RenderPassColorAttachment{
				{
					View:          colorTarget,
					ResolveTarget: selectResolveTarget(r.shipAA, target),
					LoadOp:        gputypes.LoadOpLoad,
					StoreOp:       selectStoreOp(r.shipAA),
				},
			},
			DepthStencilAttachment: &wgpu.RenderPassDepthStencilAttachment{
				View:            r.shipDepthView,
				DepthLoadOp:     gputypes.LoadOpClear,
				DepthStoreOp:    gputypes.StoreOpStore,
				DepthClearValue: 1.0,
			},
		})
		if err != nil {
			encoder.DiscardEncoding()
			return fmt.Errorf("begin ship render pass: %w", err)
		}
		r.shipRenderer.Draw(shipPass, frame, r.shipAA)
		if err = shipPass.End(); err != nil {
			encoder.DiscardEncoding()
			return fmt.Errorf("end ship render pass: %w", err)
		}
	}

	cmd, err := encoder.Finish()
	if err != nil {
		return fmt.Errorf("finish water command buffer: %w", err)
	}

	if _, err = queue.Submit(cmd); err != nil {
		cmd.Release()
		return fmt.Errorf("submit water command buffer: %w", err)
	}

	if didInitVariation {
		r.variationInitialized = true
	}
	if didInitSpectrum {
		r.spectrumInitialized = true
	}
	r.foamHistoryInitialized = true
	r.foamHistoryFlip = !r.foamHistoryFlip
	if runInteraction {
		r.interactionInitialized = true
		r.interactionFlip = !r.interactionFlip
		r.interactionOriginX, r.interactionOriginZ = originX, originZ
		r.interactionLastTime = frame.Time
	}

	return nil
}

// CapturePNG renders one additional frame into a CPU-readable texture. It is
// intended for visual regression checks and is only called when explicitly
// enabled by the app's FFTWATER_CAPTURE_DIR environment variable.
func (r *WaterRenderer) CapturePNG(path string, frame WaterFrame) error {
	if r == nil || r.device == nil || frame.Width == 0 || frame.Height == 0 {
		return fmt.Errorf("cannot capture an uninitialized water frame")
	}

	texture, err := r.device.CreateTexture(&wgpu.TextureDescriptor{
		Label: "water screenshot target",
		Size: wgpu.Extent3D{
			Width:              frame.Width,
			Height:             frame.Height,
			DepthOrArrayLayers: 1,
		},
		MipLevelCount: 1,
		SampleCount:   1,
		Dimension:     wgpu.TextureDimension2D,
		Format:        r.surfaceFormat,
		Usage:         wgpu.TextureUsageRenderAttachment | wgpu.TextureUsageCopySrc,
	})
	if err != nil {
		return fmt.Errorf("create screenshot texture: %w", err)
	}
	defer texture.Release()

	view, err := r.device.CreateTextureView(texture, nil)
	if err != nil {
		return fmt.Errorf("create screenshot view: %w", err)
	}
	defer view.Release()

	if err = r.Draw(view, frame); err != nil {
		return fmt.Errorf("draw screenshot frame: %w", err)
	}

	bytesPerRow := (frame.Width*4 + 255) &^ 255
	bufferSize := uint64(bytesPerRow) * uint64(frame.Height)
	staging, err := r.device.CreateBuffer(&wgpu.BufferDescriptor{
		Label: "water screenshot readback",
		Size:  bufferSize,
		Usage: wgpu.BufferUsageCopyDst | wgpu.BufferUsageMapRead,
	})
	if err != nil {
		return fmt.Errorf("create screenshot readback buffer: %w", err)
	}
	defer staging.Release()

	encoder, err := r.device.CreateCommandEncoder(&wgpu.CommandEncoderDescriptor{Label: "water screenshot copy encoder"})
	if err != nil {
		return fmt.Errorf("create screenshot copy encoder: %w", err)
	}
	encoder.CopyTextureToBuffer(texture, staging, []wgpu.BufferTextureCopy{{
		BufferLayout: wgpu.ImageDataLayout{
			Offset:       0,
			BytesPerRow:  bytesPerRow,
			RowsPerImage: frame.Height,
		},
		TextureBase: wgpu.ImageCopyTexture{Texture: texture},
		Size: wgpu.Extent3D{
			Width:              frame.Width,
			Height:             frame.Height,
			DepthOrArrayLayers: 1,
		},
	}})
	cmd, err := encoder.Finish()
	if err != nil {
		return fmt.Errorf("finish screenshot copy: %w", err)
	}
	if _, err = r.device.Queue().Submit(cmd); err != nil {
		cmd.Release()
		return fmt.Errorf("submit screenshot copy: %w", err)
	}

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	if err = staging.Map(ctx, wgpu.MapModeRead, 0, bufferSize); err != nil {
		return fmt.Errorf("map screenshot buffer: %w", err)
	}
	defer staging.Unmap()

	mapped, err := staging.MappedRange(0, bufferSize)
	if err != nil {
		return fmt.Errorf("read screenshot buffer: %w", err)
	}
	defer mapped.Release()
	src := mapped.Bytes()
	img := image.NewRGBA(image.Rect(0, 0, int(frame.Width), int(frame.Height)))
	isBGRA := r.surfaceFormat == gputypes.TextureFormatBGRA8Unorm ||
		r.surfaceFormat == gputypes.TextureFormatBGRA8UnormSrgb
	for y := uint32(0); y < frame.Height; y++ {
		row := src[uint64(y)*uint64(bytesPerRow):]
		dst := img.Pix[int(y)*img.Stride:]
		for x := uint32(0); x < frame.Width; x++ {
			si := x * 4
			di := int(x * 4)
			if isBGRA {
				dst[di+0], dst[di+1], dst[di+2], dst[di+3] = row[si+2], row[si+1], row[si+0], row[si+3]
			} else {
				copy(dst[di:di+4], row[si:si+4])
			}
		}
	}

	if err = os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		return fmt.Errorf("create screenshot directory: %w", err)
	}
	file, err := os.Create(filepath.Clean(path))
	if err != nil {
		return fmt.Errorf("create screenshot file: %w", err)
	}
	if err = png.Encode(file, img); err != nil {
		_ = file.Close()
		return fmt.Errorf("encode screenshot: %w", err)
	}
	if err = file.Close(); err != nil {
		return fmt.Errorf("close screenshot: %w", err)
	}
	return nil
}

func packWaterFrame(frame WaterFrame) []byte {
	values := make([]float32, 0, int(waterFrameUniformSize/4))
	values = append(values,
		float32(frame.Width), float32(frame.Height), frame.Time, float32(waterGridCells),
	)
	values = append(values, frame.ViewProj[:]...)
	values = append(values,
		frame.CameraPosition.X, frame.CameraPosition.Y, frame.CameraPosition.Z, frame.TanHalfFOVY,
		frame.CameraRight.X, frame.CameraRight.Y, frame.CameraRight.Z, waterMaxDistance,
		frame.CameraUp.X, frame.CameraUp.Y, frame.CameraUp.Z, frame.Aspect,
		frame.CameraForward.X, frame.CameraForward.Y, frame.CameraForward.Z, 0.0,
		waterGridSnap, waterChopScale, waterFoamGain, waterDetailGain,
		frame.SpectrumOriginX, frame.SpectrumOriginZ, frame.SpectrumWorldSize, frame.SpectrumTextureDim,
		frame.DebugMode, frame.WaveHeightScale, frame.InteractionOriginX, frame.InteractionOriginZ,
	)
	return util.Float32Bytes(values...)
}

func interactionFieldOrigin(renderer *ShipRenderer) (float32, float32) {
	ships := renderer.Interactions()
	if len(ships) == 0 {
		return -waterInteractionSpan * 0.5, -waterInteractionSpan * 0.5
	}
	var centerX, centerZ, forwardX, forwardZ float32
	for _, ship := range ships {
		centerX += ship.Position.X
		centerZ += ship.Position.Z
		forwardX += ship.Forward.X
		forwardZ += ship.Forward.Z
	}
	invCount := 1 / float32(len(ships))
	centerX *= invCount
	centerZ *= invCount
	forwardX *= invCount
	forwardZ *= invCount
	forwardLength := float32(math.Hypot(float64(forwardX), float64(forwardZ)))
	if forwardLength > 0.001 {
		forwardX /= forwardLength
		forwardZ /= forwardLength
	}
	// Bias storage behind the fleet so the persistent field retains more of the
	// path already traveled. The shader only injects at each ship's current
	// hull/stern; this offset does not procedurally invent wake history.
	centerX -= forwardX * waterInteractionSpan * 0.20
	centerZ -= forwardZ * waterInteractionSpan * 0.20
	texel := waterInteractionSpan / float32(waterInteractionSize)
	originX := float32(math.Floor(float64((centerX-waterInteractionSpan*0.5)/texel))) * texel
	originZ := float32(math.Floor(float64((centerZ-waterInteractionSpan*0.5)/texel))) * texel
	return originX, originZ
}

func packInteractionFrame(renderer *ShipRenderer, originX, originZ, prevX, prevZ, time, dt float32) []byte {
	ships := renderer.Interactions()
	if len(ships) > 4 {
		ships = ships[:4]
	}
	values := make([]float32, 0, int(waterInteractionUniformSize/4))
	values = append(values, originX, originZ, waterInteractionSpan, dt)
	values = append(values, prevX, prevZ, time, float32(len(ships)))
	for i := 0; i < 4; i++ {
		if i < len(ships) {
			s := ships[i]
			values = append(values,
				s.Position.X, s.Position.Z, s.Speed, s.Strength,
				s.Forward.X, s.Forward.Z, s.Length, s.Beam,
				s.Draft, s.Propellers, s.Phase, 0,
			)
		} else {
			values = append(values, make([]float32, 12)...)
		}
	}
	return util.Float32Bytes(values...)
}

func releaseRenderPipeline(p **wgpu.RenderPipeline) {
	if *p != nil {
		(*p).Release()
		*p = nil
	}
}

func releaseComputePipeline(p **wgpu.ComputePipeline) {
	if *p != nil {
		(*p).Release()
		*p = nil
	}
}

func releaseBindGroup(bg **wgpu.BindGroup) {
	if *bg != nil {
		(*bg).Release()
		*bg = nil
	}
}

func releasePipelineLayout(pl **wgpu.PipelineLayout) {
	if *pl != nil {
		(*pl).Release()
		*pl = nil
	}
}

func releaseBindGroupLayout(bgl **wgpu.BindGroupLayout) {
	if *bgl != nil {
		(*bgl).Release()
		*bgl = nil
	}
}

func releaseTextureView(tv **wgpu.TextureView) {
	if *tv != nil {
		(*tv).Release()
		*tv = nil
	}
}

func releaseTexture(t **wgpu.Texture) {
	if *t != nil {
		(*t).Release()
		*t = nil
	}
}

func releaseBuffer(b **wgpu.Buffer) {
	if *b != nil {
		(*b).Release()
		*b = nil
	}
}

func releaseShaderModule(sm **wgpu.ShaderModule) {
	if *sm != nil {
		(*sm).Release()
		*sm = nil
	}
}

func (r *WaterRenderer) Release() {
	if r == nil {
		return
	}

	if r.shipRenderer != nil {
		r.shipRenderer.Release()
		r.shipRenderer = nil
	}
	releaseTextureView(&r.shipDepthView)
	releaseTexture(&r.shipDepthTexture)
	releaseTextureView(&r.msaaColorView)
	releaseTexture(&r.msaaColorTexture)

	releaseRenderPipeline(&r.renderPipelineMSAA)
	releaseRenderPipeline(&r.renderPipeline)
	releaseRenderPipeline(&r.skyPipelineMSAA)
	releaseRenderPipeline(&r.skyPipeline)
	releaseComputePipeline(&r.variationPipeline)
	releaseComputePipeline(&r.interactionPipeline)
	releaseComputePipeline(&r.foamHistoryClearPipeline)
	releaseComputePipeline(&r.foamHistoryPipeline)
	releaseComputePipeline(&r.waveDataPipeline)
	releaseComputePipeline(&r.filterPipeline)
	releaseComputePipeline(&r.computePipeline)
	for i := range r.fftVerticalPipelines {
		releaseComputePipeline(&r.fftVerticalPipelines[i])
	}
	for i := range r.fftHorizontalPipelines {
		releaseComputePipeline(&r.fftHorizontalPipelines[i])
	}
	releaseComputePipeline(&r.fftBitReverseVerticalPipeline)
	releaseComputePipeline(&r.fftBitReverseHorizontalPipeline)
	releaseComputePipeline(&r.evolvePipeline)
	releaseComputePipeline(&r.initPipeline)

	releaseBindGroup(&r.renderBindGroupBB)
	releaseBindGroup(&r.renderBindGroupBA)
	releaseBindGroup(&r.renderBindGroupAB)
	releaseBindGroup(&r.renderBindGroupAA)
	r.releaseShipEffectTargets()
	releaseBindGroup(&r.skyBindGroup)
	releaseBindGroup(&r.variationBindGroup)
	releaseBindGroup(&r.interactionBToAGroup)
	releaseBindGroup(&r.interactionAToBGroup)
	releaseBindGroup(&r.foamHistoryBToAGroup)
	releaseBindGroup(&r.foamHistoryAToBGroup)
	releaseBindGroup(&r.waveDataBindGroup)
	releaseBindGroup(&r.filterBindGroup)
	releaseBindGroup(&r.computeBindGroup)
	releaseBindGroup(&r.fftAuxPongToPingBindGroup)
	releaseBindGroup(&r.fftAuxPingToPongBindGroup)
	releaseBindGroup(&r.fftAuxEvolvedToPingBindGroup)
	releaseBindGroup(&r.fftPongToPingBindGroup)
	releaseBindGroup(&r.fftPingToPongBindGroup)
	releaseBindGroup(&r.fftEvolvedToPingBindGroup)
	releaseBindGroup(&r.evolveBindGroup)
	releaseBindGroup(&r.initBindGroup)

	releasePipelineLayout(&r.renderPipelineLayout)
	releasePipelineLayout(&r.skyPipelineLayout)
	releasePipelineLayout(&r.variationPipelineLayout)
	releasePipelineLayout(&r.interactionPipelineLayout)
	releasePipelineLayout(&r.foamHistoryPipelineLayout)
	releasePipelineLayout(&r.waveDataPipelineLayout)
	releasePipelineLayout(&r.filterPipelineLayout)
	releasePipelineLayout(&r.computePipelineLayout)
	releasePipelineLayout(&r.fftPipelineLayout)
	releasePipelineLayout(&r.evolvePipelineLayout)
	releasePipelineLayout(&r.initPipelineLayout)

	releaseBindGroupLayout(&r.renderBindGroupLayout)
	releaseBindGroupLayout(&r.skyBindGroupLayout)
	releaseBindGroupLayout(&r.variationBindGroupLayout)
	releaseBindGroupLayout(&r.interactionBindGroupLayout)
	releaseBindGroupLayout(&r.foamHistoryBindGroupLayout)
	releaseBindGroupLayout(&r.waveDataBindGroupLayout)
	releaseBindGroupLayout(&r.filterBindGroupLayout)
	releaseBindGroupLayout(&r.computeBindGroupLayout)
	releaseBindGroupLayout(&r.fftBindGroupLayout)
	releaseBindGroupLayout(&r.evolveBindGroupLayout)
	releaseBindGroupLayout(&r.initBindGroupLayout)

	releaseTextureView(&r.variationView)
	releaseTexture(&r.variationTexture)
	releaseTextureView(&r.interactionViewB)
	releaseTexture(&r.interactionTextureB)
	releaseTextureView(&r.interactionViewA)
	releaseTexture(&r.interactionTextureA)
	if r.interactionSampler != nil {
		r.interactionSampler.Release()
		r.interactionSampler = nil
	}
	releaseTextureView(&r.foamHistoryViewB)
	releaseTexture(&r.foamHistoryTextureB)
	releaseTextureView(&r.foamHistoryViewA)
	releaseTexture(&r.foamHistoryTextureA)
	releaseTextureView(&r.waveDataView)
	releaseTexture(&r.waveDataTexture)
	releaseTextureView(&r.fieldSpectrumView)
	releaseTexture(&r.fieldSpectrumTexture)
	releaseTextureView(&r.rawSpectrumView)
	releaseTexture(&r.rawSpectrumTexture)
	releaseTextureView(&r.fftAuxPongView)
	releaseTexture(&r.fftAuxPongTexture)
	releaseTextureView(&r.fftAuxPingView)
	releaseTexture(&r.fftAuxPingTexture)
	releaseTextureView(&r.fftPongView)
	releaseTexture(&r.fftPongTexture)
	releaseTextureView(&r.fftPingView)
	releaseTexture(&r.fftPingTexture)
	releaseTextureView(&r.evolvedAuxModeView)
	releaseTexture(&r.evolvedAuxModeTexture)
	releaseTextureView(&r.evolvedModeView)
	releaseTexture(&r.evolvedModeTexture)
	releaseTextureView(&r.h0ModeView)
	releaseTexture(&r.h0ModeTexture)

	releaseBuffer(&r.interactionUniformBuffer)
	releaseBuffer(&r.uniformBuffer)

	releaseShaderModule(&r.variationShaderModule)
	releaseShaderModule(&r.interactionShaderModule)
	releaseShaderModule(&r.foamHistoryShaderModule)
	releaseShaderModule(&r.waveDataShaderModule)
	releaseShaderModule(&r.filterShaderModule)
	releaseShaderModule(&r.computeShaderModule)
	releaseShaderModule(&r.fftShaderModule)
	releaseShaderModule(&r.evolveShaderModule)
	releaseShaderModule(&r.initShaderModule)
	releaseShaderModule(&r.skyShaderModule)
	releaseShaderModule(&r.shaderModule)
}
