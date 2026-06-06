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

fn safe_normalize2(v: vec2<f32>) -> vec2<f32> {
    let l = length(v);
    if l < 1e-5 {
        return vec2<f32>(1.0, 0.0);
    }
    return v / l;
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
        p = p * 2.03 + vec2<f32>(13.7, 9.2);
        amp = amp * 0.50;
    }
    return sum / max(norm, 1e-4);
}

fn ridge01(x: f32) -> f32 {
    return 1.0 - abs(x * 2.0 - 1.0);
}

fn rotate2(v: vec2<f32>, cs: vec2<f32>) -> vec2<f32> {
    return vec2<f32>(v.x * cs.x - v.y * cs.y, v.x * cs.y + v.y * cs.x);
}

fn ocean_origin() -> vec2<f32> {
    return frame.ocean_origin;
}

fn wave_lod_weight(wavelength: f32, footprint: f32, dist: f32) -> f32 {
    let pixel_ok = smoothstep(0.95, 2.60, wavelength / max(footprint, 0.001));
    let far_ok = 1.0 - smoothstep(1600.0, 4400.0, dist / max(wavelength, 0.1));
    return pixel_ok * clamp(far_ok, 0.0, 1.0);
}

fn add_slope_wave(
    g: vec2<f32>,
    world_xz: vec2<f32>,
    dir: vec2<f32>,
    wavelength: f32,
    amp: f32,
    speed: f32,
    phase_offset: f32,
    footprint: f32,
    dist: f32
) -> vec2<f32> {
    let k = 2.0 * PI / wavelength;
    let t = frame.time * max(frame.time_scale, 0.0);
    let phase = dot(world_xz, dir) * k + t * speed + phase_offset;
    let w = wave_lod_weight(wavelength, footprint, dist);
    return g + dir * (cos(phase) * amp * k * w);
}

fn surface_signal(world_xz: vec2<f32>, footprint: f32, dist: f32) -> f32 {
    let wind = safe_normalize2(vec2<f32>(frame.wind_dir_x, frame.wind_dir_z));
    let cross_wind = vec2<f32>(-wind.y, wind.x);
    let t = frame.time * max(frame.time_scale, 0.0);

    // Domain-warped procedural slope field. This replaces most of the repeated
    // sine-band detail that caused the top-down tiling/stamp pattern.
    let warp0 = fbm2(world_xz * 0.018 + vec2<f32>(t * 0.011, -t * 0.007)) - 0.5;
    let warp1 = fbm2(rotate2(world_xz * 0.026, vec2<f32>(0.819152, 0.573576)) + vec2<f32>(11.0 - t * 0.008, 19.0 + t * 0.012)) - 0.5;
    let p = world_xz + vec2<f32>(warp0, warp1) * 3.4;

    let a = ridge01(fbm2(vec2<f32>(dot(p, wind) * 0.070, dot(p, cross_wind) * 0.115) + vec2<f32>(t * 0.018, -t * 0.010)));
    let b = ridge01(fbm2(rotate2(p * 0.155, vec2<f32>(0.642788, 0.766044)) + vec2<f32>(23.0 - t * 0.032, 7.0 + t * 0.021)));
    let c = ridge01(fbm2(rotate2(p * 0.355, vec2<f32>(0.258819, 0.965926)) + vec2<f32>(-31.0 + t * 0.070, 13.0 - t * 0.045)));
    let d = ridge01(fbm2(rotate2(p * 0.740, vec2<f32>(0.906308, -0.422618)) + vec2<f32>(41.0 - t * 0.135, -17.0 + t * 0.095)));

    let micro_ok = smoothstep(0.35, 1.25, 1.0 / max(footprint, 0.001)) * (1.0 - smoothstep(1800.0, 4200.0, dist));
    return a * 0.34 + b * 0.31 + c * 0.23 + d * 0.12 * micro_ok;
}

fn signal_gradient(world_xz: vec2<f32>, footprint: f32, dist: f32) -> vec2<f32> {
    let e = clamp(footprint * 0.62, 0.16, 1.15);
    let sx0 = surface_signal(world_xz - vec2<f32>(e, 0.0), footprint, dist);
    let sx1 = surface_signal(world_xz + vec2<f32>(e, 0.0), footprint, dist);
    let sz0 = surface_signal(world_xz - vec2<f32>(0.0, e), footprint, dist);
    let sz1 = surface_signal(world_xz + vec2<f32>(0.0, e), footprint, dist);
    return vec2<f32>(sx1 - sx0, sz1 - sz0) / max(2.0 * e, 1e-4);
}

fn normal_detail_gradient(world_xz: vec2<f32>, footprint: f32, dist: f32) -> vec2<f32> {
    let wind = safe_normalize2(vec2<f32>(frame.wind_dir_x, frame.wind_dir_z));
    let cross_wind = vec2<f32>(-wind.y, wind.x);
    let t = frame.time * max(frame.time_scale, 0.0);

    // Mostly stochastic/ridged gradient; only a few longer analytic waves remain.
    // This removes the obvious repeating rows in top-down views while preserving
    // wind-sea directionality at normal camera angles.
    var g = signal_gradient(world_xz, footprint, dist) * 0.42;

    let warp = vec2<f32>(
        fbm2(world_xz * 0.030 + vec2<f32>(t * 0.015, 8.0)) - 0.5,
        fbm2(rotate2(world_xz * 0.036, vec2<f32>(0.707107, 0.707107)) + vec2<f32>(-4.0, t * 0.018)) - 0.5
    ) * 1.8;
    let p = world_xz + warp;

    g = add_slope_wave(g, p, safe_normalize2(wind * 0.92 + cross_wind * 0.38), 8.8, 0.0090,  1.20, 0.3, footprint, dist);
    g = add_slope_wave(g, p, safe_normalize2(wind * 0.35 + cross_wind * 0.94), 5.6, 0.0062, -1.70, 2.1, footprint, dist);
    g = add_slope_wave(g, p, safe_normalize2(-wind * 0.40 + cross_wind * 0.92), 3.7, 0.0036,  2.30, 4.8, footprint, dist);

    let far_fade = 1.0 - smoothstep(2500.0, 5200.0, dist);
    return g * clamp(frame.normal_detail_scale, 0.0, 3.2) * far_fade;
}

fn sky_reflection_color(ray: vec3<f32>) -> vec3<f32> {
    let rd = normalize(ray);
    let up = saturate(rd.y * 0.5 + 0.5);
    let horizon = vec3<f32>(0.40, 0.46, 0.52);
    let mid = vec3<f32>(0.18, 0.30, 0.43);
    let zenith = vec3<f32>(0.060, 0.130, 0.250);
    var col = mix(horizon, mid, smoothstep(0.0, 0.62, up));
    col = mix(col, zenith, smoothstep(0.48, 1.0, up));

    let sun_dot = saturate(dot(rd, normalize(frame.sun_dir)));
    col = col + vec3<f32>(1.0, 0.86, 0.62) * (pow(sun_dot, 260.0) * 0.13 + pow(sun_dot, 48.0) * 0.020);
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

fn water_body_color(height: f32, slope_mag: f32, far: f32) -> vec3<f32> {
    // 1/9: narrow dark steel-blue ramp. No white lives here.
    let deep = vec3<f32>(0.006, 0.026, 0.048);
    let trough = vec3<f32>(0.010, 0.038, 0.066);
    let mid = vec3<f32>(0.026, 0.059, 0.091);
    let high = vec3<f32>(0.044, 0.083, 0.115);
    let horizon = vec3<f32>(0.075, 0.105, 0.132);

    var c = mix(deep, trough, smoothstep(-0.70, -0.22, height));
    c = mix(c, mid, smoothstep(-0.22, 0.16, height) * 0.46);
    c = mix(c, high, smoothstep(0.18, 0.66, height) * 0.16);
    c = mix(c, horizon, far * 0.28);

    // Slight blue-green lift on sharp facets, still not white.
    let facet = smoothstep(0.55, 1.65, slope_mag);
    c = mix(c, vec3<f32>(0.047, 0.085, 0.112), facet * 0.07 * (1.0 - far));
    return c;
}

fn sparse_foam(surface_xz: vec2<f32>, height: f32, slope_mag: f32, jacobian: f32, base_foam: f32, footprint: f32) -> f32 {
    // 6: sparse, advected crest/fold foam. It should be flecks/streaks only.
    let wind = safe_normalize2(vec2<f32>(frame.wind_dir_x, frame.wind_dir_z));
    let cross_wind = vec2<f32>(-wind.y, wind.x);
    let t = frame.time * max(frame.time_scale, 0.0);
    let adv = surface_xz + wind * t * 1.10 + cross_wind * sin(t * 0.23) * 0.32;

    let fold = smoothstep(frame.foam_threshold + 0.02, frame.foam_threshold - 0.12, jacobian);
    let crest = smoothstep(0.26, 0.84, height) * smoothstep(0.72, 1.80, slope_mag);
    let inherited = smoothstep(0.42, 0.92, base_foam);

    let streak_uv = vec2<f32>(dot(adv, wind) * 0.48, dot(adv, cross_wind) * 1.95);
    let streak = fbm2(streak_uv + vec2<f32>(t * 0.16, -t * 0.06));
    let fleck = fbm2(adv * 2.95 + vec2<f32>(19.0, 7.0) + wind * t * 0.45);
    let breakup = smoothstep(0.62, 0.88, streak) * 0.62 + smoothstep(0.72, 0.94, fleck) * 0.46;

    let aa = smoothstep(0.20, 1.40, 1.15 / max(footprint, 0.001));
    return saturate((fold * 0.35 + crest * 0.55 + inherited * 0.20) * breakup * frame.foam_amount * aa);
}

fn far_sea_color(view_dir: vec3<f32>, dist: f32) -> vec3<f32> {
    let deep = vec3<f32>(0.018, 0.043, 0.070);
    let mid = vec3<f32>(0.050, 0.080, 0.106);
    let horizon = vec3<f32>(0.130, 0.148, 0.168);
    let fog = smoothstep(760.0, 4700.0, dist);
    let grazing = smoothstep(-0.08, 0.28, view_dir.y);
    var col = mix(deep, mid, smoothstep(0.0, 0.62, fog));
    col = mix(col, horizon, clamp(fog * 0.58 + grazing * 0.22, 0.0, 1.0));
    return col;
}

fn wire_density(uv: vec2<f32>) -> f32 {
    let grid = uv * frame.plane_resolution;
    let fw = max(fwidth(grid), vec2<f32>(1e-4, 1e-4));
    let line = abs(fract(grid) - vec2<f32>(0.5, 0.5)) / fw;
    return 1.0 - saturate(min(line.x, line.y));
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
    let displaced_xz = base_xz + vec2<f32>(s.disp_x, s.disp_z) * edge * frame.chop_scale;
    let height = s.height * frame.height_scale;
    let slope = vec2<f32>(s.slope_x, s.slope_z) * frame.height_scale;

    var out: VSOut;
    out.clip_pos = frame.view_proj * vec4<f32>(displaced_xz.x, height, displaced_xz.y, 1.0);
    out.world_pos = vec3<f32>(displaced_xz.x, height, displaced_xz.y);
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

@fragment
fn fs_main(in: VSOut) -> @location(0) vec4<f32> {
    let debug_mode = i32(frame.debug_mode + 0.5);
    let rel = in.surface_xz - frame.ocean_origin;
    let dist = max(abs(rel.x), abs(rel.y));
    let far = smoothstep(700.0, 4300.0, dist);
    let edge = clamp(in.edge_fade, 0.0, 1.0);

    let v = normalize(frame.camera_pos - in.world_pos);
    let l = normalize(frame.sun_dir);

    let ddx_xz = dpdx(in.surface_xz);
    let ddy_xz = dpdy(in.surface_xz);
    let footprint = clamp(max(length(ddx_xz), length(ddy_xz)), 0.025, 42.0);

    let detail_grad = normal_detail_gradient(in.surface_xz, footprint, dist) * edge;
    var n = normalize(in.base_normal + vec3<f32>(-detail_grad.x, 0.0, -detail_grad.y));
    let filtered_n = normalize(vec3<f32>(n.x * 0.30, 1.0, n.z * 0.30));
    n = normalize(mix(n, filtered_n, clamp(far * 0.52 + (1.0 - edge) * 0.88, 0.0, 0.88)));

    let n_dot_v = saturate(dot(n, v));
    let n_dot_l = saturate(dot(n, l));
    let slope_mag = in.slope_mag + length(detail_grad) * 0.16;

    var body = water_body_color(in.height, slope_mag, far);

    // 1: darken troughs/faces; do not brighten broad depth patches.
    let leeward = 1.0 - smoothstep(0.04, 0.58, dot(n, l));
    let trough = 1.0 - smoothstep(-0.45, 0.08, in.height);
    let face_shadow = saturate(leeward * 0.18 + trough * 0.24 + smoothstep(0.95, 2.05, slope_mag) * 0.07);
    body = body * (1.0 - face_shadow * (1.0 - far * 0.55));

    // 7: reflection carries visual complexity.
    let r = reflect(-v, n);
    let reflected = sky_reflection_color(r);
    let fresnel = fresnel_schlick(n_dot_v);
    let reflection_cap = mix(0.060, 0.36, smoothstep(0.18, 0.0, n_dot_v));
    let reflection_weight = clamp(fresnel * frame.reflection_amount * 1.55, 0.0, reflection_cap) * edge;

    let rough = clamp(frame.roughness + far * 0.07 + clamp(slope_mag * 0.004, 0.0, 0.045), 0.42, 0.93);
    let h = normalize(l + v);
    let n_dot_h = saturate(dot(n, h));
    let v_dot_h = saturate(dot(v, h));
    let alpha = max(rough * rough, 0.045);
    let spec = ggx_d(n_dot_h, alpha) * smith_g1(n_dot_v, alpha) * smith_g1(n_dot_l, alpha) * fresnel_schlick(v_dot_h) / max(4.0 * n_dot_v * n_dot_l, 0.05);
    let sun_specular = vec3<f32>(1.0, 0.86, 0.62) * spec * n_dot_l * edge * 0.00040;

    let foam = sparse_foam(in.surface_xz, in.height, slope_mag, in.jacobian, in.foam, footprint);
    var color = body * (1.0 - reflection_weight * 0.22) + reflected * reflection_weight + sun_specular * (1.0 - foam * 0.92);

    let foam_col = vec3<f32>(0.72, 0.76, 0.76);
    color = mix(color, foam_col, smoothstep(0.10, 0.82, foam) * 0.78);

    let far_col = far_sea_color(normalize(in.world_pos - frame.camera_pos), dist);
    let distance_haze = smoothstep(1600.0, 5400.0, dist);
    let edge_haze = 1.0 - smoothstep(0.04, 0.82, edge);
    color = mix(color, far_col, clamp(distance_haze * 0.50 + edge_haze * 0.94, 0.0, 0.94));

    if debug_mode == 0 {
        let w = wire_density(in.uv);
        return vec4(vec3<f32>(0.05, 0.25, 0.38) + vec3<f32>(w), 1.0);
    }
    if debug_mode == 2 {
        let hdbg = clamp(in.height * 0.20 + 0.5, 0.0, 1.0);
        return vec4(vec3<f32>(hdbg), 1.0);
    }
    if debug_mode == 3 {
        return vec4(vec3<f32>(clamp(slope_mag * 0.45, 0.0, 1.0)), 1.0);
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
        let body_only = 1.0 - exp(-body * 1.2);
        return vec4(pow(body_only, vec3<f32>(1.0 / 2.2)), 1.0);
    }

    color = 1.0 - exp(-color * 1.48);
    color = pow(max(color, vec3<f32>(0.0)), vec3<f32>(1.0 / 2.2));
    return vec4(color, 1.0);
}
