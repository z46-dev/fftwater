package app

import (
	"fmt"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"sync"
	"sync/atomic"
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
	hudWidth  = 760
	hudHeight = 142
)

const (
	debugModeFinal = iota
	debugModeHeight
	debugModeDisplacement
	debugModeGradient
	debugModeMoments
	debugModeFoamHistory
	debugModeVariation
	debugModeRoughness
	debugModeInteraction
	debugModeCount
)

func debugModeLabel(mode int) string {
	switch mode {
	case debugModeHeight:
		return "height"
	case debugModeDisplacement:
		return "displacement"
	case debugModeGradient:
		return "gradient"
	case debugModeMoments:
		return "moments"
	case debugModeFoamHistory:
		return "foam history"
	case debugModeVariation:
		return "variation"
	case debugModeRoughness:
		return "roughness"
	case debugModeInteraction:
		return "ship interaction"
	default:
		return "final"
	}
}

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
				WithBackend(gogpu.BackendGo).WithFullscreen(),
		)

		start               time.Time = time.Now()
		look                inputDeltaAccumulator
		scroll              inputDeltaAccumulator
		ctx                 *gctx2d.Context
		cam                 *WaterCamera = NewWaterCamera()
		renderer            *WaterRenderer
		pointerSource       gpucontext.PointerEventSource
		scrollSource        interface{ OnScroll(func(float64, float64)) }
		debugMode           int                   = debugModeFromEnvironment(os.Getenv("FFTWATER_DEBUG_MODE"))
		shipAA              bool                  = os.Getenv("FFTWATER_SHIP_AA") != ""
		shipReflections     ShipReflectionQuality = parseShipReflectionQuality(os.Getenv("FFTWATER_SHIP_REFLECTIONS"))
		shipShadows         bool                  = os.Getenv("FFTWATER_SHIP_SHADOWS") != ""
		aaToggle            atomic.Bool
		reflectionCycle     atomic.Bool
		shadowToggle        atomic.Bool
		lastAAToggle        atomic.Int64
		lastReflectionCycle atomic.Int64
		lastShadowToggle    atomic.Int64
		captureDir          string = os.Getenv("FFTWATER_CAPTURE_DIR")
		captureLate         bool   = os.Getenv("FFTWATER_CAPTURE_LATE") != ""
		captureIndex        int
		logFPS              bool = os.Getenv("FFTWATER_LOG_FPS") != ""
		ok                  bool
	)
	applyCameraOverride(cam, os.Getenv("FFTWATER_CAMERA"))

	if pointerSource, ok = gpuApp.EventSource().(gpucontext.PointerEventSource); ok {
		pointerSource.OnPointer(func(ev gpucontext.PointerEvent) {
			if ev.Type != gpucontext.PointerMove || ev.PointerType != gpucontext.PointerTypeMouse {
				return
			}

			if !ev.Buttons.HasRight() && gpuApp.CursorMode() != gpucontext.CursorModeLocked {
				return
			}

			look.Add(-float32(ev.DeltaX), float32(ev.DeltaY))
		})
	}

	if scrollSource, ok = gpuApp.EventSource().(interface{ OnScroll(func(float64, float64)) }); ok {
		scrollSource.OnScroll(func(dx, dy float64) {
			scroll.Add(float32(dx), float32(dy))
		})
	}

	// Letter key codes are unreliable on some Wayland/XKB combinations. Text
	// input preserves the user's actual keys. Timestamps suppress key repeat.
	gpuApp.EventSource().OnTextInput(func(text string) {
		now := time.Now().UnixNano()
		switch text {
		case "f", "F":
			previous := lastAAToggle.Load()
			if now-previous >= int64(300*time.Millisecond) && lastAAToggle.CompareAndSwap(previous, now) {
				aaToggle.Store(true)
			}
		case "r", "R":
			previous := lastReflectionCycle.Load()
			if now-previous >= int64(300*time.Millisecond) && lastReflectionCycle.CompareAndSwap(previous, now) {
				reflectionCycle.Store(true)
			}
		case "q", "Q":
			previous := lastShadowToggle.Load()
			if now-previous >= int64(300*time.Millisecond) && lastShadowToggle.CompareAndSwap(previous, now) {
				shadowToggle.Store(true)
			}
		}
	})

	gpuApp.OnUpdate(func(dt float64) {
		var in = gpuApp.Input()

		if in != nil && in.Mouse().Pressed(input.MouseButtonRight) {
			gpuApp.SetCursorMode(gpucontext.CursorModeLocked)
		} else if gpuApp.CursorMode() != gpucontext.CursorModeNormal {
			gpuApp.SetCursorMode(gpucontext.CursorModeNormal)
		}

		if in != nil {
			if in.Keyboard().JustPressed(input.KeyTab) {
				debugMode = (debugMode + 1) % debugModeCount
			}

		}

		if aaToggle.Swap(false) {
			shipAA = !shipAA
			if renderer != nil {
				renderer.SetShipAA(shipAA)
			}
			log.Infof("4x ship AA: %t\n", shipAA)
		}
		if reflectionCycle.Swap(false) {
			shipReflections = (shipReflections + 1) % (ShipReflectionHigh + 1)
			if renderer != nil {
				renderer.SetShipReflectionQuality(shipReflections)
			}
			log.Infof("ship reflections: %s\n", shipReflections.Label())
		}
		if shadowToggle.Swap(false) {
			shipShadows = !shipShadows
			if renderer != nil {
				renderer.SetShipShadows(shipShadows)
			}
			log.Infof("ship shadows: %t\n", shipShadows)
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
			renderer.SetShipAA(shipAA)
			renderer.SetShipReflectionQuality(shipReflections)
			renderer.SetShipShadows(shipShadows)

			log.Infof("GoGPU backend: %s\n", dc.Backend())
		}

		renderer.SetDebugMode(debugMode)

		frame := NewWaterFrame(surfaceW, surfaceH, float32(elapsed), aspect, cam)
		if err = renderer.Draw(finalSurface, frame); err != nil {
			log.Errorf("draw water: %v", err)
			return
		}

		captureTimes := [...]float64{2.0, 4.0, 6.0}
		if captureLate {
			captureTimes = [...]float64{6.0, 12.0, 16.0}
		}
		if captureDir != "" && captureIndex < len(captureTimes) && elapsed >= captureTimes[captureIndex] {
			path := filepath.Join(captureDir, fmt.Sprintf("fftwater-%02d.png", captureIndex+1))
			if err = renderer.CapturePNG(path, frame); err != nil {
				log.Errorf("capture screenshot: %v\n", err)
			} else {
				log.Infof("captured screenshot: %s\n", path)
			}
			captureIndex++
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
		ctx.FillText(fmt.Sprintf("Cam: %.1f %.1f %.1f", cam.Position.X, cam.Position.Y, cam.Position.Z), hudX+12, hudY+76)
		aaLabel := "off"
		if renderer.ShipAAEnabled() {
			aaLabel = "4x"
		}
		ctx.FillText(fmt.Sprintf("Time: %.2fs   Height: %.2f   View: %s   Ship AA [F]: %s", elapsed, renderer.WaveHeightScale(), debugModeLabel(debugMode), aaLabel), hudX+12, hudY+100)
		shadowLabel := "off"
		if renderer.ShipShadowsEnabled() {
			shadowLabel = "on"
		}
		ctx.FillText(fmt.Sprintf("Ship reflections [R]: %s   Ship shadows [Q]: %s", renderer.ShipReflectionQuality().Label(), shadowLabel), hudX+12, hudY+124)

		if err = ctx.Flush(finalSurface, nil); err != nil {
			log.Errorf("flush 2D HUD overlay: %v", err)
			return
		}

		frameCount++
		if time.Since(lastSecond) >= time.Second {
			lastSecond = time.Now()
			fps = frameCount
			frameCount = 0
			if logFPS {
				log.Infof("FPS: %d\n", fps)
			}
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

// applyCameraOverride accepts "x,y,z,yaw,pitch" for deterministic visual
// regression captures without changing the normal startup camera.
func applyCameraOverride(cam *WaterCamera, value string) {
	if cam == nil || value == "" {
		return
	}
	parts := strings.Split(value, ",")
	if len(parts) != 5 {
		return
	}
	values := [5]float32{}
	for i, part := range parts {
		v, err := strconv.ParseFloat(strings.TrimSpace(part), 32)
		if err != nil {
			return
		}
		values[i] = float32(v)
	}
	cam.Position = Vec3{X: values[0], Y: values[1], Z: values[2]}
	cam.Yaw = values[3]
	cam.Pitch = clamp32(values[4], waterCameraMinPitch, waterCameraMaxPitch)
}

func debugModeFromEnvironment(value string) int {
	mode, err := strconv.Atoi(strings.TrimSpace(value))
	if err != nil || mode < debugModeFinal || mode >= debugModeCount {
		return debugModeFinal
	}
	return mode
}

func parseShipReflectionQuality(value string) ShipReflectionQuality {
	switch strings.ToLower(strings.TrimSpace(value)) {
	case "1", "low":
		return ShipReflectionLow
	case "2", "medium", "med":
		return ShipReflectionMedium
	case "3", "high":
		return ShipReflectionHigh
	default:
		return ShipReflectionOff
	}
}
