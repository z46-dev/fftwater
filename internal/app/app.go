package app

import (
	"fmt"
	"sync"
	"time"

	"github.com/gogpu/gogpu"
	"github.com/gogpu/gogpu/input"
	"github.com/gogpu/gpucontext"
	"github.com/z46-dev/fftwater/internal/camera"
	"github.com/z46-dev/fftwater/internal/m3"
	"github.com/z46-dev/fftwater/internal/ocean"
	"github.com/z46-dev/gctx2d"
	"github.com/z46-dev/golog"
)

const (
	startWidth  = 1280
	startHeight = 720

	hudX      = 16
	hudY      = 16
	hudWidth  = 640
	hudHeight = 118
)

type mouseLookAccumulator struct {
	mu sync.Mutex
	x  float32
	y  float32
}

func (a *mouseLookAccumulator) Add(dx, dy float32) {
	a.mu.Lock()
	defer a.mu.Unlock()

	a.x += dx
	a.y += dy
}

func (a *mouseLookAccumulator) Take() (dx, dy float32) {
	a.mu.Lock()
	defer a.mu.Unlock()

	dx, dy = a.x, a.y
	a.x, a.y = 0, 0

	return
}

func Run(log *golog.Logger) error {
	var (
		gpuApp *gogpu.App = gogpu.NewApp(
			gogpu.DefaultConfig().
				WithTitle("FFTWater").
				WithSize(startWidth, startHeight).
				WithContinuousRender(true).
				WithPowerPreference(gogpu.PowerPreferenceHighPerformance).
				WithVSync(false).
				WithBackend(gogpu.BackendGo),
		)

		cam           *camera.Camera = camera.New(&m3.Vector3{X: 0, Y: 18, Z: 48})
		start         time.Time      = time.Now()
		renderer      *ocean.Renderer
		look          mouseLookAccumulator
		ctx           *gctx2d.Context
		pointerSource gpucontext.PointerEventSource
		ok            bool
	)

	if pointerSource, ok = gpuApp.EventSource().(gpucontext.PointerEventSource); ok {
		pointerSource.OnPointer(func(ev gpucontext.PointerEvent) {
			if ev.Type != gpucontext.PointerMove || ev.PointerType != gpucontext.PointerTypeMouse {
				return
			}

			if !ev.Buttons.HasRight() && gpuApp.CursorMode() != gpucontext.CursorModeLocked {
				return
			}

			look.Add(float32(ev.DeltaX), float32(ev.DeltaY))
		})
	}

	gpuApp.OnUpdate(func(dt float64) {
		var in = gpuApp.Input()

		if in != nil && in.Mouse().Pressed(input.MouseButtonRight) {
			gpuApp.SetCursorMode(gpucontext.CursorModeLocked)
		} else if gpuApp.CursorMode() != gpucontext.CursorModeNormal {
			gpuApp.SetCursorMode(gpucontext.CursorModeNormal)
		}

		var dx, dy float32
		if dx, dy = look.Take(); dx != 0 || dy != 0 {
			cam.ApplyLookDelta(dx, dy)
		}

		cam.Update(float32(dt), in)
	})

	var (
		provider        gogpu.DeviceProvider
		frameCount, fps int
		lastSecond      time.Time = time.Now()
		err             error
	)

	var release2D = func() {
		if ctx != nil {
			ctx.Release()
			ctx = nil
		}
	}

	ensure2DContext := func(provider gogpu.DeviceProvider) bool {
		if ctx != nil {
			return true
		}

		var createErr error
		ctx, createErr = gctx2d.NewContext(provider.Device(), provider.SurfaceFormat())
		if createErr != nil {
			log.Errorf("create 2D context: %v", createErr)
			return false
		}

		return true
	}

	gpuApp.OnDraw(func(dc *gogpu.Context) {
		provider = gpuApp.DeviceProvider()
		if provider == nil {
			return
		}

		finalSurface := dc.SurfaceView()
		if finalSurface == nil {
			return
		}

		var (
			surfaceW, surfaceH uint32 = dc.SurfaceSize()
			width, height      int    = int(surfaceW), int(surfaceH)
		)

		if width <= 0 {
			width = startWidth
		}

		if height <= 0 {
			height = startHeight
		}

		var aspect float32 = float32(width) / float32(height)

		if renderer == nil {
			if renderer, err = ocean.NewRenderer(provider.Device(), provider.SurfaceFormat()); err != nil {
				log.Panicf("create ocean renderer: %v", err)
			}

			log.Infof("GoGPU backend: %s\n", dc.Backend())
		}

		if !ensure2DContext(provider) {
			return
		}

		// Pass 1: draw the 3D scene directly to the swapchain. The ocean pass owns
		// the clear. This avoids the previous offscreen-scene -> gg -> swapchain
		// composition chain and removes the expensive gg frame from the hot path.
		if err = renderer.Draw(finalSurface, ocean.FrameUniformsFromCamera(cam, aspect, float32(time.Since(start).Seconds()))); err != nil {
			log.Errorf("draw ocean: %v", err)
			return
		}

		var (
			gpuName string = gpuApp.GPUContextProvider().AdapterInfo().Name
			elapsed        = time.Since(start).Seconds()
		)

		// Pass 2: draw the gctx2d HUD directly over the already-rendered swapchain
		// image. Flush(..., nil) uses LoadOpLoad, so transparent/partial-alpha HUD
		// geometry blends over the ocean instead of clearing it.
		ctx.Begin(width, height)
		ctx.BeginPath()
		ctx.RoundedRect(hudX, hudY, hudWidth, hudHeight, 8)
		ctx.ClosePath()
		ctx.SetFillStyle(gctx2d.RGBA(0, 0, 0, 0.38))
		ctx.Fill()

		ctx.SetStrokeStyle(gctx2d.RGBA(1, 1, 1, 0.14))
		ctx.SetLineWidth(2)
		ctx.Stroke()

		ctx.SetFont(16, nil, gctx2d.FontWeightMedium)
		ctx.SetFillStyle(gctx2d.ColorWhite)
		ctx.FillText(fmt.Sprintf("FPS: %d", fps), hudX+12, hudY+28)
		ctx.FillText("GPU: "+gpuName, hudX+12, hudY+52)
		ctx.FillText(fmt.Sprintf("Cam: %.1f %.1f %.1f", cam.Position.X, cam.Position.Y, cam.Position.Z), hudX+12, hudY+76)
		ctx.FillText(fmt.Sprintf("Time: %.2fs", elapsed), hudX+12, hudY+100)

		if err = ctx.Flush(finalSurface, nil); err != nil {
			log.Errorf("flush 2D HUD overlay: %v", err)
			return
		}

		frameCount++
		if time.Since(lastSecond) >= time.Second {
			lastSecond = time.Now()
			fps = frameCount
			frameCount = 0
		}
	})

	gpuApp.OnClose(func() {
		release2D()

		if renderer != nil {
			renderer.Release()
			renderer = nil
		}
	})

	return gpuApp.Run()
}
