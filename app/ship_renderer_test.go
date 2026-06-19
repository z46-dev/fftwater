package app

import "testing"

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
