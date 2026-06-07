package app

import (
	"fmt"
	"sync"
	"time"

	"github.com/gogpu/gogpu"
	"github.com/gogpu/gogpu/input"
	"github.com/gogpu/gpucontext"
	"github.com/gogpu/wgpu"
	"github.com/z46-dev/gctx2d"
	"github.com/z46-dev/golog"
)

const (
	startWidth  = 1280
	startHeight = 720

	hudX      = 16
	hudY      = 16
	hudWidth  = 640
	hudHeight = 166
)

type inputDeltaAccumulator struct {
	mu sync.Mutex
	x  float32
	y  float32
}

func (a *inputDeltaAccumulator) Add(dx, dy float32) {
	a.mu.Lock()
	defer a.mu.Unlock()

	a.x += dx
	a.y += dy
}

func (a *inputDeltaAccumulator) Take() (dx, dy float32) {
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

		start         time.Time = time.Now()
		look          inputDeltaAccumulator
		scroll        inputDeltaAccumulator
		ctx           *gctx2d.Context
		cam           *WaterCamera = NewWaterCamera()
		renderer      *WaterRenderer
		pointerSource gpucontext.PointerEventSource
		scrollSource  interface{ OnScroll(func(float64, float64)) }
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

	if scrollSource, ok = gpuApp.EventSource().(interface{ OnScroll(func(float64, float64)) }); ok {
		scrollSource.OnScroll(func(dx, dy float64) {
			scroll.Add(float32(dx), float32(dy))
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

		var scrollY float32
		if _, scrollY = scroll.Take(); scrollY != 0 {
			fastZoom := false
			if in != nil {
				keyboard := in.Keyboard()
				fastZoom = keyboard.Pressed(input.KeyShiftLeft) || keyboard.Pressed(input.KeyShiftRight)
			}
			cam.ApplyZoomScroll(-scrollY, fastZoom)
		}

		cam.Update(float32(dt), in)
	})

	var (
		provider        gogpu.DeviceProvider
		frameCount, fps int
		lastSecond      time.Time = time.Now()
		err             error
	)

	var ensure2DContext func(provider gogpu.DeviceProvider) bool = func(provider gogpu.DeviceProvider) bool {
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

		var finalSurface *wgpu.TextureView = dc.SurfaceView()
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

		var (
			elapsed float64 = time.Since(start).Seconds()
			aspect  float32 = float32(width) / float32(height)
		)

		if renderer == nil {
			if renderer, err = NewWaterRenderer(provider.Device(), provider.SurfaceFormat()); err != nil {
				log.Panicf("create water renderer: %v", err)
			}

			log.Infof("GoGPU backend: %s", dc.Backend())
		}

		if err = renderer.Draw(finalSurface, NewWaterFrame(surfaceW, surfaceH, float32(elapsed), aspect, cam)); err != nil {
			log.Errorf("draw water: %v", err)
			return
		}

		if !ensure2DContext(provider) {
			return
		}

		var gpuName string = gpuApp.GPUContextProvider().AdapterInfo().Name

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
		ctx.FillText("Water: raw spectral field -> filtered field -> projected grid", hudX+12, hudY+76)
		ctx.FillText(fmt.Sprintf("Cam: %.1f %.1f %.1f", cam.Position.X, cam.Position.Y, cam.Position.Z), hudX+12, hudY+100)
		ctx.FillText(fmt.Sprintf("Time: %.2fs", elapsed), hudX+12, hudY+124)
		ctx.FillText("Move: WASD, wheel zooms, Shift accelerates. Hold RMB to look", hudX+12, hudY+148)

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
		if ctx != nil {
			ctx.Release()
			ctx = nil
		}

		if renderer != nil {
			renderer.Release()
			renderer = nil
		}
	})

	return gpuApp.Run()
}
