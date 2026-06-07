package m3

import "math"

// Identity returns the identity matrix.
func Identity() Mat4 {
	return Mat4{1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1}
}

// Perspective returns a perspective projection matrix.
func Perspective(fovyRadians, aspect, near, far float32) (mat Mat4) {
	var inverseTangentFov float32 = float32(1.0 / math.Tan(float64(fovyRadians*0.5)))
	mat = Mat4{
		inverseTangentFov / aspect, 0, 0, 0,
		0, inverseTangentFov, 0, 0,
		0, 0, far / (near - far), -1,
		0, 0, (far * near) / (near - far), 0,
	}

	return
}

// LookAt returns a view matrix that transforms world space to the camera's local space.
func LookAt(eye, target, up *Vector3) (mat Mat4) {
	var (
		f *Vector3 = target.Sub(eye).Normalize()
		s *Vector3 = Cross(f, up).Normalize()
		u *Vector3 = Cross(s, f)
	)

	mat = Mat4{
		s.X, u.X, -f.X, 0,
		s.Y, u.Y, -f.Y, 0,
		s.Z, u.Z, -f.Z, 0,
		-Dot(s, eye), -Dot(u, eye), Dot(f, eye), 1,
	}

	return
}

// Mul returns the product of two 4x4 matrices.
func Mul(a, b Mat4) (out Mat4) {
	for col := range 4 {
		for row := range 4 {
			out[col*4+row] = a[0*4+row]*b[col*4+0] + a[1*4+row]*b[col*4+1] + a[2*4+row]*b[col*4+2] + a[3*4+row]*b[col*4+3]
		}
	}

	return
}
