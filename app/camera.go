package app

import (
	"math"

	"github.com/gogpu/gogpu/input"
)

const (
	waterCameraMoveSpeed    float32 = 36.0
	waterCameraLookScale    float32 = 0.0025
	waterCameraMinPitch     float32 = -1.35
	waterCameraMaxPitch     float32 = 0.08
	waterCameraDefaultFOV   float32 = 62.0 * math.Pi / 180.0
	waterCameraDefaultNear  float32 = 0.25
	waterCameraDefaultFar   float32 = 2400.0
	waterCameraDefaultYaw   float32 = 0.0
	waterCameraDefaultPitch float32 = -0.24
)

type Vec3 struct {
	X float32
	Y float32
	Z float32
}

func (v Vec3) Add(o Vec3) Vec3    { return Vec3{X: v.X + o.X, Y: v.Y + o.Y, Z: v.Z + o.Z} }
func (v Vec3) Sub(o Vec3) Vec3    { return Vec3{X: v.X - o.X, Y: v.Y - o.Y, Z: v.Z - o.Z} }
func (v Vec3) Mul(s float32) Vec3 { return Vec3{X: v.X * s, Y: v.Y * s, Z: v.Z * s} }

func dot3(a, b Vec3) float32 { return a.X*b.X + a.Y*b.Y + a.Z*b.Z }

func cross3(a, b Vec3) Vec3 {
	return Vec3{
		X: a.Y*b.Z - a.Z*b.Y,
		Y: a.Z*b.X - a.X*b.Z,
		Z: a.X*b.Y - a.Y*b.X,
	}
}

func normalize3(v Vec3) Vec3 {
	l2 := dot3(v, v)
	if l2 <= 0.00000001 {
		return Vec3{Y: 1}
	}

	inv := float32(1.0 / math.Sqrt(float64(l2)))
	return v.Mul(inv)
}

func clamp32(v, lo, hi float32) float32 {
	if v < lo {
		return lo
	}
	if v > hi {
		return hi
	}
	return v
}

// Mat4 is column-major so it can be copied directly into WGSL mat4x4<f32>
// uniforms. Index = column*4 + row.
type Mat4 [16]float32

type WaterCamera struct {
	Position Vec3
	Yaw      float32
	Pitch    float32
	FOVY     float32
	Near     float32
	Far      float32
}

func NewWaterCamera() *WaterCamera {
	return &WaterCamera{
		Position: Vec3{X: 0, Y: 18, Z: 48},
		Yaw:      waterCameraDefaultYaw,
		Pitch:    waterCameraDefaultPitch,
		FOVY:     waterCameraDefaultFOV,
		Near:     waterCameraDefaultNear,
		Far:      waterCameraDefaultFar,
	}
}

func (c *WaterCamera) ApplyLookDelta(dx, dy float32) {
	if c == nil {
		return
	}

	c.Yaw -= dx * waterCameraLookScale
	c.Pitch = clamp32(c.Pitch-dy*waterCameraLookScale, waterCameraMinPitch, waterCameraMaxPitch)
}

func (c *WaterCamera) Basis() (forward, right, up Vec3) {
	cy := float32(math.Cos(float64(c.Yaw)))
	sy := float32(math.Sin(float64(c.Yaw)))
	cp := float32(math.Cos(float64(c.Pitch)))
	sp := float32(math.Sin(float64(c.Pitch)))

	forward = normalize3(Vec3{X: sy * cp, Y: sp, Z: -cy * cp})
	right = normalize3(cross3(forward, Vec3{Y: 1}))
	up = normalize3(cross3(right, forward))
	return
}

func (c *WaterCamera) Update(dt float32, in *input.State) {
	if c == nil || in == nil || dt <= 0 {
		return
	}

	keyboard := in.Keyboard()
	forward, right, _ := c.Basis()
	flatForward := normalize3(Vec3{X: forward.X, Y: 0, Z: forward.Z})
	flatRight := normalize3(Vec3{X: right.X, Y: 0, Z: right.Z})

	var move Vec3
	if keyboard.Pressed(input.KeyW) || keyboard.Pressed(input.KeyUp) {
		move = move.Add(flatForward)
	}
	if keyboard.Pressed(input.KeyS) || keyboard.Pressed(input.KeyDown) {
		move = move.Sub(flatForward)
	}
	if keyboard.Pressed(input.KeyD) || keyboard.Pressed(input.KeyRight) {
		move = move.Add(flatRight)
	}
	if keyboard.Pressed(input.KeyA) || keyboard.Pressed(input.KeyLeft) {
		move = move.Sub(flatRight)
	}
	if keyboard.Pressed(input.KeyE) || keyboard.Pressed(input.KeySpace) {
		move.Y += 1
	}
	if keyboard.Pressed(input.KeyQ) || keyboard.Pressed(input.KeyControlLeft) || keyboard.Pressed(input.KeyControlRight) {
		move.Y -= 1
	}

	if dot3(move, move) > 0.0001 {
		move = normalize3(move)
	}

	speed := waterCameraMoveSpeed
	if keyboard.Pressed(input.KeyShiftLeft) || keyboard.Pressed(input.KeyShiftRight) {
		speed *= 3.0
	}

	c.Position = c.Position.Add(move.Mul(speed * dt))
	if c.Position.Y < 2.0 {
		c.Position.Y = 2.0
	}
}

func (c *WaterCamera) ViewProj(aspect float32) Mat4 {
	if aspect <= 0 {
		aspect = 16.0 / 9.0
	}

	forward, right, up := c.Basis()
	view := mat4LookRH(c.Position, forward, right, up)
	proj := mat4PerspectiveRHZO(c.FOVY, aspect, c.Near, c.Far)
	return mat4Mul(proj, view)
}

func (c *WaterCamera) TanHalfFOVY() float32 {
	return float32(math.Tan(float64(c.FOVY * 0.5)))
}

func mat4LookRH(eye, forward, right, up Vec3) Mat4 {
	f := normalize3(forward)
	r := normalize3(right)
	u := normalize3(up)

	return Mat4{
		r.X, u.X, -f.X, 0,
		r.Y, u.Y, -f.Y, 0,
		r.Z, u.Z, -f.Z, 0,
		-dot3(r, eye), -dot3(u, eye), dot3(f, eye), 1,
	}
}

func mat4PerspectiveRHZO(fovy, aspect, near, far float32) Mat4 {
	if aspect <= 0 {
		aspect = 1
	}
	if near <= 0 {
		near = 0.1
	}
	if far <= near {
		far = near + 1
	}

	f := float32(1.0 / math.Tan(float64(fovy*0.5)))
	zf := far / (near - far)
	zn := (far * near) / (near - far)

	return Mat4{
		f / aspect, 0, 0, 0,
		0, f, 0, 0,
		0, 0, zf, -1,
		0, 0, zn, 0,
	}
}

func mat4Mul(a, b Mat4) Mat4 {
	var out Mat4
	for col := 0; col < 4; col++ {
		for row := 0; row < 4; row++ {
			out[col*4+row] =
				a[0*4+row]*b[col*4+0] +
					a[1*4+row]*b[col*4+1] +
					a[2*4+row]*b[col*4+2] +
					a[3*4+row]*b[col*4+3]
		}
	}
	return out
}
