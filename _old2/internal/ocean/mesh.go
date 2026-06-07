package ocean

import "math"

const (
	// WoWS-style continuous sea grid. The older explicit near/mid/far square rings
	// were visible as three independent surfaces and each band appeared to swim at
	// a different rate during camera motion. This is one continuous projected grid:
	// density changes smoothly with distance, but topology no longer has hard LOD
	// seams.
	planeSize       float32 = 10400.0
	planeResolution int     = 544
	vertexStride    uint64  = 32

	// Matches shaders/ocean_height_compute.wgsl. Larger values concentrate more
	// vertices near the camera while preserving a single continuous surface.
	projectedGridScale float32 = 4.80
)

type MeshData struct {
	Vertices    []float32
	Indices     []uint32
	VertexCount uint32
	IndexCount  uint32
}

func projectedOceanCoord(ix, iz, resolution int, size float32) (x, z, u, v float32) {
	if resolution <= 0 {
		return
	}

	u = float32(ix) / float32(resolution)
	v = float32(iz) / float32(resolution)
	qx := u*2.0 - 1.0
	qz := v*2.0 - 1.0

	r := float32(math.Max(math.Abs(float64(qx)), math.Abs(float64(qz))))
	if r <= 1e-6 {
		return 0, 0, u, v
	}

	halfSize := size * 0.5
	expScale := float32(math.Exp(float64(projectedGridScale)))
	mapped := (float32(math.Exp(float64(r*projectedGridScale))) - 1.0) / (expScale - 1.0)
	distance := mapped * halfSize

	invR := 1.0 / r
	x = qx * invR * distance
	z = qz * invR * distance
	return
}

// GeneratePlaneMesh creates one continuous projected ocean grid. It is still a
// single indexed draw, but it behaves like a sea mesh with smooth distance LOD:
// high density near the camera, progressively larger cells toward the horizon,
// and no separate close/medium/far surfaces to reveal seams or independent phase.
func GeneratePlaneMesh(size float32, resolution int) MeshData {
	if size <= 0 {
		size = planeSize
	}
	if resolution <= 0 {
		resolution = planeResolution
	}

	gridVerts := resolution + 1
	vertexCount := gridVerts * gridVerts
	indexCount := resolution * resolution * 6

	vertices := make([]float32, 0, vertexCount*8)
	indices := make([]uint32, 0, indexCount)

	for z := 0; z <= resolution; z++ {
		for x := 0; x <= resolution; x++ {
			px, pz, u, v := projectedOceanCoord(x, z, resolution, size)
			vertices = append(vertices,
				px, 0, pz,
				0, 1, 0,
				u, v,
			)
		}
	}

	rowStride := resolution + 1
	for z := 0; z < resolution; z++ {
		for x := 0; x < resolution; x++ {
			i0 := uint32(z*rowStride + x)
			i1 := i0 + 1
			i2 := i0 + uint32(rowStride)
			i3 := i2 + 1

			indices = append(indices,
				i0, i2, i1,
				i1, i2, i3,
			)
		}
	}

	return MeshData{
		Vertices:    vertices,
		Indices:     indices,
		VertexCount: uint32(vertexCount),
		IndexCount:  uint32(indexCount),
	}
}
