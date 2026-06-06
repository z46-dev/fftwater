package camera

import (
	"math"

	rl "github.com/gen2brain/raylib-go/raylib"
)

type SmoothCamera struct {
	cam                                                   rl.Camera3D
	pos, targetPos                                        rl.Vector3
	yaw, pitch                                            float32
	targetYaw, targetPitch                                float32
	lookSensitivity, moveSpeed, fastMultiplier, smoothing float32
}

func NewSmoothCamera(position rl.Vector3) (camera *SmoothCamera) {
	camera = &SmoothCamera{
		pos:             position,
		targetPos:       position,
		yaw:             -90,
		targetYaw:       -90,
		pitch:           -12,
		targetPitch:     -12,
		lookSensitivity: 0.09,
		moveSpeed:       50,
		fastMultiplier:  4,
		smoothing:       14,
	}

	camera.cam = rl.Camera3D{
		Position:   position,
		Target:     rl.Vector3Add(position, camera.forward()),
		Up:         rl.NewVector3(0, 1, 0),
		Fovy:       65,
		Projection: rl.CameraPerspective,
	}

	return camera
}

func (c *SmoothCamera) Camera() rl.Camera3D {
	return c.cam
}

func (c *SmoothCamera) Position() rl.Vector3 {
	return c.pos
}

func (c *SmoothCamera) Update(dt float32) {
	if rl.IsMouseButtonDown(rl.MouseRightButton) {
		var delta rl.Vector2 = rl.GetMouseDelta()
		c.targetYaw += delta.X * c.lookSensitivity
		c.targetPitch -= delta.Y * c.lookSensitivity
		c.targetPitch = clamp(c.targetPitch, -84, 84)
	}

	var speed float32 = c.moveSpeed
	if rl.IsKeyDown(rl.KeyLeftShift) || rl.IsKeyDown(rl.KeyRightShift) {
		speed *= c.fastMultiplier
	}

	var (
		forward rl.Vector3 = c.forwardFlat()
		right   rl.Vector3 = rl.Vector3Normalize(rl.Vector3CrossProduct(forward, rl.NewVector3(0, 1, 0)))
		move    rl.Vector3
	)

	if rl.IsKeyDown(rl.KeyW) {
		move = rl.Vector3Add(move, forward)
	}

	if rl.IsKeyDown(rl.KeyS) {
		move = rl.Vector3Subtract(move, forward)
	}

	if rl.IsKeyDown(rl.KeyD) {
		move = rl.Vector3Add(move, right)
	}

	if rl.IsKeyDown(rl.KeyA) {
		move = rl.Vector3Subtract(move, right)
	}

	if rl.Vector3Length(move) > 0.0001 {
		move = rl.Vector3Normalize(move)
		c.targetPos = rl.Vector3Add(c.targetPos, rl.Vector3Scale(move, speed*dt))
	}

	var wheel float32 = rl.GetMouseWheelMove()
	if wheel != 0 {
		c.targetPos.Y += wheel * speed * 0.35
	}

	var alpha float32 = float32(1 - math.Exp(float64(-c.smoothing*dt)))
	c.yaw = lerp(c.yaw, c.targetYaw, alpha)
	c.pitch = lerp(c.pitch, c.targetPitch, alpha)
	c.pos = vec3Lerp(c.pos, c.targetPos, alpha)

	c.cam.Position = c.pos
	c.cam.Target = rl.Vector3Add(c.pos, c.forward())
	c.cam.Up = rl.NewVector3(0, 1, 0)
}

func (c *SmoothCamera) forward() rl.Vector3 {
	var (
		yaw, pitch float64 = float64(degToRad(c.yaw)), float64(degToRad(c.pitch))
		cp         float32 = float32(math.Cos(float64(pitch)))
	)

	return rl.Vector3Normalize(rl.NewVector3(
		cp*float32(math.Cos(yaw)),
		float32(math.Sin(float64(pitch))),
		cp*float32(math.Sin(yaw)),
	))
}

func (c *SmoothCamera) forwardFlat() rl.Vector3 {
	var f rl.Vector3 = c.forward()
	f.Y = 0

	if rl.Vector3Length(f) < 0.0001 {
		return rl.NewVector3(0, 0, -1)
	}

	return rl.Vector3Normalize(f)
}

func vec3Lerp(a, b rl.Vector3, t float32) rl.Vector3 {
	return rl.NewVector3(
		lerp(a.X, b.X, t),
		lerp(a.Y, b.Y, t),
		lerp(a.Z, b.Z, t),
	)
}

func lerp(a, b, t float32) float32 {
	return a + (b-a)*t
}

func clamp(v, lo, hi float32) float32 {
	if v < lo {
		return lo
	}

	if v > hi {
		return hi
	}

	return v
}

func degToRad(v float32) float32 {
	return v * math.Pi / 180
}
