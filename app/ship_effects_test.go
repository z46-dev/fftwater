package app

import "testing"

func TestParseShipReflectionQuality(t *testing.T) {
	tests := map[string]ShipReflectionQuality{
		"":       ShipReflectionOff,
		"off":    ShipReflectionOff,
		"low":    ShipReflectionLow,
		"1":      ShipReflectionLow,
		"medium": ShipReflectionMedium,
		"med":    ShipReflectionMedium,
		"2":      ShipReflectionMedium,
		"high":   ShipReflectionHigh,
		"3":      ShipReflectionHigh,
	}
	for input, want := range tests {
		if got := parseShipReflectionQuality(input); got != want {
			t.Errorf("parseShipReflectionQuality(%q) = %v, want %v", input, got, want)
		}
	}
}

func TestShipReflectionQualityLabels(t *testing.T) {
	tests := map[ShipReflectionQuality]string{
		ShipReflectionOff:    "off",
		ShipReflectionLow:    "low",
		ShipReflectionMedium: "medium",
		ShipReflectionHigh:   "high",
	}
	for quality, want := range tests {
		if got := quality.Label(); got != want {
			t.Errorf("quality %d label = %q, want %q", quality, got, want)
		}
	}
}
