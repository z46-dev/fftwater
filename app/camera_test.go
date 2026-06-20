package app

import "testing"

func TestCameraHeightAllowsUnderwaterMovement(t *testing.T) {
	camera := NewWaterCamera()
	camera.Position.Y = -25
	camera.clampNavigableHeight()
	if camera.Position.Y != -25 {
		t.Fatalf("underwater camera height = %f, want -25", camera.Position.Y)
	}

	camera.Position.Y = waterCameraMinHeight - 1
	camera.clampNavigableHeight()
	if camera.Position.Y != waterCameraMinHeight {
		t.Errorf("minimum camera height = %f, want %f", camera.Position.Y, waterCameraMinHeight)
	}
}
