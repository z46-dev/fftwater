package shader

import _ "embed"

// SkyWGSL is the procedural skybox shader used as the water reflection source.
//go:embed sky.wgsl
var SkyWGSL string
