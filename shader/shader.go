package shader

import _ "embed"

// WaterWGSL is the current water render shader.
//
// The file lives in shader/ so later patches can add compute FFT, foam,
// reflection, and debug shaders without burying WGSL inside app code.
//
//go:embed water.wgsl
var WaterWGSL string

// OceanInitWGSL initializes the persistent H0(k) mode texture once.
//
//go:embed ocean_init.wgsl
var OceanInitWGSL string

// OceanEvolveWGSL evolves H0(k) into H(k,t) each frame.
//
//go:embed ocean_evolve.wgsl
var OceanEvolveWGSL string

// OceanFFTWGSL runs the staged inverse FFT scaffold over the evolved spectral
// modes. Cascades remain stacked vertically in one mode texture.
//
//go:embed ocean_fft.wgsl
var OceanFFTWGSL string

// OceanSpectrumWGSL expands the FFT tile output into the raw ocean field
// texture sampled by the filter/render path.
//
//go:embed ocean_spectrum.wgsl
var OceanSpectrumWGSL string

// OceanFilterWGSL stabilizes the raw field into the texture sampled by the
// projected-grid renderer. Keeping this as a distinct pass gives us the first
// ping-pong data path needed for later FFT stages.
//
//go:embed ocean_filter.wgsl
var OceanFilterWGSL string
