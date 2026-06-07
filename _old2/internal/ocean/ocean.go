package ocean

import (
	"fmt"
	"math"
	"os"
	"strconv"

	"github.com/gogpu/gputypes"
	"github.com/gogpu/wgpu"
	"github.com/z46-dev/fftwater/internal/camera"
	"github.com/z46-dev/fftwater/internal/gpu"
	"github.com/z46-dev/fftwater/internal/m3"
)

const (
	// The shaders now consume additional cascade and debug data, so keep a wider
	// packed block and leave room for future diagnostics without changing bind
	// sizes again.
	frameUniformSize uint64 = 512 // 128 float32s
)

const (
	oceanSampleSize        uint64  = 48
	waveLayerSampleSize    uint64  = 64
	foamLayerSampleSize    uint64  = 48
	opticalLayerSampleSize uint64  = 64
	spectrumSampleSize     uint64  = 32
	fftSampleSize          uint64  = 8
	fieldMapSampleSize     uint64  = 32
	spectrumResolution     uint32  = 128
	heightWorkgroupSize    uint32  = 64
	fftHeightScale         float32 = 320.0
	defaultSpectrumSeed    int64   = 42
)

type FrameUniforms struct {
	Data [128]float32
}

type Renderer struct {
	device                          *wgpu.Device
	vertexBuf, indexBuf, uniformBuf *wgpu.Buffer
	spectrumBuf                     *wgpu.Buffer
	fftABuf, fftBBuf                *wgpu.Buffer
	fieldMapBuf                     *wgpu.Buffer
	heightBuf                       *wgpu.Buffer
	waveLayerBuf                    *wgpu.Buffer
	foamLayerBuf                    *wgpu.Buffer
	opticalLayerBuf                 *wgpu.Buffer

	renderBindLayout  *wgpu.BindGroupLayout
	computeBindLayout *wgpu.BindGroupLayout
	renderBindGroup   *wgpu.BindGroup
	computeBindGroup  *wgpu.BindGroup

	renderPipeLayout  *wgpu.PipelineLayout
	computePipeLayout *wgpu.PipelineLayout
	skyPipeline       *wgpu.RenderPipeline
	renderPipeline    *wgpu.RenderPipeline

	evolveHeightPipeline  *wgpu.ComputePipeline
	evolveSlopeXPipeline  *wgpu.ComputePipeline
	evolveSlopeZPipeline  *wgpu.ComputePipeline
	evolveDispXPipeline   *wgpu.ComputePipeline
	evolveDispZPipeline   *wgpu.ComputePipeline
	fftRowsPipeline       *wgpu.ComputePipeline
	fftHeightColsPipeline *wgpu.ComputePipeline
	fftSlopeXColsPipeline *wgpu.ComputePipeline
	fftSlopeZColsPipeline *wgpu.ComputePipeline
	fftDispXColsPipeline  *wgpu.ComputePipeline
	fftDispZColsPipeline  *wgpu.ComputePipeline
	finalizePipeline      *wgpu.ComputePipeline

	tuning      OceanTuning
	spectrum    spectrumKey
	cascades    [cascadeCount]CascadeRuntime
	vertexCount uint32
	indexCount  uint32
	debugMode   float32

	frameIndex    uint64
	computeEveryN uint64

	hasOceanOrigin bool
	oceanOriginX   float32
	oceanOriginZ   float32
	lastOriginTime float32
}

// FrameUniformsFromCamera creates a packed uniform block consumed by:
//
//   - shaders/ocean_height_compute.wgsl
//   - shaders/ocean_render.wgsl
//   - shaders/sky.wgsl
func FrameUniformsFromCamera(cam *camera.Camera, aspect, timeSec float32) (u FrameUniforms) {
	var (
		proj     = m3.Perspective(60.0*float32(math.Pi)/180.0, aspect, 0.1, 3000.0)
		view     = cam.ViewMatrix()
		viewProj = m3.Mul(proj, view)

		worldUp = m3.NewVector3(0, 1, 0)
		forward = cam.Forward().Normalize()
		right   = m3.Cross(forward, worldUp).Normalize()
		up      = m3.Cross(right, forward).Normalize()
		sun     = m3.NewVector3(-0.38, 0.58, -0.72).Normalize()
	)

	copy(u.Data[0:16], viewProj[:])
	u.Data[16] = cam.Position.X
	u.Data[17] = cam.Position.Y
	u.Data[18] = cam.Position.Z
	u.Data[19] = aspect

	u.Data[20] = sun.X
	u.Data[21] = sun.Y
	u.Data[22] = sun.Z
	u.Data[23] = timeSec

	u.Data[24] = planeSize
	u.Data[25] = float32(planeResolution)
	u.Data[26] = float32(spectrumResolution)
	u.Data[27] = fftHeightScale

	u.Data[28] = right.X
	u.Data[29] = right.Y
	u.Data[30] = right.Z
	u.Data[31] = 0

	u.Data[32] = up.X
	u.Data[33] = up.Y
	u.Data[34] = up.Z
	u.Data[35] = 0

	u.Data[36] = forward.X
	u.Data[37] = forward.Y
	u.Data[38] = forward.Z
	u.Data[39] = 0

	return
}

func NewRenderer(dev *wgpu.Device, format gputypes.TextureFormat) (r *Renderer, err error) {
	tuning := DefaultOceanTuning().Clamped()
	r = &Renderer{
		device:        dev,
		tuning:        tuning,
		spectrum:      tuning.spectrumKey(),
		computeEveryN: 1,
		debugMode:     float32(readDebugModeEnv()),
	}

	mesh := GeneratePlaneMesh(planeSize, planeResolution)
	r.vertexCount = mesh.VertexCount
	r.indexCount = mesh.IndexCount

	if r.vertexBuf, err = dev.CreateBuffer(&wgpu.BufferDescriptor{
		Label: "ocean vertices",
		Size:  uint64(len(mesh.Vertices) * 4),
		Usage: wgpu.BufferUsageVertex | wgpu.BufferUsageCopyDst,
	}); err != nil {
		return
	}
	if err = dev.Queue().WriteBuffer(r.vertexBuf, 0, gpu.Float32Bytes(mesh.Vertices)); err != nil {
		return
	}

	if r.indexBuf, err = dev.CreateBuffer(&wgpu.BufferDescriptor{
		Label: "ocean indices",
		Size:  uint64(len(mesh.Indices) * 4),
		Usage: wgpu.BufferUsageIndex | wgpu.BufferUsageCopyDst,
	}); err != nil {
		return
	}
	if err = dev.Queue().WriteBuffer(r.indexBuf, 0, gpu.Uint32Bytes(mesh.Indices)); err != nil {
		return
	}

	if r.uniformBuf, err = dev.CreateBuffer(&wgpu.BufferDescriptor{
		Label: "frame uniforms",
		Size:  frameUniformSize,
		Usage: wgpu.BufferUsageUniform | wgpu.BufferUsageCopyDst,
	}); err != nil {
		return
	}

	totalCascadeSamples := uint64(cascadeCount) * uint64(spectrumResolution*spectrumResolution)
	heightBufSize := uint64(r.vertexCount) * oceanSampleSize
	waveLayerBufSize := uint64(r.vertexCount) * waveLayerSampleSize
	foamLayerBufSize := uint64(r.vertexCount) * foamLayerSampleSize
	opticalLayerBufSize := uint64(r.vertexCount) * opticalLayerSampleSize
	spectrumBufSize := totalCascadeSamples * spectrumSampleSize
	fftBufSize := totalCascadeSamples * fftSampleSize
	fieldMapSize := totalCascadeSamples * fieldMapSampleSize

	if r.heightBuf, err = dev.CreateBuffer(&wgpu.BufferDescriptor{
		Label: "ocean height samples",
		Size:  heightBufSize,
		Usage: wgpu.BufferUsageStorage,
	}); err != nil {
		return
	}

	if r.waveLayerBuf, err = dev.CreateBuffer(&wgpu.BufferDescriptor{
		Label: "water wave layer samples",
		Size:  waveLayerBufSize,
		Usage: wgpu.BufferUsageStorage,
	}); err != nil {
		return
	}

	if r.foamLayerBuf, err = dev.CreateBuffer(&wgpu.BufferDescriptor{
		Label: "water foam layer samples",
		Size:  foamLayerBufSize,
		Usage: wgpu.BufferUsageStorage,
	}); err != nil {
		return
	}

	if r.opticalLayerBuf, err = dev.CreateBuffer(&wgpu.BufferDescriptor{
		Label: "water optical layer samples",
		Size:  opticalLayerBufSize,
		Usage: wgpu.BufferUsageStorage,
	}); err != nil {
		return
	}

	if r.spectrumBuf, err = dev.CreateBuffer(&wgpu.BufferDescriptor{
		Label: "ocean initial spectrum",
		Size:  spectrumBufSize,
		Usage: wgpu.BufferUsageStorage | wgpu.BufferUsageCopyDst,
	}); err != nil {
		return
	}

	if r.fftABuf, err = dev.CreateBuffer(&wgpu.BufferDescriptor{
		Label: "ocean fft buffer a",
		Size:  fftBufSize,
		Usage: wgpu.BufferUsageStorage,
	}); err != nil {
		return
	}

	if r.fftBBuf, err = dev.CreateBuffer(&wgpu.BufferDescriptor{
		Label: "ocean fft buffer b",
		Size:  fftBufSize,
		Usage: wgpu.BufferUsageStorage,
	}); err != nil {
		return
	}

	if r.fieldMapBuf, err = dev.CreateBuffer(&wgpu.BufferDescriptor{
		Label: "ocean fft field map",
		Size:  fieldMapSize,
		Usage: wgpu.BufferUsageStorage,
	}); err != nil {
		return
	}

	if err = r.rebuildSpectrum(defaultSpectrumSeed); err != nil {
		return
	}

	if r.renderBindLayout, err = dev.CreateBindGroupLayout(&wgpu.BindGroupLayoutDescriptor{
		Entries: []wgpu.BindGroupLayoutEntry{
			{
				Binding:    0,
				Visibility: wgpu.ShaderStageVertex | wgpu.ShaderStageFragment,
				Buffer: &gputypes.BufferBindingLayout{
					Type:           gputypes.BufferBindingTypeUniform,
					MinBindingSize: frameUniformSize,
				},
			},
			{
				Binding:    1,
				Visibility: wgpu.ShaderStageVertex | wgpu.ShaderStageFragment,
				Buffer: &gputypes.BufferBindingLayout{
					Type:           gputypes.BufferBindingTypeReadOnlyStorage,
					MinBindingSize: heightBufSize,
				},
			},
			{
				Binding:    2,
				Visibility: wgpu.ShaderStageVertex | wgpu.ShaderStageFragment,
				Buffer: &gputypes.BufferBindingLayout{
					Type:           gputypes.BufferBindingTypeReadOnlyStorage,
					MinBindingSize: waveLayerBufSize,
				},
			},
			{
				Binding:    3,
				Visibility: wgpu.ShaderStageVertex | wgpu.ShaderStageFragment,
				Buffer: &gputypes.BufferBindingLayout{
					Type:           gputypes.BufferBindingTypeReadOnlyStorage,
					MinBindingSize: foamLayerBufSize,
				},
			},
			{
				Binding:    4,
				Visibility: wgpu.ShaderStageVertex | wgpu.ShaderStageFragment,
				Buffer: &gputypes.BufferBindingLayout{
					Type:           gputypes.BufferBindingTypeReadOnlyStorage,
					MinBindingSize: opticalLayerBufSize,
				},
			},
		},
	}); err != nil {
		return
	}

	if r.computeBindLayout, err = dev.CreateBindGroupLayout(&wgpu.BindGroupLayoutDescriptor{
		Entries: []wgpu.BindGroupLayoutEntry{
			{
				Binding:    0,
				Visibility: wgpu.ShaderStageCompute,
				Buffer: &gputypes.BufferBindingLayout{
					Type:           gputypes.BufferBindingTypeUniform,
					MinBindingSize: frameUniformSize,
				},
			},
			{
				Binding:    1,
				Visibility: wgpu.ShaderStageCompute,
				Buffer: &gputypes.BufferBindingLayout{
					Type:           gputypes.BufferBindingTypeStorage,
					MinBindingSize: heightBufSize,
				},
			},
			{
				Binding:    2,
				Visibility: wgpu.ShaderStageCompute,
				Buffer: &gputypes.BufferBindingLayout{
					Type:           gputypes.BufferBindingTypeReadOnlyStorage,
					MinBindingSize: spectrumBufSize,
				},
			},
			{
				Binding:    3,
				Visibility: wgpu.ShaderStageCompute,
				Buffer: &gputypes.BufferBindingLayout{
					Type:           gputypes.BufferBindingTypeStorage,
					MinBindingSize: fftBufSize,
				},
			},
			{
				Binding:    4,
				Visibility: wgpu.ShaderStageCompute,
				Buffer: &gputypes.BufferBindingLayout{
					Type:           gputypes.BufferBindingTypeStorage,
					MinBindingSize: fftBufSize,
				},
			},
			{
				Binding:    5,
				Visibility: wgpu.ShaderStageCompute,
				Buffer: &gputypes.BufferBindingLayout{
					Type:           gputypes.BufferBindingTypeStorage,
					MinBindingSize: fieldMapSize,
				},
			},
			{
				Binding:    6,
				Visibility: wgpu.ShaderStageCompute,
				Buffer: &gputypes.BufferBindingLayout{
					Type:           gputypes.BufferBindingTypeStorage,
					MinBindingSize: waveLayerBufSize,
				},
			},
			{
				Binding:    7,
				Visibility: wgpu.ShaderStageCompute,
				Buffer: &gputypes.BufferBindingLayout{
					Type:           gputypes.BufferBindingTypeStorage,
					MinBindingSize: foamLayerBufSize,
				},
			},
			{
				Binding:    8,
				Visibility: wgpu.ShaderStageCompute,
				Buffer: &gputypes.BufferBindingLayout{
					Type:           gputypes.BufferBindingTypeStorage,
					MinBindingSize: opticalLayerBufSize,
				},
			},
		},
	}); err != nil {
		return
	}

	if r.renderBindGroup, err = dev.CreateBindGroup(&wgpu.BindGroupDescriptor{
		Layout: r.renderBindLayout,
		Entries: []wgpu.BindGroupEntry{
			{Binding: 0, Buffer: r.uniformBuf, Size: frameUniformSize},
			{Binding: 1, Buffer: r.heightBuf, Size: heightBufSize},
			{Binding: 2, Buffer: r.waveLayerBuf, Size: waveLayerBufSize},
			{Binding: 3, Buffer: r.foamLayerBuf, Size: foamLayerBufSize},
			{Binding: 4, Buffer: r.opticalLayerBuf, Size: opticalLayerBufSize},
		},
	}); err != nil {
		return
	}

	if r.computeBindGroup, err = dev.CreateBindGroup(&wgpu.BindGroupDescriptor{
		Layout: r.computeBindLayout,
		Entries: []wgpu.BindGroupEntry{
			{Binding: 0, Buffer: r.uniformBuf, Size: frameUniformSize},
			{Binding: 1, Buffer: r.heightBuf, Size: heightBufSize},
			{Binding: 2, Buffer: r.spectrumBuf, Size: spectrumBufSize},
			{Binding: 3, Buffer: r.fftABuf, Size: fftBufSize},
			{Binding: 4, Buffer: r.fftBBuf, Size: fftBufSize},
			{Binding: 5, Buffer: r.fieldMapBuf, Size: fieldMapSize},
			{Binding: 6, Buffer: r.waveLayerBuf, Size: waveLayerBufSize},
			{Binding: 7, Buffer: r.foamLayerBuf, Size: foamLayerBufSize},
			{Binding: 8, Buffer: r.opticalLayerBuf, Size: opticalLayerBufSize},
		},
	}); err != nil {
		return
	}

	if r.renderPipeLayout, err = dev.CreatePipelineLayout(&wgpu.PipelineLayoutDescriptor{
		BindGroupLayouts: []*wgpu.BindGroupLayout{r.renderBindLayout},
	}); err != nil {
		return
	}

	if r.computePipeLayout, err = dev.CreatePipelineLayout(&wgpu.PipelineLayoutDescriptor{
		BindGroupLayouts: []*wgpu.BindGroupLayout{r.computeBindLayout},
	}); err != nil {
		return
	}

	var (
		renderShaderText  []byte
		skyShaderText     []byte
		computeShaderText []byte
		renderShader      *wgpu.ShaderModule
		skyShader         *wgpu.ShaderModule
		computeShader     *wgpu.ShaderModule
	)

	if renderShaderText, err = os.ReadFile("shaders/ocean_render.wgsl"); err != nil {
		return nil, fmt.Errorf("read render shader: %w", err)
	}
	if skyShaderText, err = os.ReadFile("shaders/sky.wgsl"); err != nil {
		return nil, fmt.Errorf("read sky shader: %w", err)
	}
	if computeShaderText, err = os.ReadFile("shaders/ocean_height_compute.wgsl"); err != nil {
		return nil, fmt.Errorf("read height compute shader: %w", err)
	}

	if renderShader, err = dev.CreateShaderModule(&wgpu.ShaderModuleDescriptor{WGSL: string(renderShaderText)}); err != nil {
		return
	}
	defer renderShader.Release()

	if skyShader, err = dev.CreateShaderModule(&wgpu.ShaderModuleDescriptor{WGSL: string(skyShaderText)}); err != nil {
		return
	}
	defer skyShader.Release()

	if computeShader, err = dev.CreateShaderModule(&wgpu.ShaderModuleDescriptor{WGSL: string(computeShaderText)}); err != nil {
		return
	}
	defer computeShader.Release()

	if r.evolveHeightPipeline, err = r.createComputePipeline(computeShader, "ocean evolve height pipeline", "evolve_height"); err != nil {
		return
	}
	if r.evolveSlopeXPipeline, err = r.createComputePipeline(computeShader, "ocean evolve slope x pipeline", "evolve_slope_x"); err != nil {
		return
	}
	if r.evolveSlopeZPipeline, err = r.createComputePipeline(computeShader, "ocean evolve slope z pipeline", "evolve_slope_z"); err != nil {
		return
	}
	if r.evolveDispXPipeline, err = r.createComputePipeline(computeShader, "ocean evolve displacement x pipeline", "evolve_disp_x"); err != nil {
		return
	}
	if r.evolveDispZPipeline, err = r.createComputePipeline(computeShader, "ocean evolve displacement z pipeline", "evolve_disp_z"); err != nil {
		return
	}
	if r.fftRowsPipeline, err = r.createComputePipeline(computeShader, "ocean fft rows pipeline", "fft_rows"); err != nil {
		return
	}
	if r.fftHeightColsPipeline, err = r.createComputePipeline(computeShader, "ocean fft height columns pipeline", "fft_height_columns"); err != nil {
		return
	}
	if r.fftSlopeXColsPipeline, err = r.createComputePipeline(computeShader, "ocean fft slope x columns pipeline", "fft_slope_x_columns"); err != nil {
		return
	}
	if r.fftSlopeZColsPipeline, err = r.createComputePipeline(computeShader, "ocean fft slope z columns pipeline", "fft_slope_z_columns"); err != nil {
		return
	}
	if r.fftDispXColsPipeline, err = r.createComputePipeline(computeShader, "ocean fft displacement x columns pipeline", "fft_displacement_x_columns"); err != nil {
		return
	}
	if r.fftDispZColsPipeline, err = r.createComputePipeline(computeShader, "ocean fft displacement z columns pipeline", "fft_displacement_z_columns"); err != nil {
		return
	}
	if r.finalizePipeline, err = r.createComputePipeline(computeShader, "ocean fft finalize pipeline", "finalize_samples"); err != nil {
		return
	}

	if r.skyPipeline, err = dev.CreateRenderPipeline(&wgpu.RenderPipelineDescriptor{
		Label:  "procedural sky render pipeline",
		Layout: r.renderPipeLayout,
		Vertex: wgpu.VertexState{
			Module:     skyShader,
			EntryPoint: "vs_main",
			Buffers:    nil,
		},
		Primitive: gputypes.PrimitiveState{
			Topology:  gputypes.PrimitiveTopologyTriangleList,
			FrontFace: gputypes.FrontFaceCCW,
			CullMode:  gputypes.CullModeNone,
		},
		Fragment: &wgpu.FragmentState{
			Module:     skyShader,
			EntryPoint: "fs_main",
			Targets: []gputypes.ColorTargetState{{
				Format:    format,
				WriteMask: gputypes.ColorWriteMaskAll,
			}},
		},
	}); err != nil {
		return
	}

	r.renderPipeline, err = dev.CreateRenderPipeline(&wgpu.RenderPipelineDescriptor{
		Label:  "fft ocean render pipeline",
		Layout: r.renderPipeLayout,
		Vertex: wgpu.VertexState{
			Module:     renderShader,
			EntryPoint: "vs_main",
			Buffers: []wgpu.VertexBufferLayout{{
				ArrayStride: vertexStride,
				StepMode:    gputypes.VertexStepModeVertex,
				Attributes: []gputypes.VertexAttribute{
					{Format: gputypes.VertexFormatFloat32x3, Offset: 0, ShaderLocation: 0},
					{Format: gputypes.VertexFormatFloat32x3, Offset: 12, ShaderLocation: 1},
					{Format: gputypes.VertexFormatFloat32x2, Offset: 24, ShaderLocation: 2},
				},
			}},
		},
		Primitive: gputypes.PrimitiveState{
			Topology:  gputypes.PrimitiveTopologyTriangleList,
			FrontFace: gputypes.FrontFaceCCW,
			CullMode:  gputypes.CullModeNone,
		},
		Fragment: &wgpu.FragmentState{
			Module:     renderShader,
			EntryPoint: "fs_main",
			Targets: []gputypes.ColorTargetState{{
				Format:    format,
				WriteMask: gputypes.ColorWriteMaskAll,
			}},
		},
	})

	return
}

func (r *Renderer) createComputePipeline(shader *wgpu.ShaderModule, label, entryPoint string) (*wgpu.ComputePipeline, error) {
	pipe, err := r.device.CreateComputePipeline(&wgpu.ComputePipelineDescriptor{
		Label:      label,
		Layout:     r.computePipeLayout,
		Module:     shader,
		EntryPoint: entryPoint,
	})
	if err != nil {
		return nil, fmt.Errorf("%s entry %q: %w", label, entryPoint, err)
	}
	return pipe, nil
}

func (r *Renderer) Tuning() OceanTuning {
	return r.tuning
}

func (r *Renderer) SetPreset(preset OceanPreset) error {
	return r.SetTuning(OceanTuningPreset(preset))
}

func (r *Renderer) SetTuning(tuning OceanTuning) error {
	tuning = tuning.Clamped()

	oldKey := r.spectrum
	newKey := tuning.spectrumKey()
	r.tuning = tuning

	if oldKey != newKey {
		r.spectrum = newKey
		return r.rebuildSpectrum(defaultSpectrumSeed)
	}

	return nil
}

func (r *Renderer) SetDebugMode(mode int) {
	if mode < 0 {
		mode = 0
	}
	if mode > 9 {
		mode = 9
	}
	r.debugMode = float32(mode)
}

// UpdateRuntimeTuning mutates runtime-only values without forcing a spectrum rebuild.
func (r *Renderer) UpdateRuntimeTuning(mutator func(*OceanTuning)) {
	if mutator == nil {
		return
	}

	t := r.tuning
	mutator(&t)

	t.WindSpeed = r.tuning.WindSpeed
	t.WindDirectionX = r.tuning.WindDirectionX
	t.WindDirectionZ = r.tuning.WindDirectionZ
	t.SpectrumScale = r.tuning.SpectrumScale
	t.ShortWaveDamping = r.tuning.ShortWaveDamping

	r.tuning = t.Clamped()
}

func (r *Renderer) SetComputeEveryN(n uint64) {
	if n == 0 {
		n = 1
	}
	r.computeEveryN = n
}

func (r *Renderer) rebuildSpectrum(seed int64) error {
	spectrum, cascades := GenerateInitialSpectrumSet(int(spectrumResolution), r.tuning.SpectrumConfig(seed))
	for i := range r.cascades {
		if i < len(cascades) {
			r.cascades[i] = cascades[i]
		} else {
			r.cascades[i] = CascadeRuntime{}
		}
	}
	return r.device.Queue().WriteBuffer(r.spectrumBuf, 0, gpu.Float32Bytes(spectrum))
}

func (r *Renderer) Draw(surfaceView *wgpu.TextureView, frame FrameUniforms) (err error) {
	r.packTuning(&frame)
	r.updateOceanOrigin(&frame)

	if err = r.device.Queue().WriteBuffer(r.uniformBuf, 0, gpu.Float32Bytes(frame.Data[:])); err != nil {
		return
	}

	var (
		enc *wgpu.CommandEncoder
		rp  *wgpu.RenderPassEncoder
	)

	if enc, err = r.device.CreateCommandEncoder(nil); err != nil {
		return
	}

	computeEvery := r.computeEveryN
	if computeEvery == 0 {
		computeEvery = 1
	}

	if r.frameIndex%computeEvery == 0 {
		if err = r.dispatchFFTField(enc, r.evolveHeightPipeline, r.fftHeightColsPipeline); err != nil {
			return
		}
		if err = r.dispatchFFTField(enc, r.evolveSlopeXPipeline, r.fftSlopeXColsPipeline); err != nil {
			return
		}
		if err = r.dispatchFFTField(enc, r.evolveSlopeZPipeline, r.fftSlopeZColsPipeline); err != nil {
			return
		}
		if err = r.dispatchFFTField(enc, r.evolveDispXPipeline, r.fftDispXColsPipeline); err != nil {
			return
		}
		if err = r.dispatchFFTField(enc, r.evolveDispZPipeline, r.fftDispZColsPipeline); err != nil {
			return
		}
		if err = r.dispatchCompute(enc, r.finalizePipeline, (r.vertexCount+heightWorkgroupSize-1)/heightWorkgroupSize, 1, 1); err != nil {
			return
		}
	}
	r.frameIndex++

	if rp, err = enc.BeginRenderPass(&wgpu.RenderPassDescriptor{
		ColorAttachments: []wgpu.RenderPassColorAttachment{{
			View:    surfaceView,
			LoadOp:  gputypes.LoadOpClear,
			StoreOp: gputypes.StoreOpStore,
			ClearValue: gputypes.Color{
				R: 0.54,
				G: 0.70,
				B: 0.82,
				A: 1.0,
			},
		}},
	}); err != nil {
		return
	}

	rp.SetPipeline(r.skyPipeline)
	rp.SetBindGroup(0, r.renderBindGroup, nil)
	rp.Draw(3, 1, 0, 0)

	rp.SetPipeline(r.renderPipeline)
	rp.SetBindGroup(0, r.renderBindGroup, nil)
	rp.SetVertexBuffer(0, r.vertexBuf, 0)
	rp.SetIndexBuffer(r.indexBuf, gputypes.IndexFormatUint32, 0)
	rp.DrawIndexed(r.indexCount, 1, 0, 0, 0)
	rp.End()

	var cmds *wgpu.CommandBuffer
	if cmds, err = enc.Finish(); err != nil {
		return
	}

	_, err = r.device.Queue().Submit(cmds)
	return
}

func (r *Renderer) packTuning(frame *FrameUniforms) {
	t := r.tuning.Clamped()

	frame.Data[40] = t.HeightScale
	frame.Data[41] = t.ChopScale
	frame.Data[42] = t.TimeScale
	frame.Data[43] = t.NormalDetailScale

	frame.Data[44] = t.FoamAmount
	frame.Data[45] = t.FoamThreshold
	frame.Data[46] = t.ReflectionAmount
	frame.Data[47] = t.Roughness

	frame.Data[48] = t.WindSpeed
	frame.Data[49] = t.WindDirectionX
	frame.Data[50] = t.WindDirectionZ
	frame.Data[51] = t.SpectrumScale

	frame.Data[52] = t.ShortWaveDamping
	frame.Data[53] = r.debugMode

	for i, cascade := range r.cascades {
		base := 56 + i*4
		frame.Data[base+0] = cascade.DomainSize
		frame.Data[base+1] = cascade.HeightWeight
		frame.Data[base+2] = cascade.SlopeWeight
		frame.Data[base+3] = cascade.ChopWeight
	}
	frame.Data[72] = cascadeCount
}

func (r *Renderer) updateOceanOrigin(frame *FrameUniforms) {
	// Keep the projected sea grid continuously camera-relative, but sample all waves
	// and material layers in absolute world coordinates. The previous 2m snapped
	// origin removed some LOD crawling, but it created visible material/normal pops
	// whenever the camera crossed a snap boundary. With the single projected grid,
	// continuous origin is now the lower-flicker choice.
	cameraX := frame.Data[16]
	cameraZ := frame.Data[18]

	r.oceanOriginX = cameraX
	r.oceanOriginZ = cameraZ
	r.hasOceanOrigin = true
	r.lastOriginTime = frame.Data[23]

	frame.Data[54] = r.oceanOriginX
	frame.Data[55] = r.oceanOriginZ
}

func (r *Renderer) dispatchFFTField(enc *wgpu.CommandEncoder, evolve, columns *wgpu.ComputePipeline) (err error) {
	totalSpectrum := uint32(cascadeCount) * spectrumResolution * spectrumResolution
	if err = r.dispatchCompute(enc, evolve, (totalSpectrum+heightWorkgroupSize-1)/heightWorkgroupSize, 1, 1); err != nil {
		return
	}
	if err = r.dispatchCompute(enc, r.fftRowsPipeline, 1, spectrumResolution, cascadeCount); err != nil {
		return
	}
	err = r.dispatchCompute(enc, columns, 1, spectrumResolution, cascadeCount)
	return
}

func (r *Renderer) dispatchCompute(enc *wgpu.CommandEncoder, pipeline *wgpu.ComputePipeline, x, y, z uint32) (err error) {
	var cp *wgpu.ComputePassEncoder

	if cp, err = enc.BeginComputePass(nil); err != nil {
		return
	}

	cp.SetPipeline(pipeline)
	cp.SetBindGroup(0, r.computeBindGroup, nil)
	cp.Dispatch(x, y, z)
	err = cp.End()
	return
}

func (r *Renderer) Release() {
	for _, resource := range []interface{ Release() }{
		r.finalizePipeline,
		r.fftDispZColsPipeline,
		r.fftDispXColsPipeline,
		r.fftSlopeZColsPipeline,
		r.fftSlopeXColsPipeline,
		r.fftHeightColsPipeline,
		r.fftRowsPipeline,
		r.evolveDispZPipeline,
		r.evolveDispXPipeline,
		r.evolveSlopeZPipeline,
		r.evolveSlopeXPipeline,
		r.evolveHeightPipeline,
		r.renderPipeline,
		r.skyPipeline,
		r.computePipeLayout,
		r.renderPipeLayout,
		r.computeBindGroup,
		r.renderBindGroup,
		r.computeBindLayout,
		r.renderBindLayout,
		r.opticalLayerBuf,
		r.foamLayerBuf,
		r.waveLayerBuf,
		r.fieldMapBuf,
		r.fftBBuf,
		r.fftABuf,
		r.spectrumBuf,
		r.heightBuf,
		r.uniformBuf,
		r.indexBuf,
		r.vertexBuf,
	} {
		if resource != nil {
			resource.Release()
		}
	}
}

func readDebugModeEnv() int {
	if raw := os.Getenv("FFT_OCEAN_DEBUG_MODE"); raw != "" {
		if v, err := strconv.Atoi(raw); err == nil {
			if v < 0 {
				return 0
			}
			if v > 9 {
				return 9
			}
			return v
		}
	}
	return 1
}
