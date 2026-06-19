package app

import (
	"math"
	"testing"
)

func TestDefaultShipsUseDistinctModels(t *testing.T) {
	ships := DefaultShips()
	if len(ships) != 3 {
		t.Fatalf("DefaultShips() returned %d ships, want 3", len(ships))
	}

	want := []struct {
		name string
		path string
	}{
		{name: "Roosevelt", path: "assets/models/Roosevelt.glb"},
		{name: "Shinano", path: "assets/models/Shinano.glb"},
		{name: "Essex", path: "assets/models/Essex.glb"},
	}

	seen := make(map[string]bool, len(ships))
	for i, ship := range ships {
		if ship.Name != want[i].name {
			t.Errorf("ship %d name = %q, want %q", i, ship.Name, want[i].name)
		}
		if ship.ModelPath != want[i].path {
			t.Errorf("ship %d model = %q, want %q", i, ship.ModelPath, want[i].path)
		}
		if seen[ship.ModelPath] {
			t.Errorf("ship %d reuses model %q", i, ship.ModelPath)
		}
		seen[ship.ModelPath] = true
	}
}

func TestShipInteractionsPreserveWakeConfiguration(t *testing.T) {
	ships := DefaultShips()
	initializeShipMotion(ships)
	renderer := &ShipRenderer{ships: ships}
	interactions := renderer.Interactions()
	if len(interactions) != 3 {
		t.Fatalf("Interactions() returned %d ships, want 3", len(interactions))
	}
	for i, interaction := range interactions {
		if interaction.Speed <= 0 || interaction.Strength <= 0 || interaction.Beam <= 0 || interaction.Draft <= 0 {
			t.Errorf("interaction %d has invalid wake parameters: %+v", i, interaction)
		}
		length := math.Hypot(float64(interaction.Forward.X), float64(interaction.Forward.Z))
		if math.Abs(length-1) > 1e-5 {
			t.Errorf("interaction %d forward length = %f, want 1", i, length)
		}
	}
}

func TestDefaultFleetSpeedRatiosAndTurns(t *testing.T) {
	ships := DefaultShips()
	if got := ships[1].Speed / ships[0].Speed; math.Abs(float64(got-1.0/3.0)) > 1e-6 {
		t.Errorf("port speed ratio = %f, want 1/3", got)
	}
	if got := ships[2].Speed / ships[0].Speed; math.Abs(float64(got-2.0/3.0)) > 1e-6 {
		t.Errorf("starboard speed ratio = %f, want 2/3", got)
	}
	if ships[1].TurnRate >= 0 {
		t.Errorf("port turn rate = %f, want left/negative", ships[1].TurnRate)
	}
	if ships[2].TurnRate <= 0 {
		t.Errorf("starboard turn rate = %f, want right/positive", ships[2].TurnRate)
	}
	if ships[0].TurnRate != 0 {
		t.Errorf("center turn rate = %f, want straight", ships[0].TurnRate)
	}
}

func TestShipMotionMatchesConfiguredVelocity(t *testing.T) {
	ships := DefaultShips()
	initializeShipMotion(ships)
	renderer := &ShipRenderer{ships: ships}
	const t1 = float32(12)
	renderer.UpdateMotion(t1)

	center := renderer.ships[0]
	if math.Abs(float64(center.Position.X-center.initialPosition.X)) > 1e-5 {
		t.Errorf("center ship moved sideways: x = %f", center.Position.X)
	}
	wantZ := center.initialPosition.Z + center.Speed*t1
	if math.Abs(float64(center.Position.Z-wantZ)) > 1e-4 {
		t.Errorf("center z = %f, want %f", center.Position.Z, wantZ)
	}
	if renderer.ships[1].Heading >= renderer.ships[1].initialHeading {
		t.Errorf("port ship did not turn left")
	}
	if renderer.ships[2].Heading <= renderer.ships[2].initialHeading {
		t.Errorf("starboard ship did not turn right")
	}
}

func initializeShipMotion(ships []Ship) {
	for i := range ships {
		ships[i].initialPosition = ships[i].Position
		ships[i].initialHeading = ships[i].Heading
	}
}
