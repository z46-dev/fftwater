package m3

import "math"

// Vector3 represents a 3D vector with X, Y, and Z components.
func NewVector3(x, y, z float32) (v *Vector3) {
	v = &Vector3{X: x, Y: y, Z: z}
	return
}

// Adds two vectors together and returns the result as a new vector.
func (v *Vector3) Add(o *Vector3) (n *Vector3) {
	n = &Vector3{v.X + o.X, v.Y + o.Y, v.Z + o.Z}
	return
}

// Adds a new vector into an existing vector.
func (v *Vector3) AddS(o *Vector3) {
	v.X += o.X
	v.Y += o.Y
	v.Z += o.Z
}

// Subtracts one vector from another and returns the result as a new vector.
func (v *Vector3) Sub(o *Vector3) (n *Vector3) {
	n = &Vector3{v.X - o.X, v.Y - o.Y, v.Z - o.Z}
	return
}

// Subtracts a new vector from an existing vector.
func (v *Vector3) SubS(o *Vector3) {
	v.X -= o.X
	v.Y -= o.Y
	v.Z -= o.Z
}

// Multiplies a vector by a scalar and returns the result as a new vector.
func (v *Vector3) MulScalar(s float32) (n *Vector3) {
	n = &Vector3{v.X * s, v.Y * s, v.Z * s}
	return
}

// Multiplies an existing vector by a scalar.
func (v *Vector3) MulScalarS(s float32) {
	v.X *= s
	v.Y *= s
	v.Z *= s
}

// Multiplies two vectors together and returns the result as a new vector.
func (v *Vector3) Mul(o *Vector3) (n *Vector3) {
	n = &Vector3{v.X * o.X, v.Y * o.Y, v.Z * o.Z}
	return
}

// Multiplies an existing vector by a new vector.
func (v *Vector3) MulS(o *Vector3) {
	v.X *= o.X
	v.Y *= o.Y
	v.Z *= o.Z
}

// Returns the length of the vector
func (v *Vector3) Length() (length float32) {
	length = float32(math.Sqrt(float64(v.X*v.X + v.Y*v.Y + v.Z*v.Z)))
	return
}

// Normalizes the vector and returns the result as a new vector.
// If the length of the vector is very small, a zero vector is returned instead.
func (v *Vector3) Normalize() (n *Vector3) {
	var l float32 = v.Length()
	if l < 1e-6 {
		n = &Vector3{}
		return
	}

	n = v.MulScalar(1 / l)
	return
}

// Normalizes an existing vector.
// If the length of the vector is very small, the vector is set to zero instead.
func (v *Vector3) NormalizeS() {
	var l float32 = v.Length()
	if l < 1e-6 {
		v.X, v.Y, v.Z = 0, 0, 0
		return
	}

	v.MulScalarS(1 / l)
}

// Returns the dot product of two vectors.
func Dot(a, b *Vector3) (dot float32) {
	dot = a.X*b.X + a.Y*b.Y + a.Z*b.Z
	return
}

// Returns the cross product of two vectors as a new vector.
func Cross(a, b *Vector3) (n *Vector3) {
	n = &Vector3{
		X: a.Y*b.Z - a.Z*b.Y,
		Y: a.Z*b.X - a.X*b.Z,
		Z: a.X*b.Y - a.Y*b.X,
	}

	return
}

// Linearly interpolates between two vectors and returns the result as a new vector.
func (v *Vector3) Lerp(o *Vector3, t float32) (n *Vector3) {
	n = &Vector3{
		X: Lerp(v.X, o.X, t),
		Y: Lerp(v.Y, o.Y, t),
		Z: Lerp(v.Z, o.Z, t),
	}

	return
}
