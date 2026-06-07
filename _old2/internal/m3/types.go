package m3

type (
	Vector3 struct {
		X, Y, Z float32
	}

	Mat4 [16]float32 // column-major, compatible with WGSL mat4x4<f32>
)
