package main

import (
	"fmt"
	"log"
	"runtime"

	rl "github.com/gen2brain/raylib-go/raylib"

	"github.com/z46-dev/fftwater/_old/camera"
	"github.com/z46-dev/fftwater/_old/ocean"
	"github.com/z46-dev/fftwater/_old/sky"
)

const (
	screenWidth  = 600
	screenHeight = 300
)

type environmentPreset struct {
	name       string
	sunDir     rl.Vector3
	clearColor rl.Color
}

var environmentPresets = []environmentPreset{
	{
		name:       "day",
		sunDir:     rl.Vector3Normalize(rl.NewVector3(-0.42, 0.70, -0.57)),
		clearColor: rl.NewColor(185, 205, 216, 255),
	},
	{
		name:       "sunset",
		sunDir:     rl.Vector3Normalize(rl.NewVector3(-0.72, 0.18, -0.42)),
		clearColor: rl.NewColor(170, 145, 132, 255),
	},
	{
		name:       "night",
		sunDir:     rl.Vector3Normalize(rl.NewVector3(0.28, 0.46, 0.84)),
		clearColor: rl.NewColor(9, 15, 28, 255),
	},
}

func main() {
	rl.SetConfigFlags(rl.FlagMsaa4xHint | rl.FlagVsyncHint | rl.FlagWindowResizable)
	rl.InitWindow(screenWidth, screenHeight, "Ocean3D FFT Boilerplate")
	defer rl.CloseWindow()

	rl.SetWindowSize(rl.GetScreenWidth(), rl.GetScreenHeight())

	var (
		cam     *camera.SmoothCamera = camera.NewSmoothCamera(rl.NewVector3(0, 14, 45))
		skyDome *sky.Dome
		err     error
		sea     *ocean.Ocean
	)

	if skyDome, err = sky.New("shaders/sky.vert.glsl", "shaders/sky.frag.glsl"); err != nil {
		log.Fatalf("load sky: %v", err)
	}

	defer skyDome.Close()

	if sea, err = ocean.New(ocean.Config{
		N:                128,
		SizeMeters:       512,
		RenderSizeMeters: 8192,
		WindDirection:    rl.NewVector2(1.0, 0.28),
		WindSpeed:        10.5,
		Amplitude:        150,
		Choppiness:       0.1,
		Seed:             42,
		SpectralUpdateHz: 60,
		Cascades: []ocean.CascadeConfig{
			{
				N:             128,
				SizeMeters:    512,
				WindDirection: rl.NewVector2(-1.0, 0.28),
				WindSpeed:     10.5,
				Amplitude:     1000,
				Choppiness:    0.3,
				Seed:          42,
			},
			{
				N:             128,
				SizeMeters:    128,
				WindDirection: rl.NewVector2(1.0, -0.28),
				WindSpeed:     10.5,
				Amplitude:     1000,
				Choppiness:    0.8,
				Seed:          43,
			},
			{
				N:             128,
				SizeMeters:    64,
				WindDirection: rl.NewVector2(1.0, 0.28),
				WindSpeed:     10.5,
				Amplitude:     1000,
				Choppiness:    0.2,
				Seed:          44,
			},
		},
		ShaderVert: "shaders/ocean.vert.glsl",
		ShaderFrag: "shaders/ocean.frag.glsl",
	}); err != nil {
		log.Fatalf("create ocean: %v", err)
	}

	defer sea.Close()

	var (
		debugMode       int32   = 1
		paused          bool    = false
		timeScale       float32 = 1.0
		simTime         float64 = 0
		environmentMode int32   = 0
	)

	for !rl.WindowShouldClose() {
		var dt float32 = rl.GetFrameTime()
		if dt > 1.0/15.0 {
			dt = 1.0 / 15.0
		}

		if rl.IsKeyPressed(rl.KeyOne) {
			debugMode = 1
		}

		if rl.IsKeyPressed(rl.KeyTwo) {
			debugMode = 2
		}

		if rl.IsKeyPressed(rl.KeyThree) {
			debugMode = 3
		}

		if rl.IsKeyPressed(rl.KeyFour) {
			debugMode = 4
		}

		if rl.IsKeyPressed(rl.KeyFive) {
			debugMode = 5
		}

		if rl.IsKeyPressed(rl.KeySix) {
			environmentMode = 0
		}

		if rl.IsKeyPressed(rl.KeySeven) {
			environmentMode = 1
		}

		if rl.IsKeyPressed(rl.KeyEight) {
			environmentMode = 2
		}

		if rl.IsKeyPressed(rl.KeySpace) {
			paused = !paused
		}

		if rl.IsKeyPressed(rl.KeyLeftBracket) {
			timeScale *= 0.8
		}

		if rl.IsKeyPressed(rl.KeyRightBracket) {
			timeScale *= 1.25
		}

		if rl.IsKeyPressed(rl.KeyR) {
			timeScale = 1.0
		}

		cam.Update(dt)

		if !paused {
			simTime += float64(dt * timeScale)
		}

		var preset environmentPreset = environmentPresets[environmentMode]
		sea.Update(float32(simTime), preset.sunDir, cam.Position(), environmentMode)
		skyDome.Update(float32(simTime), preset.sunDir, cam.Position(), environmentMode)

		rl.BeginDrawing()
		rl.ClearBackground(preset.clearColor)

		rl.BeginMode3D(cam.Camera())
		skyDome.Draw(cam.Position())
		sea.Draw(debugMode, cam.Position())
		rl.EndMode3D()

		drawHUD(debugMode, paused, timeScale, sea, cam, preset.name)
		rl.EndDrawing()
	}
}

func drawHUD(debugMode int32, paused bool, timeScale float32, sea *ocean.Ocean, cam *camera.SmoothCamera, environmentName string) {
	var y int32 = 8

	rl.DrawFPS(8, y)
	y += 24

	var pauseText string = "running"
	if paused {
		pauseText = "paused"
	}

	rl.DrawText(fmt.Sprintf("mode %d | %s | env %s | time %.2fx | right mouse look | WASD move | wheel height", debugMode, pauseText, environmentName, timeScale), 8, y, 16, rl.NewColor(35, 45, 50, 255))
	y += 22

	rl.DrawText("1 shaded | 2 height | 3 slope | 4 normals | 5 foam | 6 day | 7 sunset | 8 night | Space pause | [/] time | R reset", 8, y, 16, rl.NewColor(35, 45, 50, 255))
	y += 22

	rl.DrawText(fmt.Sprintf("FFT grid %dx%d | cascades %d | patch %.0fm | render %.0fm | %.1fm spacing | camera %.1f %.1f %.1f", sea.N(), sea.N(), sea.CascadeCount(), sea.Size(), sea.RenderSize(), sea.RenderSpacing(), cam.Position().X, cam.Position().Y, cam.Position().Z), 8, y, 16, rl.NewColor(35, 45, 50, 255))
}

// Debug
func init() {
	fmt.Printf("Go version: %s\n", runtime.Version())
	fmt.Printf("OS/Arch: %s/%s\n", runtime.GOOS, runtime.GOARCH)
	fmt.Printf("NumCPU: %d\n", runtime.NumCPU())
	fmt.Printf("GOMAXPROCS: %d\n", runtime.GOMAXPROCS(0))
	fmt.Printf("GLSL version: %d\n", rl.GetVersion())
}
