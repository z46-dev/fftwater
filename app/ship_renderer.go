package app

import (
	"encoding/binary"
	"fmt"
	"math"
	"path/filepath"

	"github.com/gogpu/gputypes"
	"github.com/gogpu/wgpu"
	"github.com/z46-dev/fftwater/shader"
	"github.com/z46-dev/fftwater/util"
)

const (
	defaultShipWorldLength = float32(315.0)
	defaultShipSink        = float32(8.5)
	shipUniformSize        = uint64(256)
	shipMaxTextureSize     = uint32(1024)
)

type shipMaterialGPU struct {
	texture *wgpu.Texture
	view    *wgpu.TextureView
	bind    *wgpu.BindGroup
}

type shipDrawGPU struct {
	firstIndex uint32
	indexCount uint32
	material   int
}

type shipModelGPU struct {
	path         string
	vertexBuffer *wgpu.Buffer
	indexBuffer  *wgpu.Buffer
	materials    []shipMaterialGPU
	draws        []shipDrawGPU
	indexCount   uint32
}

// Ship is one configured model instance. GPU bindings are private renderer
// state; callers configure the model path and world-space fields.
type Ship struct {
	Name        string
	ModelPath   string
	Position    Vec3
	Heading     float32
	Length      float32
	Sink        float32
	MotionScale float32

	uniformBuffer    *wgpu.Buffer
	uniformBindGroup *wgpu.BindGroup
	model            int
}

func DefaultShips() []Ship {
	return []Ship{
		{Name: "Roosevelt", ModelPath: "assets/models/Roosevelt.glb", Position: Vec3{X: 0, Z: 30}, Heading: 0.0, Length: 315, Sink: 8.7, MotionScale: 0.72},
		{Name: "Shinano", ModelPath: "assets/models/Shinano.glb", Position: Vec3{X: -300, Z: -185}, Heading: 0.10, Length: 266, Sink: 8.8, MotionScale: 0.68},
		{Name: "Essex", ModelPath: "assets/models/Essex.glb", Position: Vec3{X: 310, Z: -245}, Heading: -0.12, Length: 266, Sink: 8.2, MotionScale: 0.70},
	}
}

type ShipRenderer struct {
	device *wgpu.Device
	queue  *wgpu.Queue

	shaderModule   *wgpu.ShaderModule
	pipeline       *wgpu.RenderPipeline
	pipelineMSAA   *wgpu.RenderPipeline
	pipelineLayout *wgpu.PipelineLayout
	uniformLayout  *wgpu.BindGroupLayout
	materialLayout *wgpu.BindGroupLayout

	sampler *wgpu.Sampler
	models  []shipModelGPU
	ships   []Ship
}

func NewShipRenderer(device *wgpu.Device, surfaceFormat wgpu.TextureFormat, ships []Ship) (*ShipRenderer, error) {
	if len(ships) == 0 {
		ships = DefaultShips()
	}
	r := &ShipRenderer{device: device, queue: device.Queue(), ships: append([]Ship(nil), ships...)}
	cpuModels := make([]*shipModelCPU, 0, len(r.ships))
	modelByPath := make(map[string]int, len(r.ships))
	for i := range r.ships {
		ship := &r.ships[i]
		if ship.ModelPath == "" {
			ship.ModelPath = "assets/models/Roosevelt.glb"
		}
		modelIndex, ok := modelByPath[ship.ModelPath]
		if !ok {
			cpu, err := loadShipGLB(ship.ModelPath)
			if err != nil {
				return nil, fmt.Errorf("load ship %q model %q: %w", ship.Name, ship.ModelPath, err)
			}
			modelIndex = len(cpuModels)
			modelByPath[ship.ModelPath] = modelIndex
			cpuModels = append(cpuModels, cpu)
		}
		ship.model = modelIndex
	}
	if err := r.createResources(surfaceFormat, cpuModels); err != nil {
		r.Release()
		return nil, err
	}
	return r, nil
}

func (r *ShipRenderer) createResources(surfaceFormat wgpu.TextureFormat, cpuModels []*shipModelCPU) error {
	var err error
	r.shaderModule, err = r.device.CreateShaderModule(&wgpu.ShaderModuleDescriptor{Label: "ship glb shader", WGSL: shader.ShipWGSL})
	if err != nil {
		return fmt.Errorf("create ship shader module: %w", err)
	}

	r.sampler, err = r.device.CreateSampler(&wgpu.SamplerDescriptor{Label: "ship base-color sampler", AddressModeU: gputypes.AddressModeRepeat, AddressModeV: gputypes.AddressModeRepeat, AddressModeW: gputypes.AddressModeRepeat, MagFilter: gputypes.FilterModeLinear, MinFilter: gputypes.FilterModeLinear, MipmapFilter: gputypes.FilterModeLinear, LodMinClamp: 0, LodMaxClamp: 12})
	if err != nil {
		return fmt.Errorf("create ship sampler: %w", err)
	}

	r.uniformLayout, err = r.device.CreateBindGroupLayout(&wgpu.BindGroupLayoutDescriptor{Label: "ship uniform layout", Entries: []wgpu.BindGroupLayoutEntry{uniformLayoutEntry(wgpu.ShaderStageVertex | wgpu.ShaderStageFragment)}})
	if err != nil {
		return fmt.Errorf("create ship uniform layout: %w", err)
	}
	r.materialLayout, err = r.device.CreateBindGroupLayout(&wgpu.BindGroupLayoutDescriptor{Label: "ship material layout", Entries: []wgpu.BindGroupLayoutEntry{
		{Binding: 0, Visibility: wgpu.ShaderStageFragment, Texture: &gputypes.TextureBindingLayout{SampleType: gputypes.TextureSampleTypeFloat, ViewDimension: gputypes.TextureViewDimension2D}},
		{Binding: 1, Visibility: wgpu.ShaderStageFragment, Sampler: &gputypes.SamplerBindingLayout{Type: gputypes.SamplerBindingTypeFiltering}},
	}})
	if err != nil {
		return fmt.Errorf("create ship material layout: %w", err)
	}
	r.pipelineLayout, err = r.device.CreatePipelineLayout(&wgpu.PipelineLayoutDescriptor{Label: "ship pipeline layout", BindGroupLayouts: []*wgpu.BindGroupLayout{r.uniformLayout, r.materialLayout}})
	if err != nil {
		return fmt.Errorf("create ship pipeline layout: %w", err)
	}
	for i := range r.ships {
		ship := &r.ships[i]
		if ship.Length <= 0 {
			ship.Length = defaultShipWorldLength
		}
		if ship.Sink <= 0 {
			ship.Sink = defaultShipSink
		}
		if ship.MotionScale <= 0 {
			ship.MotionScale = 1
		}
		label := fmt.Sprintf("ship %d %s uniforms", i, ship.Name)
		ship.uniformBuffer, err = r.device.CreateBuffer(&wgpu.BufferDescriptor{Label: label, Size: shipUniformSize, Usage: wgpu.BufferUsageUniform | wgpu.BufferUsageCopyDst})
		if err != nil {
			return fmt.Errorf("create %s: %w", label, err)
		}
		ship.uniformBindGroup, err = r.device.CreateBindGroup(&wgpu.BindGroupDescriptor{Label: label + " bind group", Layout: r.uniformLayout, Entries: []wgpu.BindGroupEntry{{Binding: 0, Buffer: ship.uniformBuffer, Size: shipUniformSize}}})
		if err != nil {
			return fmt.Errorf("create %s bind group: %w", label, err)
		}
	}

	r.models = make([]shipModelGPU, len(cpuModels))
	modelPaths := make([]string, len(cpuModels))
	for i := range r.ships {
		if r.ships[i].model >= 0 && r.ships[i].model < len(modelPaths) {
			modelPaths[r.ships[i].model] = r.ships[i].ModelPath
		}
	}
	for i, cpu := range cpuModels {
		model, err := r.createModelResources(modelPaths[i], cpu)
		if err != nil {
			return err
		}
		r.models[i] = model
	}

	r.pipeline, err = r.createPipeline(surfaceFormat, 1)
	if err != nil {
		return err
	}
	r.pipelineMSAA, err = r.createPipeline(surfaceFormat, 4)
	if err != nil {
		return err
	}
	return nil
}

func (r *ShipRenderer) createModelResources(path string, cpu *shipModelCPU) (shipModelGPU, error) {
	if cpu == nil {
		return shipModelGPU{}, fmt.Errorf("nil ship model for %q", path)
	}
	label := filepath.Base(path)
	model := shipModelGPU{path: path, indexCount: uint32(len(cpu.Indices))}
	var err error
	model.vertexBuffer, err = r.device.CreateBuffer(&wgpu.BufferDescriptor{Label: label + " vertices", Size: uint64(len(cpu.Vertices) * 4), Usage: wgpu.BufferUsageVertex | wgpu.BufferUsageCopyDst})
	if err != nil {
		return shipModelGPU{}, fmt.Errorf("create %s vertex buffer: %w", label, err)
	}
	model.indexBuffer, err = r.device.CreateBuffer(&wgpu.BufferDescriptor{Label: label + " indices", Size: uint64(len(cpu.Indices) * 4), Usage: wgpu.BufferUsageIndex | wgpu.BufferUsageCopyDst})
	if err != nil {
		model.release()
		return shipModelGPU{}, fmt.Errorf("create %s index buffer: %w", label, err)
	}
	if err = r.queue.WriteBuffer(model.vertexBuffer, 0, util.Float32Bytes(cpu.Vertices...)); err != nil {
		model.release()
		return shipModelGPU{}, fmt.Errorf("upload %s vertices: %w", label, err)
	}
	if err = r.queue.WriteBuffer(model.indexBuffer, 0, uint32SliceBytes(cpu.Indices)); err != nil {
		model.release()
		return shipModelGPU{}, fmt.Errorf("upload %s indices: %w", label, err)
	}

	fallback := shipImageCPU{RGBA: []byte{145, 148, 142, 255}, Width: 1, Height: 1}
	model.materials = make([]shipMaterialGPU, len(cpu.Materials))
	for i, mat := range cpu.Materials {
		img := fallback
		if mat.Image >= 0 && mat.Image < len(cpu.Images) && len(cpu.Images[mat.Image].RGBA) > 0 {
			img = cpu.Images[mat.Image]
		}
		model.materials[i], err = r.createMaterialTexture(fmt.Sprintf("%s material %d %s", label, i, mat.Name), img)
		if err != nil {
			model.release()
			return shipModelGPU{}, err
		}
	}
	if len(model.materials) == 0 {
		gpuMat, createErr := r.createMaterialTexture(label+" fallback material", fallback)
		if createErr != nil {
			model.release()
			return shipModelGPU{}, createErr
		}
		model.materials = []shipMaterialGPU{gpuMat}
	}
	model.draws = make([]shipDrawGPU, len(cpu.Draws))
	for i, d := range cpu.Draws {
		mat := d.Material
		if mat < 0 || mat >= len(model.materials) {
			mat = 0
		}
		model.draws[i] = shipDrawGPU{firstIndex: d.FirstIndex, indexCount: d.IndexCount, material: mat}
	}
	return model, nil
}

func (r *ShipRenderer) createPipeline(surfaceFormat wgpu.TextureFormat, sampleCount uint32) (*wgpu.RenderPipeline, error) {
	var blend *gputypes.BlendState
	alphaToCoverage := sampleCount > 1
	if !alphaToCoverage {
		// The 1x pipeline uses the shader's analytic waterline coverage directly.
		// The 4x pipeline instead converts that alpha to a multisample mask.
		b := gputypes.BlendStateAlpha()
		blend = &b
	}
	pipeline, err := r.device.CreateRenderPipeline(&wgpu.RenderPipelineDescriptor{
		Label: fmt.Sprintf("ship glb render pipeline %dx", sampleCount), Layout: r.pipelineLayout,
		Vertex:       wgpu.VertexState{Module: r.shaderModule, EntryPoint: "vs_main", Buffers: []gputypes.VertexBufferLayout{{ArrayStride: 32, StepMode: gputypes.VertexStepModeVertex, Attributes: []gputypes.VertexAttribute{{Format: gputypes.VertexFormatFloat32x3, Offset: 0, ShaderLocation: 0}, {Format: gputypes.VertexFormatFloat32x3, Offset: 12, ShaderLocation: 1}, {Format: gputypes.VertexFormatFloat32x2, Offset: 24, ShaderLocation: 2}}}}},
		Primitive:    wgpu.PrimitiveState{Topology: gputypes.PrimitiveTopologyTriangleList, FrontFace: gputypes.FrontFaceCCW, CullMode: gputypes.CullModeBack},
		DepthStencil: &wgpu.DepthStencilState{Format: gputypes.TextureFormatDepth32Float, DepthWriteEnabled: true, DepthCompare: gputypes.CompareFunctionLess},
		Multisample:  gputypes.MultisampleState{Count: sampleCount, Mask: 0xFFFFFFFF, AlphaToCoverageEnabled: alphaToCoverage},
		Fragment:     &wgpu.FragmentState{Module: r.shaderModule, EntryPoint: "fs_main", Targets: []wgpu.ColorTargetState{{Format: surfaceFormat, Blend: blend, WriteMask: gputypes.ColorWriteMaskAll}}},
	})
	if err != nil {
		return nil, fmt.Errorf("create ship %dx pipeline: %w", sampleCount, err)
	}
	return pipeline, nil
}

func (r *ShipRenderer) createMaterialTexture(label string, img shipImageCPU) (shipMaterialGPU, error) {
	mips := buildShipMipChain(img)
	for len(mips) > 1 && (mips[0].Width > shipMaxTextureSize || mips[0].Height > shipMaxTextureSize) {
		mips = mips[1:]
	}
	mipCount := uint32(len(mips))
	if mipCount == 0 {
		mips = []shipImageCPU{{RGBA: []byte{145, 148, 142, 255}, Width: 1, Height: 1}}
		mipCount = 1
	}

	tex, err := r.device.CreateTexture(&wgpu.TextureDescriptor{Label: label, Size: wgpu.Extent3D{Width: mips[0].Width, Height: mips[0].Height, DepthOrArrayLayers: 1}, MipLevelCount: mipCount, SampleCount: 1, Dimension: wgpu.TextureDimension2D, Format: gputypes.TextureFormatRGBA8Unorm, Usage: wgpu.TextureUsageTextureBinding | wgpu.TextureUsageCopyDst})
	if err != nil {
		return shipMaterialGPU{}, fmt.Errorf("create %s texture: %w", label, err)
	}
	view, err := r.device.CreateTextureView(tex, &wgpu.TextureViewDescriptor{Label: label + " view", Format: gputypes.TextureFormatRGBA8Unorm, Dimension: gputypes.TextureViewDimension2D, Aspect: gputypes.TextureAspectAll, BaseMipLevel: 0, MipLevelCount: mipCount, BaseArrayLayer: 0, ArrayLayerCount: 1})
	if err != nil {
		tex.Release()
		return shipMaterialGPU{}, fmt.Errorf("create %s view: %w", label, err)
	}
	for level, mip := range mips {
		if err := r.queue.WriteTexture(&wgpu.ImageCopyTexture{Texture: tex, MipLevel: uint32(level), Origin: wgpu.Origin3D{}, Aspect: gputypes.TextureAspectAll}, mip.RGBA, &wgpu.ImageDataLayout{Offset: 0, BytesPerRow: mip.Width * 4, RowsPerImage: mip.Height}, &wgpu.Extent3D{Width: mip.Width, Height: mip.Height, DepthOrArrayLayers: 1}); err != nil {
			view.Release()
			tex.Release()
			return shipMaterialGPU{}, fmt.Errorf("upload %s mip %d texture: %w", label, level, err)
		}
	}
	bind, err := r.device.CreateBindGroup(&wgpu.BindGroupDescriptor{Label: label + " bind group", Layout: r.materialLayout, Entries: []wgpu.BindGroupEntry{{Binding: 0, TextureView: view}, {Binding: 1, Sampler: r.sampler}}})
	if err != nil {
		view.Release()
		tex.Release()
		return shipMaterialGPU{}, fmt.Errorf("create %s bind group: %w", label, err)
	}
	return shipMaterialGPU{texture: tex, view: view, bind: bind}, nil
}

func buildShipMipChain(img shipImageCPU) []shipImageCPU {
	if len(img.RGBA) == 0 || img.Width == 0 || img.Height == 0 {
		return nil
	}
	mips := []shipImageCPU{img}
	for img.Width > 1 || img.Height > 1 {
		nextW := img.Width / 2
		nextH := img.Height / 2
		if nextW == 0 {
			nextW = 1
		}
		if nextH == 0 {
			nextH = 1
		}
		next := shipImageCPU{RGBA: make([]byte, int(nextW*nextH*4)), Width: nextW, Height: nextH}
		for y := uint32(0); y < nextH; y++ {
			for x := uint32(0); x < nextW; x++ {
				var r, g, b, a, n uint32
				for oy := uint32(0); oy < 2; oy++ {
					sy := y*2 + oy
					if sy >= img.Height {
						continue
					}
					for ox := uint32(0); ox < 2; ox++ {
						sx := x*2 + ox
						if sx >= img.Width {
							continue
						}
						si := int((sy*img.Width + sx) * 4)
						r += uint32(img.RGBA[si+0])
						g += uint32(img.RGBA[si+1])
						b += uint32(img.RGBA[si+2])
						a += uint32(img.RGBA[si+3])
						n++
					}
				}
				if n == 0 {
					n = 1
				}
				di := int((y*nextW + x) * 4)
				next.RGBA[di+0] = byte(r / n)
				next.RGBA[di+1] = byte(g / n)
				next.RGBA[di+2] = byte(b / n)
				next.RGBA[di+3] = byte(a / n)
			}
		}
		mips = append(mips, next)
		img = next
	}
	return mips
}

func (r *ShipRenderer) Draw(pass *wgpu.RenderPassEncoder, frame WaterFrame, multisampled bool) {
	if r == nil || pass == nil || r.pipeline == nil || len(r.models) == 0 || len(r.ships) == 0 {
		return
	}
	pipeline := r.pipeline
	if multisampled {
		pipeline = r.pipelineMSAA
	}
	pass.SetPipeline(pipeline)
	for i := range r.ships {
		ship := &r.ships[i]
		if ship.uniformBuffer == nil || ship.uniformBindGroup == nil || ship.model < 0 || ship.model >= len(r.models) {
			continue
		}
		model := &r.models[ship.model]
		if model.vertexBuffer == nil || model.indexBuffer == nil || model.indexCount == 0 {
			continue
		}
		if err := r.queue.WriteBuffer(ship.uniformBuffer, 0, r.uniformBytes(frame, *ship)); err != nil {
			continue
		}
		pass.SetVertexBuffer(0, model.vertexBuffer, 0)
		pass.SetIndexBuffer(model.indexBuffer, gputypes.IndexFormatUint32, 0)
		pass.SetBindGroup(0, ship.uniformBindGroup, nil)
		for _, d := range model.draws {
			if d.indexCount == 0 {
				continue
			}
			mat := d.material
			if mat < 0 || mat >= len(model.materials) {
				mat = 0
			}
			pass.SetBindGroup(1, model.materials[mat].bind, nil)
			pass.DrawIndexed(d.indexCount, 1, d.firstIndex, 0, 0)
		}
	}
}

func (r *ShipRenderer) uniformBytes(frame WaterFrame, ship Ship) []byte {
	model, normal := shipModelMatrices(frame.Time, ship)
	waterline := ship.Position.Y + sampleShipWater(ship.Position.X, ship.Position.Z, frame.Time)*ship.MotionScale - 0.90
	light := glbNormalize3([3]float32{-0.36, -0.78, -0.50})
	vals := make([]float32, 0, int(shipUniformSize/4))
	vals = append(vals, frame.ViewProj[:]...)
	vals = append(vals, model[:]...)
	vals = append(vals, normal[:]...)
	vals = append(vals, frame.CameraPosition.X, frame.CameraPosition.Y, frame.CameraPosition.Z, waterline)
	vals = append(vals, light[0], light[1], light[2], 0)
	for len(vals) < int(shipUniformSize/4) {
		vals = append(vals, 0)
	}
	return util.Float32Bytes(vals...)
}

func shipModelMatrices(t float32, ship Ship) (mat4f, mat4f) {
	x, z := ship.Position.X, ship.Position.Z
	length := ship.Length
	forwardX := float32(math.Sin(float64(ship.Heading)))
	forwardZ := float32(math.Cos(float64(ship.Heading)))
	rightX := forwardZ
	rightZ := -forwardX
	bow := sampleShipWater(x+forwardX*length*0.28, z+forwardZ*length*0.28, t)
	stern := sampleShipWater(x-forwardX*length*0.28, z-forwardZ*length*0.28, t)
	port := sampleShipWater(x-rightX*length*0.055, z-rightZ*length*0.055, t)
	star := sampleShipWater(x+rightX*length*0.055, z+rightZ*length*0.055, t)
	center := sampleShipWater(x, z, t)
	pitch := clamp32((bow-stern)/(length*0.56)*ship.MotionScale, -0.075, 0.075)
	roll := clamp32((star-port)/(length*0.11)*ship.MotionScale, -0.085, 0.085)
	yaw := ship.Heading
	translation := [3]float32{x, ship.Position.Y + center*ship.MotionScale - ship.Sink, z}
	return composeShipMatrix(translation, length, yaw, pitch, roll), composeShipNormalMatrix(yaw, pitch, roll)
}

func sampleShipWater(x, z, t float32) float32 {
	waves := [][4]float32{{0.010, 0.74, 0.68, 1.80}, {0.017, -0.28, 0.96, 1.05}, {0.029, 0.94, -0.34, 0.55}, {0.045, 0.42, 0.91, 0.22}}
	h := float32(0)
	for i, w := range waves {
		k, dx, dz, amp := w[0], w[1], w[2], w[3]
		phase := k*(x*dx+z*dz) - t*(0.35+float32(i)*0.17)
		h += float32(math.Sin(float64(phase))) * amp
	}
	return h
}

func composeShipMatrix(t [3]float32, s, yaw, pitch, roll float32) mat4f {
	cy, sy := float32(math.Cos(float64(yaw))), float32(math.Sin(float64(yaw)))
	cp, sp := float32(math.Cos(float64(pitch))), float32(math.Sin(float64(pitch)))
	cr, sr := float32(math.Cos(float64(roll))), float32(math.Sin(float64(roll)))
	// Column-major R = Ry * Rx * Rz, then uniform scale.
	m := mat4f{
		(cy*cr + sy*sp*sr) * s, (cp * sr) * s, (-sy*cr + cy*sp*sr) * s, 0,
		(-cy*sr + sy*sp*cr) * s, (cp * cr) * s, (sy*sr + cy*sp*cr) * s, 0,
		(sy * cp) * s, (-sp) * s, (cy * cp) * s, 0,
		t[0], t[1], t[2], 1,
	}
	return m
}
func composeShipNormalMatrix(yaw, pitch, roll float32) mat4f {
	return composeShipMatrix([3]float32{0, 0, 0}, 1, yaw, pitch, roll)
}
func ptrBlend(b gputypes.BlendState) *gputypes.BlendState { return &b }
func uint32SliceBytes(v []uint32) []byte {
	b := make([]byte, len(v)*4)
	for i, x := range v {
		binary.LittleEndian.PutUint32(b[i*4:], x)
	}
	return b
}

func (m *shipModelGPU) release() {
	if m == nil {
		return
	}
	if m.vertexBuffer != nil {
		m.vertexBuffer.Release()
		m.vertexBuffer = nil
	}
	if m.indexBuffer != nil {
		m.indexBuffer.Release()
		m.indexBuffer = nil
	}
	for i := range m.materials {
		if m.materials[i].bind != nil {
			m.materials[i].bind.Release()
			m.materials[i].bind = nil
		}
		if m.materials[i].view != nil {
			m.materials[i].view.Release()
			m.materials[i].view = nil
		}
		if m.materials[i].texture != nil {
			m.materials[i].texture.Release()
			m.materials[i].texture = nil
		}
	}
	m.materials = nil
	m.draws = nil
	m.indexCount = 0
}

func (r *ShipRenderer) Release() {
	if r == nil {
		return
	}
	if r.pipeline != nil {
		r.pipeline.Release()
		r.pipeline = nil
	}
	if r.pipelineMSAA != nil {
		r.pipelineMSAA.Release()
		r.pipelineMSAA = nil
	}
	if r.pipelineLayout != nil {
		r.pipelineLayout.Release()
		r.pipelineLayout = nil
	}
	for i := range r.ships {
		if r.ships[i].uniformBindGroup != nil {
			r.ships[i].uniformBindGroup.Release()
			r.ships[i].uniformBindGroup = nil
		}
		if r.ships[i].uniformBuffer != nil {
			r.ships[i].uniformBuffer.Release()
			r.ships[i].uniformBuffer = nil
		}
	}
	if r.uniformLayout != nil {
		r.uniformLayout.Release()
		r.uniformLayout = nil
	}
	if r.materialLayout != nil {
		r.materialLayout.Release()
		r.materialLayout = nil
	}
	for i := range r.models {
		r.models[i].release()
	}
	r.models = nil
	if r.sampler != nil {
		r.sampler.Release()
		r.sampler = nil
	}
	if r.shaderModule != nil {
		r.shaderModule.Release()
		r.shaderModule = nil
	}
}
