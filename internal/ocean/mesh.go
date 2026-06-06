package ocean

import "math"

const (
	// Camera-relative Cartesian ocean mesh. The center stays a regular grid
	// point instead of a polar fan hub. The extent is intentionally large so high
	// camera views fade into the procedural far ocean instead of exposing a hard end.
	planeSize       float32 = 7200.0
	planeResolution int     = 512
	vertexStride    uint64  = 32
	// Moderate camera-weighting. The previous 1.64 exponent concentrated the grid
	// too hard and made top-down views reveal a center/stretch pattern. Keep a denser
	// near field, but avoid visible radial/grid transitions.
	gridExponent    float32 = 1.48
)

type MeshData struct {
	Vertices    []float32
	Indices     []uint32
	VertexCount uint32
	IndexCount  uint32
}

func gridOceanCoord(ix, iz, resolution int, size float32) (x, z, u, v float32) {
	if resolution <= 0 {
		return
	}

	u = float32(ix) / float32(resolution)
	v = float32(iz) / float32(resolution)

	qx := u*2.0 - 1.0
	qz := v*2.0 - 1.0
	halfSize := size * 0.5

	x = signedPow(qx, gridExponent) * halfSize
	z = signedPow(qz, gridExponent) * halfSize
	return
}

func signedPow(v, exp float32) float32 {
	if v == 0 {
		return 0
	}
	return float32(math.Copysign(math.Pow(math.Abs(float64(v)), float64(exp)), float64(v)))
}

// GeneratePlaneMesh creates a camera-relative indexed Cartesian ocean mesh with
// dense center spacing and stretched far cells. CPU and compute-shader vertex
// reconstruction must match this exactly.
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
			px, pz, u, v := gridOceanCoord(x, z, resolution, size)
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
