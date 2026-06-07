package app

import (
	"fmt"
	"math"

	"github.com/gogpu/gputypes"
	"github.com/gogpu/wgpu"
	"github.com/z46-dev/fftwater/shader"
	"github.com/z46-dev/fftwater/util"
)

const (
	waterGridCells           uint32  = 320
	waterSpectrumTextureSize uint32  = 512
	waterModeTextureSize     uint32  = 64
	waterModeCascadeCount    uint32  = 4
	waterFFTStageCount               = 6
	waterFrameUniformSize    uint64  = 176
	waterMaxDistance         float32 = 42000.0
	waterGridSnap            float32 = 0.5
	waterChopScale           float32 = 0.86
	waterFoamGain            float32 = 0.72
	waterDetailGain          float32 = 1.48
	waterSpectrumWorldSize   float32 = 4096.0
)

// WaterFrame contains the per-frame inputs for the projected water grid.
// The uniforms deliberately expose camera basis vectors instead of hiding the
// math behind screen-space tricks. That maps cleanly to the way large-ocean
// renderers usually build a projected grid: reconstruct a camera ray for each
// grid vertex, intersect that ray against the water plane, then displace and
// shade the resulting world-space position.
type WaterFrame struct {
	Width  uint32
	Height uint32
	Time   float32

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
		Time:               time,
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

	shaderModule        *wgpu.ShaderModule
	initShaderModule    *wgpu.ShaderModule
	evolveShaderModule  *wgpu.ShaderModule
	fftShaderModule     *wgpu.ShaderModule
	computeShaderModule *wgpu.ShaderModule
	filterShaderModule  *wgpu.ShaderModule

	uniformBuffer *wgpu.Buffer

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

	spectrumInitialized bool

	renderBindGroupLayout  *wgpu.BindGroupLayout
	initBindGroupLayout    *wgpu.BindGroupLayout
	evolveBindGroupLayout  *wgpu.BindGroupLayout
	fftBindGroupLayout     *wgpu.BindGroupLayout
	computeBindGroupLayout *wgpu.BindGroupLayout
	filterBindGroupLayout  *wgpu.BindGroupLayout

	renderPipelineLayout  *wgpu.PipelineLayout
	initPipelineLayout    *wgpu.PipelineLayout
	evolvePipelineLayout  *wgpu.PipelineLayout
	fftPipelineLayout     *wgpu.PipelineLayout
	computePipelineLayout *wgpu.PipelineLayout
	filterPipelineLayout  *wgpu.PipelineLayout

	renderBindGroup *wgpu.BindGroup
	initBindGroup   *wgpu.BindGroup
	evolveBindGroup *wgpu.BindGroup

	fftEvolvedToPingBindGroup *wgpu.BindGroup
	fftPingToPongBindGroup    *wgpu.BindGroup
	fftPongToPingBindGroup    *wgpu.BindGroup

	fftAuxEvolvedToPingBindGroup *wgpu.BindGroup
	fftAuxPingToPongBindGroup    *wgpu.BindGroup
	fftAuxPongToPingBindGroup    *wgpu.BindGroup

	computeBindGroup *wgpu.BindGroup
	filterBindGroup  *wgpu.BindGroup

	renderPipeline                  *wgpu.RenderPipeline
	initPipeline                    *wgpu.ComputePipeline
	evolvePipeline                  *wgpu.ComputePipeline
	fftBitReverseHorizontalPipeline *wgpu.ComputePipeline
	fftBitReverseVerticalPipeline   *wgpu.ComputePipeline
	fftHorizontalPipelines          [waterFFTStageCount]*wgpu.ComputePipeline
	fftVerticalPipelines            [waterFFTStageCount]*wgpu.ComputePipeline
	computePipeline                 *wgpu.ComputePipeline
	filterPipeline                  *wgpu.ComputePipeline
}

func NewWaterRenderer(device *wgpu.Device, surfaceFormat wgpu.TextureFormat) (*WaterRenderer, error) {
	if device == nil {
		return nil, fmt.Errorf("nil wgpu device")
	}

	r := &WaterRenderer{
		device:        device,
		surfaceFormat: surfaceFormat,
	}

	var err error
	if err = r.createResources(); err != nil {
		r.Release()
		return nil, err
	}

	return r, nil
}

func (r *WaterRenderer) createRGBA32FloatTexture(label string, width, height uint32) (*wgpu.Texture, *wgpu.TextureView, error) {
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
		Format:        gputypes.TextureFormatRGBA32Float,
		Usage:         wgpu.TextureUsageStorageBinding | wgpu.TextureUsageTextureBinding,
	})
	if err != nil {
		return nil, nil, err
	}

	view, err := r.device.CreateTextureView(tex, &wgpu.TextureViewDescriptor{
		Label:           label + " view",
		Format:          gputypes.TextureFormatRGBA32Float,
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

func writeRGBA32StorageTextureLayoutEntry(binding uint32, visibility wgpu.ShaderStages) wgpu.BindGroupLayoutEntry {
	return wgpu.BindGroupLayoutEntry{
		Binding:    binding,
		Visibility: visibility,
		StorageTexture: &gputypes.StorageTextureBindingLayout{
			Access:        gputypes.StorageTextureAccessWriteOnly,
			Format:        gputypes.TextureFormatRGBA32Float,
			ViewDimension: gputypes.TextureViewDimension2D,
		},
	}
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

	r.uniformBuffer, err = r.device.CreateBuffer(&wgpu.BufferDescriptor{
		Label: "water frame uniforms",
		Size:  waterFrameUniformSize,
		Usage: wgpu.BufferUsageUniform | wgpu.BufferUsageCopyDst,
	})
	if err != nil {
		return fmt.Errorf("create water uniform buffer: %w", err)
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

	r.renderBindGroupLayout, err = r.device.CreateBindGroupLayout(&wgpu.BindGroupLayoutDescriptor{
		Label: "water render bind group layout",
		Entries: []wgpu.BindGroupLayoutEntry{
			uniformLayoutEntry(wgpu.ShaderStageVertex | wgpu.ShaderStageFragment),
			sampledFloatTextureLayoutEntry(1, wgpu.ShaderStageVertex|wgpu.ShaderStageFragment),
		},
	})
	if err != nil {
		return fmt.Errorf("create water render bind group layout: %w", err)
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
			sampledFloatTextureLayoutEntry(1, wgpu.ShaderStageCompute),
			writeRGBA32StorageTextureLayoutEntry(2, wgpu.ShaderStageCompute),
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

	r.renderPipelineLayout, err = r.device.CreatePipelineLayout(&wgpu.PipelineLayoutDescriptor{
		Label:            "water render pipeline layout",
		BindGroupLayouts: []*wgpu.BindGroupLayout{r.renderBindGroupLayout},
	})
	if err != nil {
		return fmt.Errorf("create water render pipeline layout: %w", err)
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

	r.renderBindGroup, err = r.device.CreateBindGroup(&wgpu.BindGroupDescriptor{
		Label:  "water render bind group",
		Layout: r.renderBindGroupLayout,
		Entries: []wgpu.BindGroupEntry{
			{Binding: 0, Buffer: r.uniformBuffer, Size: waterFrameUniformSize},
			{Binding: 1, TextureView: r.fieldSpectrumView},
		},
	})
	if err != nil {
		return fmt.Errorf("create water render bind group: %w", err)
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

	r.renderPipeline, err = r.device.CreateRenderPipeline(&wgpu.RenderPipelineDescriptor{
		Label:  "water projected-grid pipeline",
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
		Multisample: gputypes.DefaultMultisampleState(),
		Fragment: &wgpu.FragmentState{
			Module:     r.shaderModule,
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
		return fmt.Errorf("create water render pipeline: %w", err)
	}

	return nil
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

func (r *WaterRenderer) Draw(target *wgpu.TextureView, frame WaterFrame) error {
	if r == nil || r.device == nil {
		return fmt.Errorf("water renderer is not initialized")
	}

	if target == nil {
		return fmt.Errorf("nil water render target")
	}

	if frame.Width == 0 || frame.Height == 0 {
		return nil
	}

	uniformBytes := packWaterFrame(frame)

	queue := r.device.Queue()
	if queue == nil {
		return fmt.Errorf("nil wgpu queue")
	}

	if err := queue.WriteBuffer(r.uniformBuffer, 0, uniformBytes); err != nil {
		return fmt.Errorf("write water uniforms: %w", err)
	}

	encoder, err := r.device.CreateCommandEncoder(&wgpu.CommandEncoderDescriptor{
		Label: "water frame encoder",
	})
	if err != nil {
		return fmt.Errorf("create water command encoder: %w", err)
	}

	didInitSpectrum := false
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

	pass, err := encoder.BeginRenderPass(&wgpu.RenderPassDescriptor{
		Label: "water render pass",
		ColorAttachments: []wgpu.RenderPassColorAttachment{
			{
				View:       target,
				LoadOp:     gputypes.LoadOpClear,
				StoreOp:    gputypes.StoreOpStore,
				ClearValue: gputypes.Color{R: 0.36, G: 0.50, B: 0.56, A: 1.0},
			},
		},
	})
	if err != nil {
		encoder.DiscardEncoding()
		return fmt.Errorf("begin water render pass: %w", err)
	}

	pass.SetPipeline(r.renderPipeline)
	pass.SetBindGroup(0, r.renderBindGroup, nil)
	pass.Draw(waterGridCells*waterGridCells*6, 1, 0, 0)

	if err = pass.End(); err != nil {
		encoder.DiscardEncoding()
		return fmt.Errorf("end water render pass: %w", err)
	}

	cmd, err := encoder.Finish()
	if err != nil {
		return fmt.Errorf("finish water command buffer: %w", err)
	}

	if _, err = queue.Submit(cmd); err != nil {
		cmd.Release()
		return fmt.Errorf("submit water command buffer: %w", err)
	}

	if didInitSpectrum {
		r.spectrumInitialized = true
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
	)
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

	releaseRenderPipeline(&r.renderPipeline)
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

	releaseBindGroup(&r.renderBindGroup)
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
	releasePipelineLayout(&r.filterPipelineLayout)
	releasePipelineLayout(&r.computePipelineLayout)
	releasePipelineLayout(&r.fftPipelineLayout)
	releasePipelineLayout(&r.evolvePipelineLayout)
	releasePipelineLayout(&r.initPipelineLayout)

	releaseBindGroupLayout(&r.renderBindGroupLayout)
	releaseBindGroupLayout(&r.filterBindGroupLayout)
	releaseBindGroupLayout(&r.computeBindGroupLayout)
	releaseBindGroupLayout(&r.fftBindGroupLayout)
	releaseBindGroupLayout(&r.evolveBindGroupLayout)
	releaseBindGroupLayout(&r.initBindGroupLayout)

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

	releaseBuffer(&r.uniformBuffer)

	releaseShaderModule(&r.filterShaderModule)
	releaseShaderModule(&r.computeShaderModule)
	releaseShaderModule(&r.fftShaderModule)
	releaseShaderModule(&r.evolveShaderModule)
	releaseShaderModule(&r.initShaderModule)
	releaseShaderModule(&r.shaderModule)
}
