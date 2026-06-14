package app

import (
	"bytes"
	"encoding/binary"
	"encoding/json"
	"fmt"
	"image"
	"image/draw"
	_ "image/png"
	"math"
	"os"
)

const (
	// Do not flip texture U.  The exported WoWS glb already has valid UV islands;
	// the apparent mirrored deck comes from coordinate handedness, not texture UVs.
	extractedWoWSFixMirroredU     = false
	extractedWoWSFixHandednessX   = true
	extractedWoWSRealtimeModelLOD = true
)

type glbAsset struct {
	Asset       map[string]any  `json:"asset"`
	Scene       int             `json:"scene"`
	Scenes      []glbScene      `json:"scenes"`
	Nodes       []glbNode       `json:"nodes"`
	Meshes      []glbMesh       `json:"meshes"`
	Materials   []glbMaterial   `json:"materials"`
	Textures    []glbTexture    `json:"textures"`
	Images      []glbImage      `json:"images"`
	Accessors   []glbAccessor   `json:"accessors"`
	BufferViews []glbBufferView `json:"bufferViews"`
	Buffers     []glbBuffer     `json:"buffers"`
}

type glbScene struct {
	Nodes []int `json:"nodes"`
}
type glbNode struct {
	Name        string    `json:"name"`
	Mesh        *int      `json:"mesh"`
	Children    []int     `json:"children"`
	Matrix      []float32 `json:"matrix"`
	Translation []float32 `json:"translation"`
	Rotation    []float32 `json:"rotation"`
	Scale       []float32 `json:"scale"`
}
type glbMesh struct {
	Name       string         `json:"name"`
	Primitives []glbPrimitive `json:"primitives"`
}
type glbPrimitive struct {
	Attributes map[string]int `json:"attributes"`
	Indices    *int           `json:"indices"`
	Material   *int           `json:"material"`
	Mode       int            `json:"mode"`
}
type glbMaterial struct {
	Name        string `json:"name"`
	DoubleSided bool   `json:"doubleSided"`
	PBR         glbPBR `json:"pbrMetallicRoughness"`
}
type glbPBR struct {
	BaseColorTexture *glbTextureRef `json:"baseColorTexture"`
	BaseColorFactor  []float32      `json:"baseColorFactor"`
	MetallicFactor   float32        `json:"metallicFactor"`
	RoughnessFactor  float32        `json:"roughnessFactor"`
}
type glbTextureRef struct {
	Index int `json:"index"`
}
type glbTexture struct {
	Sampler int `json:"sampler"`
	Source  int `json:"source"`
}
type glbImage struct {
	BufferView int    `json:"bufferView"`
	MIMEType   string `json:"mimeType"`
}
type glbBuffer struct {
	ByteLength int `json:"byteLength"`
}
type glbBufferView struct {
	Buffer     int `json:"buffer"`
	ByteOffset int `json:"byteOffset"`
	ByteLength int `json:"byteLength"`
	ByteStride int `json:"byteStride"`
	Target     int `json:"target"`
}
type glbAccessor struct {
	BufferView    int       `json:"bufferView"`
	ByteOffset    int       `json:"byteOffset"`
	ComponentType int       `json:"componentType"`
	Count         int       `json:"count"`
	Type          string    `json:"type"`
	Min           []float32 `json:"min"`
	Max           []float32 `json:"max"`
}

type shipVertexCPU struct {
	PX, PY, PZ float32
	NX, NY, NZ float32
	U, V       float32
}

type shipDrawCPU struct {
	Material   int
	FirstIndex uint32
	IndexCount uint32
}
type shipImageCPU struct {
	RGBA          []byte
	Width, Height uint32
}
type shipMaterialCPU struct {
	Name      string
	Image     int
	BaseColor [4]float32
}

type shipModelCPU struct {
	Vertices  []float32
	Indices   []uint32
	Draws     []shipDrawCPU
	Materials []shipMaterialCPU
	Images    []shipImageCPU
	BoundsMin [3]float32
	BoundsMax [3]float32
	Length    float32
}

type mat4f [16]float32

func loadShipGLB(path string) (*shipModelCPU, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	if len(data) < 20 || string(data[:4]) != "glTF" {
		return nil, fmt.Errorf("%s is not a binary glTF/glb", path)
	}
	version := binary.LittleEndian.Uint32(data[4:8])
	if version != 2 {
		return nil, fmt.Errorf("unsupported glb version %d", version)
	}

	off := 12
	var jsonChunk, binChunk []byte
	for off+8 <= len(data) {
		l := int(binary.LittleEndian.Uint32(data[off : off+4]))
		typ := string(data[off+4 : off+8])
		off += 8
		if off+l > len(data) {
			return nil, fmt.Errorf("truncated glb chunk")
		}
		chunk := data[off : off+l]
		off += l
		switch typ {
		case "JSON":
			jsonChunk = bytes.TrimRight(chunk, "\x00 \t\r\n")
		case "BIN\x00":
			binChunk = chunk
		}
	}
	if len(jsonChunk) == 0 || len(binChunk) == 0 {
		return nil, fmt.Errorf("glb is missing JSON or BIN chunk")
	}

	var gltf glbAsset
	if err := json.Unmarshal(jsonChunk, &gltf); err != nil {
		return nil, err
	}

	model := &shipModelCPU{}
	model.BoundsMin = [3]float32{float32(math.Inf(1)), float32(math.Inf(1)), float32(math.Inf(1))}
	model.BoundsMax = [3]float32{float32(math.Inf(-1)), float32(math.Inf(-1)), float32(math.Inf(-1))}

	model.Materials = make([]shipMaterialCPU, len(gltf.Materials))
	for i, mat := range gltf.Materials {
		m := shipMaterialCPU{Name: mat.Name, Image: -1, BaseColor: [4]float32{1, 1, 1, 1}}
		if len(mat.PBR.BaseColorFactor) >= 4 {
			copy(m.BaseColor[:], mat.PBR.BaseColorFactor[:4])
		}
		if mat.PBR.BaseColorTexture != nil && mat.PBR.BaseColorTexture.Index >= 0 && mat.PBR.BaseColorTexture.Index < len(gltf.Textures) {
			src := gltf.Textures[mat.PBR.BaseColorTexture.Index].Source
			if src >= 0 && src < len(gltf.Images) {
				m.Image = src
			}
		}
		model.Materials[i] = m
	}
	if len(model.Materials) == 0 {
		model.Materials = []shipMaterialCPU{{Name: "default", Image: -1, BaseColor: [4]float32{0.55, 0.55, 0.52, 1}}}
	}

	model.Images = make([]shipImageCPU, len(gltf.Images))
	for i, img := range gltf.Images {
		if img.BufferView < 0 || img.BufferView >= len(gltf.BufferViews) {
			continue
		}
		bv := gltf.BufferViews[img.BufferView]
		start, end := bv.ByteOffset, bv.ByteOffset+bv.ByteLength
		if start < 0 || end > len(binChunk) || start >= end {
			continue
		}
		decoded, _, err := image.Decode(bytes.NewReader(binChunk[start:end]))
		if err != nil {
			continue
		}
		b := decoded.Bounds()
		rgba := image.NewRGBA(image.Rect(0, 0, b.Dx(), b.Dy()))
		draw.Draw(rgba, rgba.Bounds(), decoded, b.Min, draw.Src)
		packed := make([]byte, rgba.Bounds().Dx()*rgba.Bounds().Dy()*4)
		for y := 0; y < rgba.Bounds().Dy(); y++ {
			copy(packed[y*rgba.Bounds().Dx()*4:(y+1)*rgba.Bounds().Dx()*4], rgba.Pix[y*rgba.Stride:y*rgba.Stride+rgba.Bounds().Dx()*4])
		}
		model.Images[i] = shipImageCPU{RGBA: packed, Width: uint32(rgba.Bounds().Dx()), Height: uint32(rgba.Bounds().Dy())}
	}

	scene := gltf.Scene
	if scene < 0 || scene >= len(gltf.Scenes) {
		scene = 0
	}
	identity := mat4Identity()
	if len(gltf.Scenes) == 0 {
		return nil, fmt.Errorf("glb has no scenes")
	}
	for _, nodeIdx := range gltf.Scenes[scene].Nodes {
		model.walkGLBNode(&gltf, binChunk, nodeIdx, identity)
	}

	// Normalize around centerline.  The renderer scales length back to ship-like
	// world meters.  This makes later GLBs usable without manual per-model scale.
	sx := model.BoundsMax[0] - model.BoundsMin[0]
	sy := model.BoundsMax[1] - model.BoundsMin[1]
	sz := model.BoundsMax[2] - model.BoundsMin[2]
	length := max32(sx, sz)
	if length <= 0 {
		length = 1
	}
	cx := (model.BoundsMin[0] + model.BoundsMax[0]) * 0.5
	cz := (model.BoundsMin[2] + model.BoundsMax[2]) * 0.5
	minY := model.BoundsMin[1]
	for i := 0; i+7 < len(model.Vertices); i += 8 {
		x := (model.Vertices[i+0] - cx) / length
		if extractedWoWSFixHandednessX {
			x = -x
			model.Vertices[i+3] = -model.Vertices[i+3]
		}
		model.Vertices[i+0] = x
		model.Vertices[i+1] = (model.Vertices[i+1] - minY) / length
		model.Vertices[i+2] = (model.Vertices[i+2] - cz) / length
	}
	model.optimizeDrawsByMaterial()
	model.Length = 1.0
	_ = sy
	return model, nil
}

func (m *shipModelCPU) walkGLBNode(gltf *glbAsset, bin []byte, idx int, parent mat4f) {
	if idx < 0 || idx >= len(gltf.Nodes) {
		return
	}
	node := gltf.Nodes[idx]
	world := glbMat4Mul(parent, nodeMatrix(node))
	if node.Mesh != nil && *node.Mesh >= 0 && *node.Mesh < len(gltf.Meshes) {
		m.appendMesh(gltf, bin, gltf.Meshes[*node.Mesh], world)
	}
	for _, child := range node.Children {
		m.walkGLBNode(gltf, bin, child, world)
	}
}

func (m *shipModelCPU) appendMesh(gltf *glbAsset, bin []byte, mesh glbMesh, world mat4f) {
	normalMat := world
	for _, prim := range mesh.Primitives {
		if prim.Mode != 0 && prim.Mode != 4 {
			continue
		}
		mat := 0
		if prim.Material != nil && *prim.Material >= 0 && *prim.Material < len(gltf.Materials) {
			mat = *prim.Material
		}
		if extractedWoWSRealtimeModelLOD && skipShipPrimitiveForRealtime(gltf.Materials[mat].Name, mesh.Name) {
			continue
		}
		posAcc, ok := prim.Attributes["POSITION"]
		if !ok {
			continue
		}
		norAcc, hasNormals := prim.Attributes["NORMAL"]
		uvAcc, hasUV := prim.Attributes["TEXCOORD_0"]
		positions := readAccessorVec3(gltf, bin, posAcc)
		normals := [][3]float32(nil)
		if hasNormals {
			normals = readAccessorVec3(gltf, bin, norAcc)
		}
		uvs := [][2]float32(nil)
		if hasUV {
			uvs = readAccessorVec2(gltf, bin, uvAcc)
		}
		baseVertex := uint32(len(m.Vertices) / 8)
		for i, p := range positions {
			wp := transformPoint(world, p)
			n := [3]float32{0, 1, 0}
			if i < len(normals) {
				n = glbNormalize3(transformVector(normalMat, normals[i]))
			}
			uv := [2]float32{0, 0}
			if i < len(uvs) {
				uv = uvs[i]
			}
			if extractedWoWSFixMirroredU {
				uv[0] = 1.0 - uv[0]
			}
			m.Vertices = append(m.Vertices, wp[0], wp[1], wp[2], n[0], n[1], n[2], uv[0], uv[1])
			for a := 0; a < 3; a++ {
				if wp[a] < m.BoundsMin[a] {
					m.BoundsMin[a] = wp[a]
				}
				if wp[a] > m.BoundsMax[a] {
					m.BoundsMax[a] = wp[a]
				}
			}
		}
		first := uint32(len(m.Indices))
		if prim.Indices != nil {
			for _, idx := range readAccessorIndices(gltf, bin, *prim.Indices) {
				m.Indices = append(m.Indices, baseVertex+idx)
			}
		} else {
			for i := range positions {
				m.Indices = append(m.Indices, baseVertex+uint32(i))
			}
		}
		m.Draws = append(m.Draws, shipDrawCPU{Material: mat, FirstIndex: first, IndexCount: uint32(len(m.Indices)) - first})
	}
}

func skipShipPrimitiveForRealtime(materialName, meshName string) bool {
	name := lowerASCII(materialName + " " + meshName)
	// The extracted WoWS carrier contains huge amounts of tiny AA/radar/director
	// geometry.  It is useful for asset inspection, but it cuts the frame rate hard
	// in this learning renderer.  Keep hull/deck/deckhouse/underwater primitives and
	// drop the small silhouette-noise pieces until we add a real LOD system.
	if containsASCII(name, "hull") || containsASCII(name, "deckhouse") || containsASCII(name, "underwater") || containsASCII(name, "default") {
		return false
	}
	if containsASCII(name, "radar") || containsASCII(name, "director") || containsASCII(name, "bofors") || containsASCII(name, "oerlikon") || containsASCII(name, "mk51") || containsASCII(name, "mk56") || containsASCII(name, "mk57") || containsASCII(name, "5in54") || containsASCII(name, "grid") || containsASCII(name, "glass") || containsASCII(name, "alpha") {
		return true
	}
	return false
}

func (m *shipModelCPU) optimizeDrawsByMaterial() {
	if len(m.Draws) <= 1 || len(m.Indices) == 0 {
		return
	}
	order := make([]int, 0, len(m.Draws))
	seen := map[int]bool{}
	for _, d := range m.Draws {
		if !seen[d.Material] {
			seen[d.Material] = true
			order = append(order, d.Material)
		}
	}
	newIndices := make([]uint32, 0, len(m.Indices))
	newDraws := make([]shipDrawCPU, 0, len(order))
	for _, mat := range order {
		first := uint32(len(newIndices))
		for _, d := range m.Draws {
			if d.Material != mat || d.IndexCount == 0 {
				continue
			}
			start := int(d.FirstIndex)
			end := start + int(d.IndexCount)
			if start < 0 || end > len(m.Indices) || start >= end {
				continue
			}
			newIndices = append(newIndices, m.Indices[start:end]...)
		}
		count := uint32(len(newIndices)) - first
		if count > 0 {
			newDraws = append(newDraws, shipDrawCPU{Material: mat, FirstIndex: first, IndexCount: count})
		}
	}
	m.Indices = newIndices
	m.Draws = newDraws
}

func lowerASCII(s string) string {
	b := []byte(s)
	for i, c := range b {
		if c >= 'A' && c <= 'Z' {
			b[i] = c + ('a' - 'A')
		}
	}
	return string(b)
}

func containsASCII(s, needle string) bool {
	if len(needle) == 0 || len(needle) > len(s) {
		return false
	}
	for i := 0; i <= len(s)-len(needle); i++ {
		if s[i:i+len(needle)] == needle {
			return true
		}
	}
	return false
}

func accessorBytes(gltf *glbAsset, bin []byte, accessorIndex int) ([]byte, glbAccessor, glbBufferView) {
	if accessorIndex < 0 || accessorIndex >= len(gltf.Accessors) {
		return nil, glbAccessor{}, glbBufferView{}
	}
	acc := gltf.Accessors[accessorIndex]
	if acc.BufferView < 0 || acc.BufferView >= len(gltf.BufferViews) {
		return nil, acc, glbBufferView{}
	}
	bv := gltf.BufferViews[acc.BufferView]
	start := bv.ByteOffset + acc.ByteOffset
	if start < 0 || start >= len(bin) {
		return nil, acc, bv
	}
	return bin[start:], acc, bv
}

func readAccessorVec3(gltf *glbAsset, bin []byte, accessorIndex int) [][3]float32 {
	b, acc, bv := accessorBytes(gltf, bin, accessorIndex)
	if b == nil || acc.Type != "VEC3" || acc.ComponentType != 5126 {
		return nil
	}
	stride := bv.ByteStride
	if stride == 0 {
		stride = 12
	}
	out := make([][3]float32, acc.Count)
	for i := range out {
		off := i * stride
		if off+12 <= len(b) {
			out[i] = [3]float32{math.Float32frombits(binary.LittleEndian.Uint32(b[off:])), math.Float32frombits(binary.LittleEndian.Uint32(b[off+4:])), math.Float32frombits(binary.LittleEndian.Uint32(b[off+8:]))}
		}
	}
	return out
}
func readAccessorVec2(gltf *glbAsset, bin []byte, accessorIndex int) [][2]float32 {
	b, acc, bv := accessorBytes(gltf, bin, accessorIndex)
	if b == nil || acc.Type != "VEC2" || acc.ComponentType != 5126 {
		return nil
	}
	stride := bv.ByteStride
	if stride == 0 {
		stride = 8
	}
	out := make([][2]float32, acc.Count)
	for i := range out {
		off := i * stride
		if off+8 <= len(b) {
			out[i] = [2]float32{math.Float32frombits(binary.LittleEndian.Uint32(b[off:])), math.Float32frombits(binary.LittleEndian.Uint32(b[off+4:]))}
		}
	}
	return out
}
func readAccessorIndices(gltf *glbAsset, bin []byte, accessorIndex int) []uint32 {
	b, acc, bv := accessorBytes(gltf, bin, accessorIndex)
	if b == nil || acc.Type != "SCALAR" {
		return nil
	}
	compSize := 4
	if acc.ComponentType == 5123 {
		compSize = 2
	}
	stride := bv.ByteStride
	if stride == 0 {
		stride = compSize
	}
	out := make([]uint32, acc.Count)
	for i := range out {
		off := i * stride
		if acc.ComponentType == 5123 && off+2 <= len(b) {
			out[i] = uint32(binary.LittleEndian.Uint16(b[off:]))
		} else if acc.ComponentType == 5125 && off+4 <= len(b) {
			out[i] = binary.LittleEndian.Uint32(b[off:])
		}
	}
	return out
}

func mat4Identity() mat4f { return mat4f{1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1} }
func nodeMatrix(n glbNode) mat4f {
	if len(n.Matrix) == 16 {
		var m mat4f
		copy(m[:], n.Matrix)
		return m
	}
	t := [3]float32{0, 0, 0}
	if len(n.Translation) >= 3 {
		copy(t[:], n.Translation[:3])
	}
	s := [3]float32{1, 1, 1}
	if len(n.Scale) >= 3 {
		copy(s[:], n.Scale[:3])
	}
	r := [4]float32{0, 0, 0, 1}
	if len(n.Rotation) >= 4 {
		copy(r[:], n.Rotation[:4])
	}
	return mat4TRS(t, r, s)
}
func mat4TRS(t [3]float32, q [4]float32, s [3]float32) mat4f {
	x, y, z, w := q[0], q[1], q[2], q[3]
	xx, yy, zz := x*x, y*y, z*z
	xy, xz, yz := x*y, x*z, y*z
	wx, wy, wz := w*x, w*y, w*z
	return mat4f{(1 - 2*(yy+zz)) * s[0], (2 * (xy + wz)) * s[0], (2 * (xz - wy)) * s[0], 0, (2 * (xy - wz)) * s[1], (1 - 2*(xx+zz)) * s[1], (2 * (yz + wx)) * s[1], 0, (2 * (xz + wy)) * s[2], (2 * (yz - wx)) * s[2], (1 - 2*(xx+yy)) * s[2], 0, t[0], t[1], t[2], 1}
}
func glbMat4Mul(a, b mat4f) mat4f {
	var o mat4f
	for c := 0; c < 4; c++ {
		for r := 0; r < 4; r++ {
			o[c*4+r] = a[0*4+r]*b[c*4+0] + a[1*4+r]*b[c*4+1] + a[2*4+r]*b[c*4+2] + a[3*4+r]*b[c*4+3]
		}
	}
	return o
}
func transformPoint(m mat4f, p [3]float32) [3]float32 {
	return [3]float32{m[0]*p[0] + m[4]*p[1] + m[8]*p[2] + m[12], m[1]*p[0] + m[5]*p[1] + m[9]*p[2] + m[13], m[2]*p[0] + m[6]*p[1] + m[10]*p[2] + m[14]}
}
func transformVector(m mat4f, p [3]float32) [3]float32 {
	return [3]float32{m[0]*p[0] + m[4]*p[1] + m[8]*p[2], m[1]*p[0] + m[5]*p[1] + m[9]*p[2], m[2]*p[0] + m[6]*p[1] + m[10]*p[2]}
}
func glbNormalize3(v [3]float32) [3]float32 {
	l := float32(math.Sqrt(float64(v[0]*v[0] + v[1]*v[1] + v[2]*v[2])))
	if l <= 0 {
		return [3]float32{0, 1, 0}
	}
	return [3]float32{v[0] / l, v[1] / l, v[2] / l}
}
func max32(a, b float32) float32 {
	if a > b {
		return a
	}
	return b
}
