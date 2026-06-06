const PI: f32 = 3.141592653589793;

struct Frame {
    view_proj: mat4x4<f32>,

    camera_pos: vec3<f32>,
    aspect: f32,

    sun_dir: vec3<f32>,
    time: f32,

    plane_size: f32,
    plane_resolution: f32,
    spectrum_resolution: f32,
    fft_height_scale: f32,

    camera_right: vec3<f32>,
    _pad0: f32,

    camera_up: vec3<f32>,
    _pad1: f32,

    camera_forward: vec3<f32>,
    _pad2: f32,

    height_scale: f32,
    chop_scale: f32,
    time_scale: f32,
    normal_detail_scale: f32,

    foam_amount: f32,
    foam_threshold: f32,
    reflection_amount: f32,
    roughness: f32,

    wind_speed: f32,
    wind_dir_x: f32,
    wind_dir_z: f32,
    spectrum_scale: f32,

    short_wave_damping: f32,
    debug_mode: f32,
    ocean_origin: vec2<f32>,

    cascade0: vec4<f32>,
    cascade1: vec4<f32>,
    cascade2: vec4<f32>,
    cascade3: vec4<f32>,

    cascade_count: f32,
    _pad3: vec3<f32>,
};

struct OceanSample {
    height: f32,
    slope_x: f32,
    slope_z: f32,
    disp_x: f32,
    disp_z: f32,
    jacobian: f32,
    foam: f32,
    edge_fade: f32,
    cascade_mix: vec3<f32>,
    _pad: f32,
};

struct VSOut {
    @builtin(position) clip_pos: vec4<f32>,
    @location(0) world_pos: vec3<f32>,
    @location(1) base_normal: vec3<f32>,
    @location(2) uv: vec2<f32>,
    @location(3) height: f32,
    @location(4) slope_mag: f32,
    @location(5) jacobian: f32,
    @location(6) foam: f32,
    @location(7) edge_fade: f32,
    @location(8) surface_xz: vec2<f32>,
    @location(9) cascade_mix: vec3<f32>,
};

@group(0) @binding(0) var<uniform> frame: Frame;
@group(0) @binding(1) var<storage, read> ocean_samples: array<OceanSample>;

fn saturate(x: f32) -> f32 {
    return clamp(x, 0.0, 1.0);
}

fn hash21(p: vec2<f32>) -> f32 {
    let q = fract(vec2<f32>(
        dot(p, vec2<f32>(127.1, 311.7)),
        dot(p, vec2<f32>(269.5, 183.3))
    ));
    return fract(sin(q.x + q.y) * 43758.5453123);
}

fn noise2(p: vec2<f32>) -> f32 {
    let i = floor(p);
    let f = fract(p);
    let u = f * f * (3.0 - 2.0 * f);

    let a = hash21(i);
    let b = hash21(i + vec2<f32>(1.0, 0.0));
    let c = hash21(i + vec2<f32>(0.0, 1.0));
    let d = hash21(i + vec2<f32>(1.0, 1.0));
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

fn fbm2(p0: vec2<f32>) -> f32 {
    var p = p0;
    var amp = 0.54;
    var sum = 0.0;
    var norm = 0.0;
    for (var i = 0u; i < 4u; i = i + 1u) {
        sum = sum + noise2(p) * amp;
        norm = norm + amp;
        p = p * 2.07 + vec2<f32>(13.7, 9.2);
        amp = amp * 0.52;
    }
    return sum / max(norm, 1e-4);
}

fn ridge01(x: f32) -> f32 {
    return 1.0 - abs(x * 2.0 - 1.0);
}

fn detail_domain_warp(world_xz: vec2<f32>) -> vec2<f32> {
    let t = frame.time * max(frame.time_scale, 0.0);
    let a = fbm2(world_xz * 0.033 + vec2<f32>(t * 0.022, -t * 0.016));
    let b = fbm2(world_xz * 0.051 + vec2<f32>(17.0 - t * 0.013, 9.0 + t * 0.020));
    let c = sin(dot(world_xz, vec2<f32>(0.015, -0.024)) + t * 0.16);
    return vec2<f32>(a - 0.5, b - 0.5) * 3.6 + vec2<f32>(c, -c) * 0.42;
}

fn reflection_cloud_noise(ray: vec3<f32>) -> f32 {
    let rd = normalize(ray);
    let p = rd.xz / max(0.30, rd.y + 0.62);
    return noise2(p * 0.12 + vec2<f32>(4.0, 9.0));
}

fn wave_weight(wavelength: f32, footprint: f32) -> f32 {
    return smoothstep(0.25, 1.2, wavelength / max(footprint, 0.001));
}

fn rotate2(v: vec2<f32>, cs: vec2<f32>) -> vec2<f32> {
    return vec2<f32>(v.x * cs.x - v.y * cs.y, v.x * cs.y + v.y * cs.x);
}

fn add_detail_wave(
    g: vec2<f32>,
    world_xz: vec2<f32>,
    dir: vec2<f32>,
    wavelength: f32,
    amp: f32,
    speed: f32,
    phase_offset: f32,
    footprint: f32
) -> vec2<f32> {
    let k = 2.0 * PI / wavelength;
    let t = frame.time * max(frame.time_scale, 0.0);
    let phase = dot(world_xz, dir) * k + t * speed + phase_offset;
    return g + dir * (cos(phase) * amp * k * wave_weight(wavelength, footprint));
}

fn add_vertex_chop_wave(
    acc: vec4<f32>,
    world_xz: vec2<f32>,
    dir: vec2<f32>,
    wavelength: f32,
    amp: f32,
    speed: f32,
    phase_offset: f32
) -> vec4<f32> {
    let k = 2.0 * PI / wavelength;
    let t = frame.time * max(frame.time_scale, 0.0);
    let phase = dot(world_xz, dir) * k + t * speed + phase_offset;
    let s = sin(phase);
    let c = cos(phase);
    // Narrower, steeper peaks. Long procedural bands made the surface look like
    // huge soft blobs and were expensive across the whole high-density mesh.
    let shaped_height = s * (0.62 + 0.38 * abs(s));
    let shaped_slope = c * (0.70 + 0.95 * abs(s));
    return acc + vec4<f32>(
        shaped_height * amp,
        dir.x * shaped_slope * amp * k,
        dir.y * shaped_slope * amp * k,
        0.0
    );
}

fn vertex_chop(world_xz: vec2<f32>, local_xz: vec2<f32>) -> vec3<f32> {
    let wind = normalize(vec2<f32>(frame.wind_dir_x, frame.wind_dir_z));
    let cross_wind = vec2<f32>(-wind.y, wind.x);
    let t = frame.time * max(frame.time_scale, 0.0);
    let dist = max(abs(local_xz.x), abs(local_xz.y));
    let fade = (1.0 - smoothstep(360.0, 1500.0, dist));

    // One cheap bend is enough to break alignment. The previous six-wave + two
    // sine bend path was the main FPS killer.
    let bend = vec2<f32>(
        sin(dot(world_xz, vec2<f32>(0.047, -0.033)) + t * 0.19),
        sin(dot(world_xz, vec2<f32>(-0.029, 0.041)) - t * 0.16)
    ) * 0.42;
    let p = world_xz + bend;

    var acc = vec4<f32>(0.0);
    acc = add_vertex_chop_wave(acc, p, detail_dir(2u, wind, cross_wind), 13.5, 0.070,  1.12, 0.6);
    acc = add_vertex_chop_wave(acc, p, detail_dir(6u, wind, cross_wind), 8.4,  0.056, -1.55, 2.4);
    acc = add_vertex_chop_wave(acc, p, detail_dir(11u, wind, cross_wind), 5.3,  0.038,  2.10, 4.8);

    return acc.xyz * fade;
}

fn detail_dir(i: u32, wind: vec2<f32>, cross_wind: vec2<f32>) -> vec2<f32> {
    if i == 0u { return normalize(wind * 1.00 + cross_wind * 0.08); }
    if i == 1u { return normalize(wind * 0.90 + cross_wind * 0.44); }
    if i == 2u { return normalize(wind * 0.66 + cross_wind * 0.76); }
    if i == 3u { return normalize(wind * 0.32 + cross_wind * 0.95); }
    if i == 4u { return normalize(-wind * 0.04 + cross_wind * 1.00); }
    if i == 5u { return normalize(-wind * 0.38 + cross_wind * 0.92); }
    if i == 6u { return normalize(-wind * 0.70 + cross_wind * 0.72); }
    if i == 7u { return normalize(-wind * 0.94 + cross_wind * 0.34); }
    if i == 8u { return normalize(-wind * 0.92 - cross_wind * 0.38); }
    if i == 9u { return normalize(-wind * 0.58 - cross_wind * 0.82); }
    if i == 10u { return normalize(-wind * 0.12 - cross_wind * 0.99); }
    if i == 11u { return normalize(wind * 0.24 - cross_wind * 0.97); }
    if i == 12u { return normalize(wind * 0.58 - cross_wind * 0.81); }
    if i == 13u { return normalize(wind * 0.86 - cross_wind * 0.50); }
    if i == 14u { return normalize(wind * 0.46 + cross_wind * 0.89); }
    return normalize(-wind * 0.48 + cross_wind * 0.88);
}

fn surface_detail_signal(world_xz: vec2<f32>, footprint: f32) -> f32 {
    let t = frame.time * max(frame.time_scale, 0.0);
    let wind = normalize(vec2<f32>(frame.wind_dir_x, frame.wind_dir_z));
    let cross_wind = vec2<f32>(-wind.y, wind.x);
    let warp = detail_domain_warp(world_xz) * 0.34;
    let p = world_xz + warp;

    // Build sharper, irregular water texture from warped noise and ridged bands.
    // This avoids the fine FFT/mesh grid while keeping a crisp WoWS-like surface.
    let a = ridge01(fbm2(vec2<f32>(dot(p, wind) * 0.112, dot(p, cross_wind) * 0.165) + vec2<f32>(t * 0.026, -t * 0.014)));
    let b = ridge01(fbm2(vec2<f32>(dot(p, wind) * 0.255, dot(p, cross_wind) * 0.392) + vec2<f32>(17.0 - t * 0.058, 5.0 + t * 0.042)));
    let c = ridge01(fbm2(rotate2(p * 0.560, vec2<f32>(0.819152, 0.573576)) + vec2<f32>(-7.0 + t * 0.105, 13.0 - t * 0.070)));
    let d = ridge01(fbm2(rotate2(p * 0.930, vec2<f32>(0.669131, -0.743145)) + vec2<f32>(29.0 - t * 0.158, -11.0 + t * 0.122)));
    let e = ridge01(fbm2(rotate2(p * 1.420, vec2<f32>(0.258819, 0.965926)) + vec2<f32>(43.0 + t * 0.228, 21.0 - t * 0.168)));

    let distance_filter = smoothstep(0.16, 1.10, 1.0 / max(footprint, 0.001));
    let coarse = a * 0.32 + b * 0.28 + c * 0.22;
    let fine = d * 0.12 + e * 0.06;
    return coarse + fine * distance_filter;
}

fn noise_gradient(world_xz: vec2<f32>, footprint: f32) -> vec2<f32> {
    let e = clamp(footprint * 0.30, 0.060, 0.72);
    let sx0 = surface_detail_signal(world_xz - vec2<f32>(e, 0.0), footprint);
    let sx1 = surface_detail_signal(world_xz + vec2<f32>(e, 0.0), footprint);
    let sz0 = surface_detail_signal(world_xz - vec2<f32>(0.0, e), footprint);
    let sz1 = surface_detail_signal(world_xz + vec2<f32>(0.0, e), footprint);
    return vec2<f32>(sx1 - sx0, sz1 - sz0) / max(2.0 * e, 1e-4);
}

fn detail_gradient(world_xz: vec2<f32>, footprint: f32) -> vec2<f32> {
    let wind = normalize(vec2<f32>(frame.wind_dir_x, frame.wind_dir_z));
    let cross_wind = vec2<f32>(-wind.y, wind.x);
    let warped_xz = world_xz + detail_domain_warp(world_xz) * 0.18;
    var g = vec2<f32>(0.0);

    // Fast analytic chop: more visible facets at smaller radius, without the
    // finite-difference FBM path that was burning fragment time.
    g = add_detail_wave(g, warped_xz, detail_dir(0u, wind, cross_wind), 6.20, 0.0084,  1.85, 0.4, footprint);
    g = add_detail_wave(g, warped_xz, detail_dir(2u, wind, cross_wind), 4.55, 0.0080, -2.35, 2.3, footprint);
    g = add_detail_wave(g, warped_xz, detail_dir(4u, wind, cross_wind), 3.35, 0.0067,  2.90, 5.0, footprint);
    g = add_detail_wave(g, warped_xz, detail_dir(6u, wind, cross_wind), 2.55, 0.0052, -3.35, 1.9, footprint);
    g = add_detail_wave(g, warped_xz, detail_dir(8u, wind, cross_wind), 1.95, 0.0038,  3.90, 3.3, footprint);
    g = add_detail_wave(g, warped_xz, detail_dir(12u, wind, cross_wind), 1.55, 0.0026, -4.50, 4.6, footprint);

    let modulation = mix(0.72, 1.18, fbm2(warped_xz * 0.092 + vec2<f32>(frame.time * 0.018, -frame.time * 0.011)));
    return g * modulation * clamp(frame.normal_detail_scale, 0.0, 3.1);
}

fn ocean_origin() -> vec2<f32> {
    return frame.ocean_origin;
}

@vertex
fn vs_main(
    @builtin(vertex_index) vertex_index: u32,
    @location(0) position: vec3<f32>,
    @location(1) _normal: vec3<f32>,
    @location(2) uv: vec2<f32>,
) -> VSOut {
    let s = ocean_samples[vertex_index];
    let base_xz = position.xz + ocean_origin();
    let edge = clamp(s.edge_fade, 0.0, 1.0);
    let displaced_xz = base_xz + vec2<f32>(s.disp_x, s.disp_z) * edge;
    let mid_chop = vertex_chop(displaced_xz, position.xz) * edge;
    let height = s.height * frame.height_scale + mid_chop.x;
    let world_pos = vec3<f32>(displaced_xz.x, height, displaced_xz.y);
    let slope = vec2<f32>(s.slope_x, s.slope_z) * frame.height_scale + mid_chop.yz;

    var out: VSOut;
    out.clip_pos = frame.view_proj * vec4<f32>(world_pos, 1.0);
    out.world_pos = world_pos;
    out.base_normal = normalize(vec3<f32>(-slope.x, 1.0, -slope.y));
    out.uv = uv;
    out.height = height;
    out.slope_mag = length(slope);
    out.jacobian = s.jacobian;
    out.foam = s.foam;
    out.edge_fade = edge;
    out.surface_xz = displaced_xz;
    out.cascade_mix = s.cascade_mix;
    return out;
}

fn water_reflection_sky_color(ray: vec3<f32>) -> vec3<f32> {
    let rd = normalize(ray);
    let up = saturate(rd.y * 0.5 + 0.5);

    // Reflection is a subdued sky tint, not a mirror coat. The WoWS sample keeps
    // most water readability in body color, foam, and self-shadow rather than glare.
    let horizon = vec3<f32>(0.32, 0.39, 0.46);
    let mid = vec3<f32>(0.16, 0.27, 0.39);
    let zenith = vec3<f32>(0.055, 0.12, 0.23);
    var col = mix(horizon, mid, smoothstep(0.0, 0.62, up));
    col = mix(col, zenith, smoothstep(0.48, 1.0, up));

    let sun_dot = saturate(dot(rd, normalize(frame.sun_dir)));
    let sun_glow = pow(sun_dot, 260.0) * 0.08 + pow(sun_dot, 44.0) * 0.018;
    let low_cloud = smoothstep(0.66, 0.92, reflection_cloud_noise(rd)) * smoothstep(-0.02, 0.30, rd.y);
    col = col + vec3<f32>(1.0, 0.88, 0.64) * sun_glow;
    col = mix(col, col + vec3<f32>(0.018, 0.020, 0.022), low_cloud * 0.018);
    return col;
}

fn fresnel_schlick(n_dot_v: f32) -> f32 {
    let f0 = 0.020;
    let x = clamp(1.0 - n_dot_v, 0.0, 1.0);
    return f0 + (1.0 - f0) * pow(x, 5.0);
}

fn ggx_d(n_dot_h: f32, alpha: f32) -> f32 {
    let a2 = alpha * alpha;
    let d = n_dot_h * n_dot_h * (a2 - 1.0) + 1.0;
    return a2 / max(PI * d * d, 1e-4);
}

fn smith_g1(n_dot_x: f32, alpha: f32) -> f32 {
    let k = (alpha + 1.0) * (alpha + 1.0) * 0.125;
    return n_dot_x / max(n_dot_x * (1.0 - k) + k, 1e-4);
}

fn water_body_color(height: f32, n: vec3<f32>, v: vec3<f32>, far: f32) -> vec3<f32> {
    let n_dot_v = saturate(dot(n, v));
    let view_path = 1.0 / max(n_dot_v, 0.26);
    let depth_approx = clamp(1.05 - height * 0.040 + far * 0.18, 0.58, 2.05);
    let optical_depth = view_path * depth_approx;

    // Lower-albedo water body. This keeps the base layer darker/clearer so normal
    // detail and reflection read through instead of flattening into pale blobs.
    let abyss = vec3<f32>(0.004, 0.018, 0.036);
    let deep = vec3<f32>(0.010, 0.034, 0.060);
    let blue1 = vec3<f32>(0.020, 0.049, 0.079);
    let blue2 = vec3<f32>(0.031, 0.064, 0.094);
    let blue3 = vec3<f32>(0.041, 0.078, 0.108);
    let far_blue = vec3<f32>(0.058, 0.086, 0.114);
    let absorption = vec3<f32>(1.10, 0.66, 0.40);
    let transmittance = exp(-absorption * optical_depth);

    var body = mix(abyss, deep, transmittance.b * 0.42);
    body = mix(body, blue1, smoothstep(-0.40, -0.12, height) * 0.26 * (1.0 - far * 0.22));
    body = mix(body, blue2, smoothstep(-0.14, 0.18, height) * 0.22 * (1.0 - far * 0.25));
    body = mix(body, blue3, smoothstep(0.20, 0.70, height) * 0.08 * (1.0 - far * 0.25));
    body = mix(body, far_blue, far * 0.20);
    return body;
}

fn foam_breakup(surface_xz: vec2<f32>, foam: f32, footprint: f32) -> f32 {
    let wind = normalize(vec2<f32>(frame.wind_dir_x, frame.wind_dir_z));
    let cross_wind = vec2<f32>(-wind.y, wind.x);
    let advected = surface_xz + wind * frame.time * 1.10 + cross_wind * sin(frame.time * 0.20) * 0.22;
    let streak_uv = vec2<f32>(dot(advected, wind) * 0.42, dot(advected, cross_wind) * 1.35);
    let cells = ridge01(fbm2(advected * 0.64 + vec2<f32>(0.0, frame.time * 0.08)));
    let streaks = ridge01(fbm2(streak_uv + vec2<f32>(frame.time * 0.14, -frame.time * 0.05)));
    let flecks = ridge01(fbm2(advected * 2.65 + vec2<f32>(17.0, 5.0) + wind * frame.time * 0.50));

    let blob_mask = smoothstep(0.54, 0.80, cells) * smoothstep(0.48, 0.84, streaks);
    let fleck_mask = smoothstep(0.78, 0.95, flecks);
    let breakup = clamp(blob_mask * 0.55 + fleck_mask * 0.36, 0.0, 1.0);
    let aa = smoothstep(0.28, 1.20, 0.95 / max(footprint, 0.001));
    return saturate(foam * mix(0.08, 0.82, breakup) * aa);
}

fn fine_crest_foam(surface_xz: vec2<f32>, height: f32, slope_mag: f32, footprint: f32) -> f32 {
    let wind = normalize(vec2<f32>(frame.wind_dir_x, frame.wind_dir_z));
    let cross_wind = vec2<f32>(-wind.y, wind.x);
    let p = surface_xz + wind * frame.time * 1.55;
    let crest_energy = smoothstep(0.24, 0.72, height) * smoothstep(0.52, 1.15, slope_mag);
    let streak = fbm2(vec2<f32>(dot(p, wind) * 0.72, dot(p, cross_wind) * 2.15));
    let speckle = fbm2(p * 3.7 + vec2<f32>(frame.time * 0.46, -frame.time * 0.22));
    let mask = smoothstep(0.56, 0.86, streak) * smoothstep(0.62, 0.94, speckle);
    let aa = smoothstep(0.18, 1.10, 1.0 / max(footprint, 0.001));
    return saturate(crest_energy * mask * aa * 0.42);
}

fn water_depth_variation(surface_xz: vec2<f32>, height: f32, slope_mag: f32, far: f32) -> f32 {
    let wind = normalize(vec2<f32>(frame.wind_dir_x, frame.wind_dir_z));
    let cross_wind = vec2<f32>(-wind.y, wind.x);
    let p = surface_xz + wind * frame.time * 0.08 + cross_wind * sin(frame.time * 0.11) * 0.9;

    // Replace broad cloudy whitening with darker, shorter-scale modulation.
    // This keeps local contrast and perceived height variance without the blotchy haze.
    let broad = fbm2(vec2<f32>(dot(p, wind) * 0.070, dot(p, cross_wind) * 0.105) + detail_domain_warp(p) * 0.003);
    let medium = ridge01(fbm2(vec2<f32>(dot(p, wind) * 0.210, dot(p, cross_wind) * 0.310) + vec2<f32>(23.0, -7.0)));
    let fine = ridge01(fbm2(rotate2(p * 0.620, vec2<f32>(0.906308, 0.422618)) + vec2<f32>(-11.0, 31.0)));
    let trough = 1.0 - smoothstep(-0.30, 0.08, height);
    let steep = smoothstep(0.38, 1.08, slope_mag);
    let noise_mix = broad * 0.16 + medium * 0.34 + fine * 0.24;

    return clamp(noise_mix * 0.16 + trough * 0.50 + steep * 0.05 - far * 0.06, 0.0, 1.0);
}

fn water_self_shadow(n: vec3<f32>, l: vec3<f32>, height: f32, slope_mag: f32, far: f32) -> f32 {
    let leeward = 1.0 - smoothstep(0.02, 0.52, dot(n, l));
    let trough = 1.0 - smoothstep(-0.42, 0.12, height);
    let steep = smoothstep(0.20, 0.95, slope_mag);
    return saturate((leeward * 0.24 + trough * 0.22 + steep * 0.11) * (1.0 - far * 0.58));
}

fn far_sea_color(view_dir: vec3<f32>, dist: f32) -> vec3<f32> {
    let deep = vec3<f32>(0.020, 0.044, 0.070);
    let mid = vec3<f32>(0.046, 0.074, 0.100);
    let horizon = vec3<f32>(0.130, 0.145, 0.164);
    let fog = smoothstep(780.0, 4700.0, dist);
    let grazing = smoothstep(-0.12, 0.24, view_dir.y);
    var col = mix(deep, mid, smoothstep(0.0, 0.58, fog));
    col = mix(col, horizon, clamp(fog * 0.68 + grazing * 0.24, 0.0, 1.0));
    return col;
}

fn wire_density(uv: vec2<f32>) -> f32 {
    let grid = uv * frame.plane_resolution;
    let fw = max(fwidth(grid), vec2<f32>(1e-4, 1e-4));
    let line = abs(fract(grid) - vec2<f32>(0.5, 0.5)) / fw;
    return 1.0 - saturate(min(line.x, line.y));
}

@fragment
fn fs_main(in: VSOut) -> @location(0) vec4<f32> {
    let debug_mode = i32(frame.debug_mode + 0.5);
    let dist = max(abs(in.surface_xz.x - frame.ocean_origin.x), abs(in.surface_xz.y - frame.ocean_origin.y));
    let far = smoothstep(650.0, 4200.0, dist);
    let edge = clamp(in.edge_fade, 0.0, 1.0);

    let v = normalize(frame.camera_pos - in.world_pos);
    let l = normalize(frame.sun_dir);

    let ddx_xz = dpdx(in.surface_xz);
    let ddy_xz = dpdy(in.surface_xz);
    let footprint = clamp(max(length(ddx_xz), length(ddy_xz)), 0.02, 32.0);

    let detail_fade = (1.0 - smoothstep(560.0, 2600.0, dist)) * edge;
    let detail_grad = detail_gradient(in.surface_xz, footprint) * (1.15 * detail_fade);
    var n = normalize(in.base_normal + vec3<f32>(-detail_grad.x, 0.0, -detail_grad.y));
    let filtered = normalize(vec3<f32>(n.x * 0.38, 1.0, n.z * 0.38));
    n = normalize(mix(n, filtered, clamp(far * 0.46 + (1.0 - edge) * 0.84, 0.0, 0.84)));

    let n_dot_v = saturate(dot(n, v));
    let n_dot_l = saturate(dot(n, l));
    let slope_mag = in.slope_mag + length(detail_grad) * 0.12;

    let fold_foam = smoothstep(frame.foam_threshold + 0.22, frame.foam_threshold - 0.02, in.jacobian);
    let crest_foam = smoothstep(0.42, 0.92, in.height) * smoothstep(0.66, 1.35, slope_mag);
    let fine_foam = fine_crest_foam(in.surface_xz, in.height, slope_mag, footprint);
    var foam = saturate(fold_foam * 0.14 + crest_foam * 0.22 + fine_foam * 0.32);
    foam = foam_breakup(in.surface_xz, max(foam, in.foam), footprint) * edge;

    var body = water_body_color(in.height, n, v, far);
    let depth_variation = water_depth_variation(in.surface_xz, in.height, slope_mag, far);
    let self_shadow = water_self_shadow(n, l, in.height, slope_mag, far);
    body = body * mix(0.68, 0.88, depth_variation);
    body = body * (1.0 - self_shadow * 0.88);
    let fresnel = fresnel_schlick(n_dot_v);
    let extreme_grazing = smoothstep(0.07, 0.0, n_dot_v);
    let reflection_cap = mix(0.040, 0.150, extreme_grazing);
    let reflection_weight = clamp(fresnel * frame.reflection_amount * 0.24, 0.0, reflection_cap) * edge;

    // Subtle volume/crest response makes real geometry visible without turning the
    // whole sea white. This is the missing readability layer in the flat screenshot.
    let sun_face = pow(n_dot_l, 1.85) * (1.0 - far * 0.48);
    let crest_lift = smoothstep(0.20, 0.62, in.height) * smoothstep(0.40, 1.10, slope_mag);
    let facet_lift = pow(saturate(n_dot_l * (1.0 - n_dot_v) + 0.05), 4.4) * smoothstep(0.32, 1.18, slope_mag);
    body = body + vec3<f32>(0.003, 0.010, 0.018) * sun_face * 0.05;
    body = body + vec3<f32>(0.004, 0.012, 0.020) * crest_lift * 0.035;
    body = body + vec3<f32>(0.003, 0.008, 0.012) * facet_lift * 0.035;
    body = mix(body, vec3<f32>(0.010, 0.036, 0.064), smoothstep(-0.62, -0.24, in.height) * 0.22 * (1.0 - far));

    let r = reflect(-v, n);
    let reflected = water_reflection_sky_color(r);

    let rough = clamp(frame.roughness + far * 0.08 + foam * 0.18 + clamp(slope_mag * 0.006, 0.0, 0.022), 0.74, 0.965);
    let h = normalize(l + v);
    let n_dot_h = saturate(dot(n, h));
    let v_dot_h = saturate(dot(v, h));
    let alpha = max(rough * rough, 0.05);
    let d = ggx_d(n_dot_h, alpha);
    let g = smith_g1(n_dot_v, alpha) * smith_g1(n_dot_l, alpha);
    let f_spec = fresnel_schlick(v_dot_h);
    let spec = (d * g * f_spec) / max(4.0 * n_dot_v * n_dot_l, 0.05);
    let sun_specular = vec3<f32>(0.88, 0.90, 0.86) * spec * n_dot_l * (1.0 - foam) * edge * 0.00013;

    // Keep body/transmission dominant. Reflections add sky color at grazing angles;
    // they no longer replace the water with a shiny plastic sheet.
    var color = body * (1.0 - reflection_weight * 0.10) + reflected * reflection_weight + sun_specular;
    let foam_col = vec3<f32>(0.70, 0.74, 0.73);
    color = mix(color, foam_col, smoothstep(0.32, 0.92, foam) * 0.24);

    let far_col = far_sea_color(normalize(in.world_pos - frame.camera_pos), dist);
    let distance_haze = smoothstep(1650.0, 5400.0, dist);
    let edge_haze = 1.0 - smoothstep(0.04, 0.82, edge);
    color = mix(color, far_col, clamp(distance_haze * 0.54 + edge_haze * 0.96, 0.0, 0.96));

    if debug_mode == 0 {
        let w = wire_density(in.uv);
        return vec4(vec3<f32>(0.05, 0.25, 0.38) + vec3<f32>(w), 1.0);
    }
    if debug_mode == 2 {
        let hdbg = clamp(in.height * 0.20 + 0.5, 0.0, 1.0);
        return vec4(vec3<f32>(hdbg), 1.0);
    }
    if debug_mode == 3 {
        return vec4(vec3<f32>(clamp(slope_mag * 0.55, 0.0, 1.0)), 1.0);
    }
    if debug_mode == 4 {
        return vec4(n * 0.5 + 0.5, 1.0);
    }
    if debug_mode == 5 {
        return vec4(vec3<f32>(foam), 1.0);
    }
    if debug_mode == 6 {
        return vec4(in.cascade_mix, 1.0);
    }
    if debug_mode == 7 {
        return vec4(vec3<f32>(reflection_weight), 1.0);
    }
    if debug_mode == 8 {
        return vec4(vec3<f32>(fresnel), 1.0);
    }
    if debug_mode == 9 {
        let body_only = 1.0 - exp(-body * 1.10);
        return vec4(pow(body_only, vec3<f32>(1.0 / 2.2)), 1.0);
    }

    color = 1.0 - exp(-color * 1.42);
    color = pow(max(color, vec3<f32>(0.0)), vec3<f32>(1.0 / 2.2));
    return vec4(color, 1.0);
}
