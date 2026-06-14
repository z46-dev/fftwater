package shader

import _ "embed"

// ShipWGSL renders loaded GLB ship meshes into the water scene.
//go:embed ship.wgsl
var ShipWGSL string
