package shader

import _ "embed"

// WaterWGSL is the current water render shader.
//
// The file lives in shader/ so later patches can add compute FFT, foam,
// reflection, and debug shaders without burying WGSL inside app code.
//
//go:embed water.wgsl
var WaterWGSL string
