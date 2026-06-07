struct FrameUniforms {
    // x = width, y = height, z = time, w = projected-grid cell count.
    resolution_time_grid: vec4<f32>,
    view_proj: mat4x4<f32>,

    // xyz = camera position, w = tan(vertical_fov / 2).
    camera_pos_fov: vec4<f32>,
    // xyz = camera right, w = max projected distance.
    camera_right_maxdist: vec4<f32>,
    // xyz = camera up, w = aspect ratio.
    camera_up_aspect: vec4<f32>,
    // xyz = camera forward, w = water plane height.
    camera_forward_water: vec4<f32>,

    // x = grid snap, y = chop scale, z = foam gain, w = detail gain.
    water_params0: vec4<f32>,
};

@group(0) @binding(0)
var<uniform> frame: FrameUniforms;

struct VertexOut {
    @builtin(position) position: vec4<f32>,
    @location(0) world_pos: vec3<f32>,
    @location(1) base_xz: vec2<f32>,
    @location(2) view_distance: f32,
};

struct WaveContrib {
    height: f32,
    disp: vec2<f32>,
    slope: vec2<f32>,
    curvature: f32,
};

const TAU: f32 = 6.28318530718;
const G: f32 = 9.81;

// The projected grid must extend beyond the exact framebuffer rectangle.
// Waves horizontally displace vertices after ray/plane intersection; without
// guard coverage those displaced edge vertices expose the clear color at the
// bottom and sides of the frame. The asymmetric bottom guard is intentional:
// near-camera water occupies more vertical screen area than the far horizon.
const GRID_GUARD_X: f32 = 0.18;
const GRID_GUARD_TOP: f32 = 0.08;
const GRID_GUARD_BOTTOM: f32 = 0.38;
const MIN_RAY_PLANE_Y: f32 = 0.00015;

fn empty_wave() -> WaveContrib {
    var w: WaveContrib;
    w.height = 0.0;
    w.disp = vec2<f32>(0.0, 0.0);
    w.slope = vec2<f32>(0.0, 0.0);
    w.curvature = 0.0;
    return w;
}

fn add_wave(a: WaveContrib, b: WaveContrib) -> WaveContrib {
    var r: WaveContrib;
    r.height = a.height + b.height;
    r.disp = a.disp + b.disp;
    r.slope = a.slope + b.slope;
    r.curvature = a.curvature + b.curvature;
    return r;
}

fn wave_component(
    p: vec2<f32>,
    dir: vec2<f32>,
    wavelength: f32,
    amplitude: f32,
    speed_scale: f32,
    steepness: f32,
    phase: f32,
) -> WaveContrib {
    let d = normalize(dir);
    let k = TAU / wavelength;
    let omega = sqrt(G * k) * speed_scale;
    let theta = k * dot(d, p) - omega * frame.resolution_time_grid.z + phase;
    let s = sin(theta);
    let c = cos(theta);

    var w: WaveContrib;
    w.height = amplitude * s;
    w.disp = d * (steepness * frame.water_params0.y * amplitude * c);
    w.slope = d * (amplitude * k * c);
    w.curvature = -amplitude * k * k * s;
    return w;
}

fn spectrum_large_mid(p: vec2<f32>) -> WaveContrib {
    // This is intentionally structured as a small spectral cascade rather than
    // arbitrary sine noise. The large band carries swell, the middle band gives
    // visible chop, and the short band injects the fast overlapping motion that
    // arcade naval water relies on before/alongside FFT displacement textures.
    var w = empty_wave();

    // Long swell: low curvature, high spatial coherence.
    w = add_wave(w, wave_component(p, vec2<f32>( 0.88,  0.28), 168.0, 1.45, 0.92, 0.68, 0.10));
    w = add_wave(w, wave_component(p, vec2<f32>( 0.52,  0.86), 126.0, 0.92, 1.05, 0.55, 1.70));
    w = add_wave(w, wave_component(p, vec2<f32>(-0.74,  0.47),  94.0, 0.58, 1.18, 0.48, 3.10));

    // Mid chop: shorter wavelengths, more crossing energy, stronger curvature.
    w = add_wave(w, wave_component(p, vec2<f32>( 0.96, -0.10), 46.0, 0.34, 1.55, 0.82, 2.40));
    w = add_wave(w, wave_component(p, vec2<f32>( 0.30,  0.95), 34.0, 0.25, 1.95, 0.78, 4.30));
    w = add_wave(w, wave_component(p, vec2<f32>(-0.58,  0.81), 25.0, 0.18, 2.30, 0.73, 5.20));
    w = add_wave(w, wave_component(p, vec2<f32>(-0.92, -0.22), 18.0, 0.115, 2.75, 0.62, 0.80));

    return w;
}

fn spectrum_detail(p: vec2<f32>) -> WaveContrib {
    var w = empty_wave();
    let t = frame.resolution_time_grid.z;

    // The shortest components are evaluated in the fragment shader so they do
    // not need a dense geometric tessellation. These are the visual analog of
    // WoWS-style small fast ripples/detail normals, not screen-space banding.
    w = add_wave(w, wave_component(p + vec2<f32>(t * 3.4, -t * 1.6), vec2<f32>( 0.72, -0.69), 9.5, 0.052, 3.4, 0.34, 1.9));
    w = add_wave(w, wave_component(p + vec2<f32>(-t * 2.1, t * 2.9), vec2<f32>(-0.18,  0.98), 6.6, 0.035, 4.2, 0.28, 3.7));
    w = add_wave(w, wave_component(p + vec2<f32>(t * 4.6, t * 1.1), vec2<f32>(-0.94, -0.33), 4.1, 0.020, 5.3, 0.22, 5.4));
    w = add_wave(w, wave_component(p + vec2<f32>(-t * 5.5, -t * 2.7), vec2<f32>( 0.37,  0.93), 2.7, 0.010, 7.0, 0.16, 0.6));
    return w;
}

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

fn projected_grid_uv(vertex_index: u32) -> vec2<f32> {
    let n = max(u32(frame.resolution_time_grid.w), 2u);
    let cell_vertex = vertex_index % 6u;
    let cell_index = vertex_index / 6u;
    let x = cell_index % n;
    let y = cell_index / n;

    var cx: u32 = 0u;
    var cy: u32 = 0u;
    switch cell_vertex {
        case 0u: { cx = 0u; cy = 0u; }
        case 1u: { cx = 1u; cy = 0u; }
        case 2u: { cx = 0u; cy = 1u; }
        case 3u: { cx = 0u; cy = 1u; }
        case 4u: { cx = 1u; cy = 0u; }
        default: { cx = 1u; cy = 1u; }
    }

    return vec2<f32>(f32(x + cx), f32(y + cy)) / f32(n);
}

fn projected_grid_ndc(uv: vec2<f32>) -> vec2<f32> {
    let left = -1.0 - GRID_GUARD_X;
    let right = 1.0 + GRID_GUARD_X;
    let top = 1.0 + GRID_GUARD_TOP;
    let bottom = -1.0 - GRID_GUARD_BOTTOM;

    return vec2<f32>(
        left + (right - left) * uv.x,
        top + (bottom - top) * uv.y
    );
}

fn camera_ray_from_ndc(ndc: vec2<f32>) -> vec3<f32> {
    let tan_half_fovy = frame.camera_pos_fov.w;
    let aspect = frame.camera_up_aspect.w;
    let right = frame.camera_right_maxdist.xyz;
    let up = frame.camera_up_aspect.xyz;
    let forward = frame.camera_forward_water.xyz;
    return normalize(
        forward +
        right * (ndc.x * aspect * tan_half_fovy) +
        up * (ndc.y * tan_half_fovy)
    );
}

fn intersect_water_plane(ndc: vec2<f32>) -> vec2<f32> {
    let cam = frame.camera_pos_fov.xyz;
    let dir = camera_ray_from_ndc(ndc);
    let water_y = frame.camera_forward_water.w;
    let max_dist = frame.camera_right_maxdist.w;

    // Use the real water-plane intersection when the ray points at the ocean.
    // For rays that are nearly parallel or above the horizon, push the sample
    // to the far projected edge instead of cutting the mesh to a circular cap.
    // The previous radial cap produced the visible saw-tooth side and bottom
    // edges because adjacent grid cells hit different points of that circle.
    var t = max_dist;
    if abs(dir.y) > MIN_RAY_PLANE_Y {
        let plane_t = (water_y - cam.y) / dir.y;
        if plane_t > 0.0 {
            t = min(plane_t, max_dist);
        }
    }

    let hit = cam + dir * max(t, 0.0);

    // Camera-relative snap stabilizes distant projected vertices without
    // making the water pattern itself screen-space. The shader still samples
    // all waves in absolute world coordinates.
    let snap = max(frame.water_params0.x, 0.001);
    return floor(hit.xz / snap) * snap;
}

@vertex
fn vs_main(@builtin(vertex_index) vertex_index: u32) -> VertexOut {
    let uv = projected_grid_uv(vertex_index);
    let ndc = projected_grid_ndc(uv);

    let base_xz = intersect_water_plane(ndc);
    let large_mid_wave = spectrum_large_mid(base_xz);

    let water_y = frame.camera_forward_water.w;
    let world = vec3<f32>(
        base_xz.x + large_mid_wave.disp.x,
        water_y + large_mid_wave.height,
        base_xz.y + large_mid_wave.disp.y
    );

    var out: VertexOut;
    out.position = frame.view_proj * vec4<f32>(world, 1.0);
    out.world_pos = world;
    out.base_xz = base_xz;
    out.view_distance = length(world - frame.camera_pos_fov.xyz);
    return out;
}

fn ocean_normal(base_xz: vec2<f32>) -> vec3<f32> {
    let large_mid_wave = spectrum_large_mid(base_xz);
    let detail = spectrum_detail(base_xz * 1.18);
    let slope = large_mid_wave.slope + detail.slope * frame.water_params0.w;
    return normalize(vec3<f32>(-slope.x, 1.0, -slope.y));
}

fn crest_foam(base_xz: vec2<f32>, view_distance: f32) -> f32 {
    let large_mid_wave = spectrum_large_mid(base_xz);
    let detail = spectrum_detail(base_xz * 1.18);
    let slope_mag = length(large_mid_wave.slope + detail.slope * 0.72);
    let crest = smoothstep(0.020, 0.095, -large_mid_wave.curvature);
    let breaking = smoothstep(0.34, 0.88, slope_mag) * crest;

    let t = frame.resolution_time_grid.z;
    let wind_streak = noise2(base_xz * vec2<f32>(0.028, 0.072) + vec2<f32>(t * 0.12, -t * 0.38));
    let lace = noise2(base_xz * 0.210 + vec2<f32>(-t * 0.80, t * 0.46));
    let breakup = smoothstep(0.42, 0.82, wind_streak) * smoothstep(0.36, 0.74, lace);
    let distance_fade = 1.0 - smoothstep(850.0, 1700.0, view_distance);

    return clamp(breaking * mix(0.25, 1.0, breakup) * distance_fade * frame.water_params0.z, 0.0, 1.0);
}

@fragment
fn fs_main(in: VertexOut) -> @location(0) vec4<f32> {
    let cam = frame.camera_pos_fov.xyz;
    let n = ocean_normal(in.base_xz);
    let view = normalize(cam - in.world_pos);
    let light = normalize(vec3<f32>(-0.42, 0.78, -0.46));
    let half_vec = normalize(light + view);

    let n_dot_v = clamp(dot(n, view), 0.0, 1.0);
    let n_dot_l = clamp(dot(n, light), 0.0, 1.0);
    let n_dot_h = clamp(dot(n, half_vec), 0.0, 1.0);
    let fresnel = 0.020 + 0.980 * pow(1.0 - n_dot_v, 5.0);

    let large_mid_wave = spectrum_large_mid(in.base_xz);
    let detail = spectrum_detail(in.base_xz * 1.18);
    let slope_mag = length(large_mid_wave.slope + detail.slope * 0.72);
    let foam = crest_foam(in.base_xz, in.view_distance);

    let deep = vec3<f32>(0.004, 0.045, 0.075);
    let body = vec3<f32>(0.010, 0.125, 0.165);
    let lit_body = vec3<f32>(0.035, 0.245, 0.270);
    let horizon_sky = vec3<f32>(0.48, 0.63, 0.68);
    let zenith_sky = vec3<f32>(0.25, 0.43, 0.58);

    let distance_t = smoothstep(45.0, 820.0, in.view_distance);
    let height_t = clamp(large_mid_wave.height * 0.12 + 0.52, 0.0, 1.0);
    var volume = mix(body, deep, distance_t * 0.68);
    volume = mix(volume, lit_body, height_t * 0.38 * n_dot_l);

    let refl_dir = reflect(-view, n);
    let sky_t = clamp(refl_dir.y * 0.52 + 0.38, 0.0, 1.0);
    let sky = mix(horizon_sky, zenith_sky, sky_t);

    let roughness = clamp(0.055 + slope_mag * 0.16 + foam * 0.30, 0.055, 0.46);
    let spec_power = mix(220.0, 32.0, roughness);
    let sparkle_mask = smoothstep(0.58, 0.92, noise2(in.base_xz * 0.36 + vec2<f32>(frame.resolution_time_grid.z * 1.2, -frame.resolution_time_grid.z * 0.7)));
    let specular = pow(n_dot_h, spec_power) * (0.24 + sparkle_mask * 0.34) * n_dot_l * (1.0 - foam * 0.72);

    var color = mix(volume, sky, fresnel * 0.78);
    color += specular * vec3<f32>(1.0, 0.94, 0.82);

    let foam_color = vec3<f32>(0.82, 0.90, 0.88);
    color = mix(color, foam_color, foam);

    let aerial = smoothstep(620.0, 1800.0, in.view_distance);
    color = mix(color, horizon_sky * 0.72, aerial * 0.42);

    // Subtle contrast control; avoid the over-polished plastic look.
    color = color / (color + vec3<f32>(0.92, 0.92, 0.92));
    color = pow(max(color, vec3<f32>(0.0, 0.0, 0.0)), vec3<f32>(1.0 / 2.2));
    return vec4<f32>(color, 1.0);
}
