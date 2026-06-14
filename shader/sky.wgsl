struct FrameUniforms {
    resolution_time_grid: vec4<f32>,
    view_proj: mat4x4<f32>,
    camera_pos_fov: vec4<f32>,
    camera_right_maxdist: vec4<f32>,
    camera_up_aspect: vec4<f32>,
    camera_forward_water: vec4<f32>,
    water_params0: vec4<f32>,
    spectrum_params: vec4<f32>,
    water_params1: vec4<f32>,
};

@group(0) @binding(0)
var<uniform> frame: FrameUniforms;

struct SkyOut {
    @builtin(position) position: vec4<f32>,
    @location(0) ray: vec3<f32>,
};

fn hash21(p: vec2<f32>) -> f32 {
    return fract(sin(dot(p, vec2<f32>(127.1, 311.7))) * 43758.5453123);
}

fn noise2(p: vec2<f32>) -> f32 {
    let i = floor(p);
    let f = fract(p);
    let u = f * f * (vec2<f32>(3.0, 3.0) - 2.0 * f);
    let a = hash21(i + vec2<f32>(0.0, 0.0));
    let b = hash21(i + vec2<f32>(1.0, 0.0));
    let c = hash21(i + vec2<f32>(0.0, 1.0));
    let d = hash21(i + vec2<f32>(1.0, 1.0));
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

fn fbm2(p: vec2<f32>) -> f32 {
    var q = p;
    var amp = 0.52;
    var sum = 0.0;
    var norm = 0.0;
    for (var i = 0; i < 4; i = i + 1) {
        sum += noise2(q) * amp;
        norm += amp;
        q = mat2x2<f32>(1.63, 1.12, -1.12, 1.63) * q + vec2<f32>(17.7, -9.2);
        amp *= 0.50;
    }
    return sum / max(norm, 0.0001);
}

fn camera_ray_from_ndc(ndc: vec2<f32>) -> vec3<f32> {
    let tan_half_fovy = frame.camera_pos_fov.w;
    let aspect = frame.camera_up_aspect.w;
    let right = frame.camera_right_maxdist.xyz;
    let up = frame.camera_up_aspect.xyz;
    let forward = frame.camera_forward_water.xyz;
    return normalize(forward + right * (ndc.x * aspect * tan_half_fovy) + up * (ndc.y * tan_half_fovy));
}

@vertex
fn vs_main(@builtin(vertex_index) vertex_index: u32) -> SkyOut {
    var positions = array<vec2<f32>, 3>(
        vec2<f32>(-1.0, -3.0),
        vec2<f32>( 3.0,  1.0),
        vec2<f32>(-1.0,  1.0)
    );
    let pos = positions[vertex_index];
    var out: SkyOut;
    out.position = vec4<f32>(pos, 0.0, 1.0);
    out.ray = camera_ray_from_ndc(pos);
    return out;
}

@fragment
fn fs_main(in: SkyOut) -> @location(0) vec4<f32> {
    let dir = normalize(in.ray);
    let up = clamp(dir.y * 0.5 + 0.5, 0.0, 1.0);
    let horizon = vec3<f32>(0.30, 0.40, 0.42);
    let mid = vec3<f32>(0.17, 0.29, 0.38);
    let zenith = vec3<f32>(0.050, 0.110, 0.185);
    var sky = mix(horizon, mid, smoothstep(0.04, 0.55, up));
    sky = mix(sky, zenith, smoothstep(0.50, 1.0, up));

    let cloud_uv = dir.xz / max(0.10 + dir.y * 0.80, 0.12) + vec2<f32>(frame.resolution_time_grid.z * 0.0020, -frame.resolution_time_grid.z * 0.0008);
    let cloud = smoothstep(0.50, 0.75, fbm2(cloud_uv * 0.72 + vec2<f32>(13.7, -4.2)));
    let cloud_col = mix(vec3<f32>(0.24, 0.29, 0.30), vec3<f32>(0.62, 0.66, 0.64), up);
    sky = mix(sky, cloud_col, cloud * 0.18);

    let sun_dir = normalize(vec3<f32>(-0.36, 0.78, -0.50));
    let sun_core = pow(max(dot(dir, sun_dir), 0.0), 420.0) * 1.25;
    let sun_halo = pow(max(dot(dir, sun_dir), 0.0), 24.0) * 0.16;
    sky += vec3<f32>(1.0, 0.82, 0.55) * (sun_core + sun_halo);

    // Subtle atmosphere near the horizon; do not make it white, because the
    // ocean will reflect this and lose contrast.
    sky = mix(sky, horizon, (1.0 - up) * 0.12);
    return vec4<f32>(sky, 1.0);
}
