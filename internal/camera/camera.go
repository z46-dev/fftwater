package camera

import (
	"math"

	"github.com/gogpu/gogpu/input"
	"github.com/z46-dev/fftwater/internal/m3"
)

// Camera is a stable free-flight inspection camera.
type Camera struct {
	Position, velocity     *m3.Vector3
	Yaw, Pitch             float32
	targetYaw, targetPitch float32
	zoomVelocity           float32
}

// New creates a new camera at the given position, looking in the -Z direction.
func New(pos *m3.Vector3) (c *Camera) {
	yaw, pitch := float32(math.Pi), float32(-0.28)

	return &Camera{
		Position:    pos,
		Yaw:         yaw,
		Pitch:       pitch,
		targetYaw:   yaw,
		targetPitch: pitch,
		velocity:    m3.NewVector3(0, 0, 0),
	}
}

// Update updates the camera's position and orientation from input.
func (c *Camera) Update(dt float32, in *input.State) {
	if in == nil || dt <= 0 {
		return
	}

	if dt > 1.0/50.0 {
		dt = 1.0 / 50.0
	}

	keyboard := in.Keyboard()
	mouse := in.Mouse()

	lookAlpha := expSmoothing(28.0, dt)
	c.Yaw = m3.Lerp(c.Yaw, c.targetYaw, lookAlpha)
	c.Pitch = m3.Lerp(c.Pitch, c.targetPitch, lookAlpha)

	forward := c.Forward()
	flatForward := m3.NewVector3(forward.X, 0, forward.Z)
	if flatForward.Length() < 0.0001 {
		flatForward = m3.NewVector3(0, 0, -1)
	} else {
		flatForward = flatForward.Normalize()
	}

	worldUp := m3.NewVector3(0, 1, 0)
	right := m3.Cross(flatForward, worldUp).Normalize()

	move := m3.NewVector3(0, 0, 0)
	if keyboard.Pressed(input.KeyW) {
		move = move.Add(flatForward)
	}
	if keyboard.Pressed(input.KeyS) {
		move = move.Sub(flatForward)
	}
	if keyboard.Pressed(input.KeyD) {
		move = move.Add(right)
	}
	if keyboard.Pressed(input.KeyA) {
		move = move.Sub(right)
	}
	if keyboard.Pressed(input.KeySpace) || keyboard.Pressed(input.KeyE) {
		move.Y += 1
	}
	if keyboard.Pressed(input.KeyControlLeft) || keyboard.Pressed(input.KeyQ) {
		move.Y -= 1
	}

	speed := float32(15.0)
	if keyboard.Pressed(input.KeyShiftLeft) || keyboard.Pressed(input.KeyShiftRight) {
		speed = 48.0
	}

	if move.Length() > 0.0001 {
		move = move.Normalize().MulScalar(speed)
	}

	_, wheelY := mouse.Scroll()
	if wheelY != 0 {
		// Treat wheel as a damped velocity, not an immediate position jump. This
		// avoids shocking the camera/ocean relationship and removes a common source
		// of visible water re-sampling artifacts while zooming.
		c.zoomVelocity += m3.Clamp(wheelY, -4.0, 4.0) * 18.0
	}

	zoomDamping := expSmoothing(10.0, dt)
	if float32(math.Abs(float64(c.zoomVelocity))) > 0.001 {
		move = move.Add(forward.MulScalar(c.zoomVelocity))
		c.zoomVelocity = m3.Lerp(c.zoomVelocity, 0.0, zoomDamping)
	} else {
		c.zoomVelocity = 0
	}

	moveAlpha := expSmoothing(14.0, dt)
	c.velocity = c.velocity.Lerp(move, moveAlpha)
	c.Position = c.Position.Add(c.velocity.MulScalar(dt))
}

// ApplyLookDelta rotates the camera target from raw relative mouse movement.
func (c *Camera) ApplyLookDelta(dx, dy float32) {
	const sensitivity float32 = 0.0020

	c.targetYaw -= dx * sensitivity
	c.targetPitch -= dy * sensitivity
	c.targetPitch = m3.Clamp(c.targetPitch, -1.38, 1.20)
}

// Forward returns the forward direction vector for the current yaw/pitch.
func (c *Camera) Forward() (forward *m3.Vector3) {
	cosPitch := float32(math.Cos(float64(c.Pitch)))
	return m3.NewVector3(
		float32(math.Sin(float64(c.Yaw)))*cosPitch,
		float32(math.Sin(float64(c.Pitch))),
		float32(math.Cos(float64(c.Yaw)))*cosPitch,
	).Normalize()
}

// ViewMatrix returns the view matrix for the camera.
func (c *Camera) ViewMatrix() m3.Mat4 {
	return m3.LookAt(c.Position, c.Position.Add(c.Forward()), &m3.Vector3{Y: 1})
}

func expSmoothing(rate, dt float32) float32 {
	return float32(1.0 - math.Exp(float64(-rate*dt)))
}
