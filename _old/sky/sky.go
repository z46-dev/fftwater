package sky

import (
	"fmt"

	rl "github.com/gen2brain/raylib-go/raylib"
)

type Dome struct {
	mesh                                                      rl.Mesh
	material                                                  rl.Material
	shader                                                    rl.Shader
	locSunDir, locCameraPos, locTime, locEnvironmentMode      int32
	sunDirUniform, cameraPosUniform, timeUniform, modeUniform []float32
}

// Create a new sky dome with the given vertex and fragment shader paths.
func New(vertexPath, fragmentPath string) (dome *Dome, err error) {
	var shader rl.Shader = rl.LoadShader(vertexPath, fragmentPath)
	if shader.ID == 0 {
		err = fmt.Errorf("failed to load sky shader")
	}

	var (
		mesh     rl.Mesh     = rl.GenMeshSphere(1, 48, 24)
		material rl.Material = rl.LoadMaterialDefault()
	)

	material.Shader = shader
	dome = &Dome{
		mesh:               mesh,
		material:           material,
		shader:             shader,
		locSunDir:          rl.GetShaderLocation(shader, "sunDirection"),
		locCameraPos:       rl.GetShaderLocation(shader, "cameraPosition"),
		locTime:            rl.GetShaderLocation(shader, "time"),
		locEnvironmentMode: rl.GetShaderLocation(shader, "environmentMode"),

		sunDirUniform:    make([]float32, 3),
		cameraPosUniform: make([]float32, 3),
		timeUniform:      make([]float32, 1),
		modeUniform:      make([]float32, 1),
	}

	return
}

// Update the sky dome's shader uniforms based on the current time, sun direction, and camera position.
func (d *Dome) Update(t float32, sunDir rl.Vector3, cameraPos rl.Vector3, environmentMode int32) {
	d.sunDirUniform[0] = sunDir.X
	d.sunDirUniform[1] = sunDir.Y
	d.sunDirUniform[2] = sunDir.Z
	d.cameraPosUniform[0] = cameraPos.X
	d.cameraPosUniform[1] = cameraPos.Y
	d.cameraPosUniform[2] = cameraPos.Z
	d.timeUniform[0] = t
	d.modeUniform[0] = float32(environmentMode)

	setShaderVec3(d.shader, d.locSunDir, d.sunDirUniform)
	setShaderVec3(d.shader, d.locCameraPos, d.cameraPosUniform)
	setShaderFloat(d.shader, d.locTime, d.timeUniform)
	setShaderFloat(d.shader, d.locEnvironmentMode, d.modeUniform)
}

// Draw the sky dome at the given camera position. The dome is scaled up and translated to always be centered on the camera.
func (d *Dome) Draw(cameraPos rl.Vector3) {
	var transform rl.Matrix = rl.MatrixMultiply(
		rl.MatrixScale(900, 900, 900),
		rl.MatrixTranslate(cameraPos.X, cameraPos.Y, cameraPos.Z),
	)

	rl.DisableBackfaceCulling()
	rl.DisableDepthMask()
	rl.DrawMesh(d.mesh, d.material, transform)
	rl.EnableDepthMask()
	rl.EnableBackfaceCulling()
}

// Clean up resources used by the sky dome.
func (d *Dome) Close() {
	rl.UnloadMesh(&d.mesh)
	rl.UnloadMaterial(d.material)
}

func setShaderVec3(shader rl.Shader, loc int32, value []float32) {
	if loc >= 0 {
		rl.SetShaderValue(shader, loc, value, rl.ShaderUniformVec3)
	}
}

func setShaderFloat(shader rl.Shader, loc int32, value []float32) {
	if loc >= 0 {
		rl.SetShaderValue(shader, loc, value, rl.ShaderUniformFloat)
	}
}
