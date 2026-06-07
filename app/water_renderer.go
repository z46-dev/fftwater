package app

import (
	"fmt"

	"github.com/gogpu/gputypes"
	"github.com/gogpu/wgpu"
	"github.com/z46-dev/fftwater/shader"
	"github.com/z46-dev/fftwater/util"
)

const (
	waterGridCells        uint32  = 192
	waterFrameUniformSize uint64  = 160
	waterMaxDistance      float32 = 1800.0
	waterGridSnap         float32 = 1.0
	waterChopScale        float32 = 1.0
	waterFoamGain         float32 = 1.0
	waterDetailGain       float32 = 1.0
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
}

func NewWaterFrame(width, height uint32, time, aspect float32, cam *WaterCamera) WaterFrame {
	if cam == nil {
		cam = NewWaterCamera()
	}

	forward, right, up := cam.Basis()
	return WaterFrame{
		Width:          width,
		Height:         height,
		Time:           time,
		Aspect:         aspect,
		TanHalfFOVY:    cam.TanHalfFOVY(),
		ViewProj:       cam.ViewProj(aspect),
		CameraPosition: cam.Position,
		CameraForward:  forward,
		CameraRight:    right,
		CameraUp:       up,
	}
}

// WaterRenderer owns the low-level WebGPU resources for the water pass.
// It stays in app for now because the renderer is still exploratory and should
// remain easy to patch while the shader model converges.
type WaterRenderer struct {
	device        *wgpu.Device
	surfaceFormat wgpu.TextureFormat

	shaderModule    *wgpu.ShaderModule
	uniformBuffer   *wgpu.Buffer
	bindGroupLayout *wgpu.BindGroupLayout
	pipelineLayout  *wgpu.PipelineLayout
	bindGroup       *wgpu.BindGroup
	pipeline        *wgpu.RenderPipeline
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

func (r *WaterRenderer) createResources() error {
	var err error

	r.shaderModule, err = r.device.CreateShaderModule(&wgpu.ShaderModuleDescriptor{
		Label: "water projected-grid shader",
		WGSL:  shader.WaterWGSL,
	})
	if err != nil {
		return fmt.Errorf("create water shader module: %w", err)
	}

	r.uniformBuffer, err = r.device.CreateBuffer(&wgpu.BufferDescriptor{
		Label: "water frame uniforms",
		Size:  waterFrameUniformSize,
		Usage: wgpu.BufferUsageUniform | wgpu.BufferUsageCopyDst,
	})
	if err != nil {
		return fmt.Errorf("create water uniform buffer: %w", err)
	}

	r.bindGroupLayout, err = r.device.CreateBindGroupLayout(&wgpu.BindGroupLayoutDescriptor{
		Label: "water frame bind group layout",
		Entries: []wgpu.BindGroupLayoutEntry{
			{
				Binding:    0,
				Visibility: wgpu.ShaderStageVertex | wgpu.ShaderStageFragment,
				Buffer: &gputypes.BufferBindingLayout{
					Type:           gputypes.BufferBindingTypeUniform,
					MinBindingSize: waterFrameUniformSize,
				},
			},
		},
	})
	if err != nil {
		return fmt.Errorf("create water bind group layout: %w", err)
	}

	r.pipelineLayout, err = r.device.CreatePipelineLayout(&wgpu.PipelineLayoutDescriptor{
		Label:            "water pipeline layout",
		BindGroupLayouts: []*wgpu.BindGroupLayout{r.bindGroupLayout},
	})
	if err != nil {
		return fmt.Errorf("create water pipeline layout: %w", err)
	}

	r.bindGroup, err = r.device.CreateBindGroup(&wgpu.BindGroupDescriptor{
		Label:  "water frame bind group",
		Layout: r.bindGroupLayout,
		Entries: []wgpu.BindGroupEntry{
			{
				Binding: 0,
				Buffer:  r.uniformBuffer,
				Size:    waterFrameUniformSize,
			},
		},
	})
	if err != nil {
		return fmt.Errorf("create water bind group: %w", err)
	}

	r.pipeline, err = r.device.CreateRenderPipeline(&wgpu.RenderPipelineDescriptor{
		Label:  "water projected-grid pipeline",
		Layout: r.pipelineLayout,
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

	pass.SetPipeline(r.pipeline)
	pass.SetBindGroup(0, r.bindGroup, nil)
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
	)
	return util.Float32Bytes(values...)
}

func (r *WaterRenderer) Release() {
	if r == nil {
		return
	}

	if r.pipeline != nil {
		r.pipeline.Release()
		r.pipeline = nil
	}

	if r.bindGroup != nil {
		r.bindGroup.Release()
		r.bindGroup = nil
	}

	if r.pipelineLayout != nil {
		r.pipelineLayout.Release()
		r.pipelineLayout = nil
	}

	if r.bindGroupLayout != nil {
		r.bindGroupLayout.Release()
		r.bindGroupLayout = nil
	}

	if r.uniformBuffer != nil {
		r.uniformBuffer.Release()
		r.uniformBuffer = nil
	}

	if r.shaderModule != nil {
		r.shaderModule.Release()
		r.shaderModule = nil
	}
}
