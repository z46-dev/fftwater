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
    @location(0) ndc: vec2<f32>,
};

fn hash31(p: vec3<f32>) -> f32 {
    return fract(sin(dot(p, vec3<f32>(127.1, 311.7, 74.7))) * 43758.5453123);
}

fn noise3(p: vec3<f32>) -> f32 {
    let i = floor(p);
    let f = fract(p);
    // Quintic interpolation removes the visible square boundaries produced by
    // cubic 2D value noise when clouds cover a large part of the sky.
    let u = f * f * f * (f * (f * 6.0 - vec3<f32>(15.0)) + vec3<f32>(10.0));
    let x00 = mix(hash31(i), hash31(i + vec3<f32>(1.0, 0.0, 0.0)), u.x);
    let x10 = mix(hash31(i + vec3<f32>(0.0, 1.0, 0.0)), hash31(i + vec3<f32>(1.0, 1.0, 0.0)), u.x);
    let x01 = mix(hash31(i + vec3<f32>(0.0, 0.0, 1.0)), hash31(i + vec3<f32>(1.0, 0.0, 1.0)), u.x);
    let x11 = mix(hash31(i + vec3<f32>(0.0, 1.0, 1.0)), hash31(i + vec3<f32>(1.0, 1.0, 1.0)), u.x);
    return mix(mix(x00, x10, u.y), mix(x01, x11, u.y), u.z);
}

fn fbm3(p: vec3<f32>) -> f32 {
    var q = p;
    var amp = 0.54;
    var sum = 0.0;
    var norm = 0.0;
    for (var i = 0; i < 3; i = i + 1) {
        sum += noise3(q) * amp;
        norm += amp;
        q = vec3<f32>(
            q.y * 1.71 + q.z * 0.83,
            q.z * 1.57 - q.x * 0.91,
            q.x * 1.63 + q.y * 0.72
        ) + vec3<f32>(11.7, -6.2, 4.8);
        amp *= 0.47;
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
    out.ndc = pos;
    return out;
}

@fragment
fn fs_main(in: SkyOut) -> @location(0) vec4<f32> {
    // Reconstruct after interpolation. Interpolating normalized corner rays
    // makes the sky bend and slide incorrectly during camera rotation.
    let dir = camera_ray_from_ndc(in.ndc);
    // Zero elevation is the horizon. Mapping dir.y into 0.5 at the horizon
    // caused the abrupt dark band in the previous gradient.
    let elevation = clamp(max(dir.y, 0.0), 0.0, 1.0);
    let horizon = vec3<f32>(0.52, 0.72, 0.89);
    let mid = vec3<f32>(0.16, 0.50, 0.88);
    let zenith = vec3<f32>(0.055, 0.27, 0.70);
    var sky = mix(horizon, mid, smoothstep(0.0, 0.46, elevation));
    sky = mix(sky, zenith, smoothstep(0.42, 1.0, elevation));

    // Layered direction-space FBM creates broad cumulus groups with smaller
    // lobes. Keeping it in direction space avoids a seam and keeps the cloud
    // field fixed while the camera rotates.
    let cloud_time = frame.resolution_time_grid.z * 0.006;
    let cloud_plane = dir.xz / max(dir.y + 0.20, 0.20);
    let cloud_pos = vec3<f32>(
        cloud_plane.x * 0.62 + cloud_time,
        dir.y * 1.7 + 0.41,
        cloud_plane.y * 0.62 - cloud_time * 0.58
    );
    let broad = fbm3(cloud_pos * 0.72 + vec3<f32>(2.3, -1.1, 5.7));
    let warp = fbm3(cloud_pos * 1.42 + vec3<f32>(broad * 2.8, -broad * 1.7, broad * 2.1));
    let detail = noise3(cloud_pos * 6.2 + vec3<f32>(-7.2, 3.4, 11.8));
    let cloud_signal = broad * 0.62 + warp * 0.30 + detail * 0.08;
    // Broad directional banks keep the lower threshold from turning the whole
    // sky overcast. The FBM cuts irregular edges and smaller holes into them.
    let bank_left = smoothstep(0.78, 0.95, dot(dir, normalize(vec3<f32>(-0.66, 0.30, -0.69))));
    let bank_mid = smoothstep(0.81, 0.96, dot(dir, normalize(vec3<f32>(0.02, 0.29, -0.96))));
    let bank_right = smoothstep(0.80, 0.95, dot(dir, normalize(vec3<f32>(0.67, 0.25, -0.70))));
    let cloud_bank = clamp(max(bank_left, max(bank_mid, bank_right)), 0.0, 1.0);
    let cloud_visibility = smoothstep(0.018, 0.10, elevation) * (1.0 - smoothstep(0.80, 1.0, elevation));
    let cloud_base = smoothstep(0.390, 0.555, cloud_signal) * cloud_bank * cloud_visibility;
    let cloud_core = smoothstep(0.505, 0.655, cloud_signal) * cloud_bank * cloud_visibility;
    let cloud_edge = max(cloud_base - cloud_core, 0.0);
    let cloud_light = mix(vec3<f32>(0.62, 0.68, 0.74), vec3<f32>(0.98, 0.965, 0.93), cloud_core);
    sky *= 1.0 - cloud_edge * 0.18;
    sky = mix(sky, cloud_light, cloud_base * (0.66 + cloud_core * 0.26));

    let horizon_haze = exp(-elevation * 13.0);
    sky = mix(sky, vec3<f32>(0.68, 0.79, 0.86), horizon_haze * 0.42);

    let sun_dir = normalize(vec3<f32>(-0.36, 0.78, -0.50));
    let sun_core = pow(max(dot(dir, sun_dir), 0.0), 520.0) * 1.35;
    let sun_halo = pow(max(dot(dir, sun_dir), 0.0), 18.0) * 0.10;
    sky += vec3<f32>(1.0, 0.82, 0.55) * (sun_core + sun_halo);

    sky = sky / (sky + vec3<f32>(0.62, 0.52, 0.42));
    sky = pow(max(sky, vec3<f32>(0.0)), vec3<f32>(1.0 / 1.28));
    return vec4<f32>(sky, 1.0);
}
