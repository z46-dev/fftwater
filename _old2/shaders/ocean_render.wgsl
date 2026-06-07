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

struct WaveLayers {
    support: vec4<f32>,
    wind: vec4<f32>,
    chop: vec4<f32>,
    capillary: vec4<f32>,
};

struct FoamLayers {
    crest: vec4<f32>,
    fold: vec4<f32>,
    foam: vec4<f32>,
};

struct OpticalLayers {
    absorption: vec4<f32>,
    scatter: vec4<f32>,
    reflection: vec4<f32>,
    lod: vec4<f32>,
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
    @location(10) wave0_layer: vec4<f32>,
    @location(11) wave1_layer: vec4<f32>,
    @location(12) foam_layer: vec4<f32>,
    @location(13) optical_layer: vec4<f32>,
    @location(14) reflection_layer: vec4<f32>,
    @location(15) flow_layer: vec4<f32>,
};

@group(0) @binding(0) var<uniform> frame: Frame;
@group(0) @binding(1) var<storage, read> ocean_samples: array<OceanSample>;
@group(0) @binding(2) var<storage, read> wave_layers: array<WaveLayers>;
@group(0) @binding(3) var<storage, read> foam_layers: array<FoamLayers>;
@group(0) @binding(4) var<storage, read> optical_layers: array<OpticalLayers>;

fn saturate(x: f32) -> f32 { return clamp(x, 0.0, 1.0); }

fn safe_normalize2(v: vec2<f32>) -> vec2<f32> {
    let l = length(v);
    if l < 0.00001 { return vec2<f32>(1.0, 0.0); }
    return v / l;
}

fn rotate2(v: vec2<f32>, cs: vec2<f32>) -> vec2<f32> {
    return vec2<f32>(v.x * cs.x - v.y * cs.y, v.x * cs.y + v.y * cs.x);
}

fn hash21(p: vec2<f32>) -> f32 {
    return fract(sin(dot(p, vec2<f32>(127.1, 311.7))) * 43758.5453123);
}

fn smooth_noise2(p: vec2<f32>) -> f32 {
    let i = floor(p);
    let f = fract(p);
    let u = f * f * (3.0 - 2.0 * f);
    let a = hash21(i + vec2<f32>(0.0, 0.0));
    let b = hash21(i + vec2<f32>(1.0, 0.0));
    let c = hash21(i + vec2<f32>(0.0, 1.0));
    let d = hash21(i + vec2<f32>(1.0, 1.0));
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

fn variation_fields(p: vec2<f32>) -> vec4<f32> {
    // Stable world-space replacements for WoWS variationTexture and
    // spaceVariationTexture. No time input here: this keeps material zones from
    // racing or flickering when the camera pans across the projected grid.
    let n0 = smooth_noise2(p * 0.00054 + vec2<f32>(9.7, -13.1));
    let n1 = smooth_noise2(rotate2(p * 0.00117, vec2<f32>(0.819152, 0.573576)) + vec2<f32>(-31.0, 17.0));
    let n2 = smooth_noise2(rotate2(p * 0.00265, vec2<f32>(0.342020, 0.939693)) + vec2<f32>(43.0, -29.0));
    let n3 = smooth_noise2(rotate2(p * 0.00510, vec2<f32>(0.965926, -0.258819)) + vec2<f32>(-7.0, 53.0));
    let slow = sin(dot(p, vec2<f32>(0.00077, -0.00048)) + 2.3) * 0.055 +
        sin(dot(p, vec2<f32>(-0.00039, 0.00091)) + 4.8) * 0.040;

    let space = saturate(0.50 + (n0 - 0.5) * 0.46 + (n1 - 0.5) * 0.24 + slow);
    let detail = saturate(0.52 + (n1 - 0.5) * 0.34 + (n2 - 0.5) * 0.28 + (n3 - 0.5) * 0.12);
    let calm = saturate(0.48 + (n0 - 0.5) * 0.22 - (n2 - 0.5) * 0.32 + (n3 - 0.5) * 0.16);
    let heading = saturate(0.50 + (n2 - 0.5) * 0.40 + (n3 - 0.5) * 0.26 + slow * 0.50);
    return vec4<f32>(space, detail, calm, heading);
}

fn fresnel_schlick(n_dot_v: f32) -> f32 {
    let f0 = 0.020;
    let x = clamp(1.0 - n_dot_v, 0.0, 1.0);
    return f0 + (1.0 - f0) * pow(x, 5.0);
}

fn sky_reflection(ray: vec3<f32>) -> vec3<f32> {
    let rd = normalize(ray);
    let h = saturate(rd.y * 0.5 + 0.5);
    let horizon = vec3<f32>(0.46, 0.52, 0.58);
    let low = vec3<f32>(0.29, 0.40, 0.51);
    let mid = vec3<f32>(0.13, 0.27, 0.43);
    let zenith = vec3<f32>(0.050, 0.118, 0.235);
    var col = mix(horizon, low, smoothstep(0.00, 0.30, h));
    col = mix(col, mid, smoothstep(0.14, 0.72, h));
    col = mix(col, zenith, smoothstep(0.58, 1.00, h));

    // The sea should inherit color from the sky/cloud layer. Keep this stable in
    // reflection-vector space so camera motion changes the reflection naturally,
    // not by sliding a painted texture across the water.
    let cloud0 = smooth_noise2(rd.xz * 3.2 + vec2<f32>(1.7, -2.6));
    let cloud1 = smooth_noise2(rotate2(rd.xz * 5.35, vec2<f32>(0.819152, 0.573576)) + vec2<f32>(-3.9, 2.4));
    let cloud2 = smooth_noise2(rotate2(rd.xz * 8.90, vec2<f32>(0.342020, 0.939693)) + vec2<f32>(5.4, -4.2));
    let cloud = smoothstep(0.46, 0.82, cloud0 * 0.52 + cloud1 * 0.34 + cloud2 * 0.14 + h * 0.42);
    let cloud_band = smoothstep(0.05, 0.70, h) * (1.0 - smoothstep(0.88, 1.00, h));
    let cloud_shadow = mix(0.72, 1.08, cloud);
    col = col * mix(1.0, cloud_shadow, cloud_band * 0.46);
    col = mix(col, vec3<f32>(0.62, 0.67, 0.70), cloud * cloud_band * 0.16);

    let sun_dot = saturate(dot(rd, normalize(frame.sun_dir)));
    let sun_warm = vec3<f32>(1.0, 0.84, 0.56);
    col = col + sun_warm * (pow(sun_dot, 220.0) * 0.042 + pow(sun_dot, 52.0) * 0.014);
    return col;
}


fn add_detail_wave(g0: vec2<f32>, p: vec2<f32>, dir0: vec2<f32>, wavelength: f32, amp: f32, speed: f32, phase0: f32, footprint: f32, dist: f32) -> vec2<f32> {
    let k = 2.0 * PI / wavelength;
    // Aggressive footprint filtering: the previous tiny bright facet bands were
    // undersampled, so camera motion converted them into shimmer/flicker.
    let pixel_lod = smoothstep(1.40, 7.80, wavelength / max(footprint, 0.001));
    let dist_lod = 1.0 - smoothstep(1450.0, 5200.0, dist);
    let lod = pixel_lod * dist_lod;
    if lod <= 0.0001 { return g0; }

    let t = frame.time * max(frame.time_scale, 0.0);
    let vf = variation_fields(p * (0.17 / max(wavelength, 0.65)) + vec2<f32>(phase0 * 2.7, -phase0 * 1.9));
    let cross0 = vec2<f32>(-dir0.y, dir0.x);
    let angle = (vf.w - 0.5) * 0.52 + (vf.y - 0.5) * 0.18;
    let cs = vec2<f32>(cos(angle), sin(angle));
    let dir = safe_normalize2(dir0 * cs.x + cross0 * cs.y);
    let cross = vec2<f32>(-dir.y, dir.x);
    let phase_bend = (vf.x - 0.5) * 0.40 + sin(dot(p, cross) * k * 0.13 + phase0) * 0.10;
    let phase = dot(p, dir) * k + t * speed + phase0 + phase_bend;
    let envelope = mix(0.90, 1.08, vf.y) * mix(1.04, 0.88, vf.z);
    return g0 + dir * (cos(phase) * amp * k * lod * envelope);
}


fn normal_detail_gradient(stable_xz: vec2<f32>, footprint: f32, dist: f32) -> vec2<f32> {
    let wind = safe_normalize2(vec2<f32>(frame.wind_dir_x, frame.wind_dir_z));
    let cross = vec2<f32>(-wind.y, wind.x);
    let vf = variation_fields(stable_xz);
    let detail_amp = mix(0.76, 1.06, vf.y) * mix(1.06, 0.84, vf.z);
    let t = frame.time * max(frame.time_scale, 0.0);

    // Smooth world-space warp only. Keep it small so material does not swim when
    // the projected grid shifts under the camera.
    let warp = vec2<f32>(
        sin(dot(stable_xz, vec2<f32>(0.0029, -0.0021)) + t * 0.014 + vf.w),
        sin(dot(stable_xz, vec2<f32>(-0.0024, 0.0032)) - t * 0.012 + vf.x)
    ) * mix(0.20, 0.54, vf.y);
    let p = stable_xz + warp;

    var g = vec2<f32>(0.0, 0.0);
    g = add_detail_wave(g, p, safe_normalize2(wind * 0.98 + cross * 0.20), 8.2, 0.0049 * detail_amp, 0.54, 0.4, footprint, dist);
    g = add_detail_wave(g, p, safe_normalize2(wind * 0.72 + cross * 0.69), 5.8, 0.0040 * detail_amp, -0.72, 2.1, footprint, dist);
    g = add_detail_wave(g, p, safe_normalize2(wind * 0.22 - cross * 0.98), 3.9, 0.0030 * detail_amp, 0.92, 4.0, footprint, dist);
    g = add_detail_wave(g, p, safe_normalize2(-wind * 0.30 + cross * 0.95), 2.65, 0.0019 * detail_amp, -1.08, 1.3, footprint, dist);
    g = add_detail_wave(g, p, safe_normalize2(-wind * 0.70 + cross * 0.72), 1.85, 0.0010 * detail_amp, 1.28, 5.0, footprint, dist);

    let scale = clamp(frame.normal_detail_scale, 0.0, 4.0);
    let out_g = g * scale;
    let m = length(out_g);
    if m > 0.48 {
        return out_g * (0.48 / m);
    }
    return out_g;
}


fn fluid_shimmer(stable_xz: vec2<f32>, v: vec3<f32>, n: vec3<f32>, flow: vec4<f32>, footprint: f32, dist: f32, far: f32) -> vec3<f32> {
    let flow_dir = safe_normalize2(flow.xy);
    let cross = vec2<f32>(-flow_dir.y, flow_dir.x);
    let t = frame.time * max(frame.time_scale, 0.0);

    let px_lod = smoothstep(0.25, 3.4, 1.0 / max(footprint, 0.001));
    let dist_lod = 1.0 - smoothstep(1600.0, 5600.0, dist);
    let lod = px_lod * dist_lod;
    if lod <= 0.0001 {
        return vec3<f32>(0.0);
    }

    let vf = variation_fields(stable_xz * 0.92 + vec2<f32>(-13.0, 47.0));
    let dir0 = safe_normalize2(flow_dir * 0.82 + cross * 0.57);
    let dir1 = safe_normalize2(flow_dir * 0.35 - cross * 0.94);
    let dir2 = safe_normalize2(-flow_dir * 0.58 + cross * 0.81);

    let p0 = stable_xz + flow_dir * t * 4.8 + cross * sin(t * 0.33 + vf.w) * 0.65;
    let p1 = stable_xz - flow_dir * t * 3.6 + cross * t * 1.2;
    let p2 = stable_xz + dir2 * t * 2.7;

    let r0 = pow(saturate(0.5 + 0.5 * sin(dot(p0, dir0) * 3.9 + sin(dot(p0, cross) * 0.52) * 0.75)), 10.0);
    let r1 = pow(saturate(0.5 + 0.5 * sin(dot(p1, dir1) * 6.4 + sin(dot(p1, flow_dir) * 0.37) * 0.90)), 13.0);
    let r2 = pow(saturate(0.5 + 0.5 * sin(dot(p2, dir2) * 9.8 + vf.y * 2.2)), 16.0);

    let ridge = (r0 * 0.44 + r1 * 0.34 + r2 * 0.22) * lod * mix(0.72, 1.18, vf.y);
    let refl = sky_reflection(reflect(-v, normalize(mix(n, vec3<f32>(0.0, 1.0, 0.0), 0.25))));
    let sun = pow(saturate(dot(reflect(-v, n), normalize(frame.sun_dir))), 34.0);
    return refl * ridge * 0.070 + vec3<f32>(1.0, 0.84, 0.58) * ridge * sun * 0.060 * (1.0 - far);
}

fn foam_texture(stable_xz: vec2<f32>, flow_dir: vec2<f32>) -> vec2<f32> {
    let cross = vec2<f32>(-flow_dir.y, flow_dir.x);
    let t = frame.time * max(frame.time_scale, 0.0);
    let p = stable_xz + flow_dir * t * 0.28;
    let low_signal =
        sin(dot(p, flow_dir) * 0.045 + sin(dot(p, cross) * 0.070) * 0.35) * 0.55 +
        sin(dot(p, flow_dir * 0.40 + cross * 0.60) * 0.064 + 1.7) * 0.30;
    let high_signal =
        sin(dot(p, flow_dir * 0.66 + cross * 0.34) * 0.18 + sin(dot(p, cross * 0.55 - flow_dir * 0.20)) * 0.42) * 0.48 +
        sin(dot(p, flow_dir * -0.18 + cross * 0.98) * 0.23 + 3.1) * 0.26;
    return vec2<f32>(smoothstep(0.58, 0.98, low_signal), smoothstep(0.70, 1.05, high_signal));
}


fn depth_absorbed_body(height: f32, slope_mag: f32, far: f32, stable_xz: vec2<f32>, n_dot_v: f32, n_dot_l: f32, wave0: vec4<f32>, wave1: vec4<f32>, optical: vec4<f32>) -> vec3<f32> {
    let vf = variation_fields(stable_xz * 0.54 + vec2<f32>(17.0, -23.0));
    let wave_energy = saturate(wave0.x * 0.05 + wave0.y * 0.18 + wave0.z * 0.26 + wave0.w * 0.20);
    let pseudo_depth = clamp(1.9 + far * 4.2 + vf.x * 0.45 + wave_energy * 0.22 - height * 0.010, 0.70, 8.2);
    let view_path = 1.0 / max(n_dot_v, 0.17);
    let optical_depth = pseudo_depth * view_path * mix(0.86, 1.08, optical.w);

    let sky_top = sky_reflection(vec3<f32>(0.0, 1.0, 0.0));
    let sky_horizon = sky_reflection(normalize(vec3<f32>(frame.camera_forward.x, 0.20, frame.camera_forward.z)));
    let sky_tint = mix(sky_horizon, sky_top, 0.50 + vf.x * 0.25);

    // Very weak intrinsic water pigment. Most color now comes from reflected sky
    // plus absorption through a dark water volume.
    let absorption = vec3<f32>(0.88, 0.42, 0.18);
    let trans = exp(-absorption * optical_depth);
    let deep = sky_tint * vec3<f32>(0.050, 0.074, 0.105) + vec3<f32>(0.0015, 0.0045, 0.0070);
    let body = sky_tint * vec3<f32>(0.100, 0.140, 0.190) + vec3<f32>(0.0030, 0.0080, 0.0120);
    let scatter = sky_tint * vec3<f32>(0.175, 0.215, 0.260) + vec3<f32>(0.0060, 0.0130, 0.0170);

    var c = mix(deep, body, trans.b * 0.74 + trans.g * 0.16);
    c = mix(c, scatter, smoothstep(0.14, 1.05, slope_mag) * 0.070 * (1.0 - far * 0.38) * optical.z);
    let cloud_mod = mix(0.84, 1.06, vf.x) * mix(0.90, 1.03, vf.y);
    c = c * cloud_mod + sky_tint * (0.010 * pow(n_dot_l, 1.25) * (1.0 - far * 0.55));
    return c;
}


fn rough_reflection(v: vec3<f32>, n: vec3<f32>, stable_xz: vec2<f32>, slope_mag: f32, far: f32, wave0: vec4<f32>, optical: vec4<f32>, reflection: vec4<f32>, flow: vec4<f32>) -> vec3<f32> {
    let flow_dir = safe_normalize2(flow.xy);
    let cross = vec2<f32>(-flow_dir.y, flow_dir.x);
    let vf0 = variation_fields(stable_xz * 0.34 + vec2<f32>(-11.0, 37.0));
    let vf1 = variation_fields(rotate2(stable_xz * 0.58, vec2<f32>(0.601815, 0.798636)) + vec2<f32>(29.0, -71.0));
    let wave_energy = saturate(wave0.y * 0.22 + wave0.z * 0.30 + wave0.w * 0.20);

    let angle = (vf0.w - 0.5) * 0.52 + (vf1.y - 0.5) * 0.24;
    let cs = vec2<f32>(cos(angle), sin(angle));
    let dir_a = safe_normalize2(flow_dir * cs.x + cross * cs.y);
    let dir_b = safe_normalize2(flow_dir * -cs.y + cross * cs.x);

    let mid_amp = (0.011 + wave_energy * 0.016 + wave0.z * 0.006) * optical.x * mix(0.86, 1.14, vf0.y);
    let sharp_amp = (0.0045 + wave0.w * 0.014 + wave_energy * 0.0050) * optical.x * mix(0.84, 1.16, vf1.y);
    let n_base = normalize(n);
    let n_broad = normalize(mix(n_base, vec3<f32>(0.0, 1.0, 0.0), clamp(0.46 + frame.roughness * 0.20 + far * 0.26, 0.0, 0.88)));
    let n_mid = normalize(n_base + vec3<f32>(dir_a.x, 0.0, dir_a.y) * mid_amp + vec3<f32>(dir_b.x, 0.0, dir_b.y) * mid_amp * 0.25);
    let n_sharp = normalize(n_base + vec3<f32>(dir_b.x, 0.0, dir_b.y) * sharp_amp + vec3<f32>(dir_a.x, 0.0, dir_a.y) * sharp_amp * 0.18);

    let broad = sky_reflection(reflect(-v, n_broad));
    let mid = sky_reflection(reflect(-v, normalize(mix(n_mid, n_broad, 0.42))));
    let sharp = sky_reflection(reflect(-v, n_sharp));
    let mid_w = clamp(0.30 + reflection.y * 0.28 + wave_energy * 0.11 + vf0.y * 0.040, 0.24, 0.58);
    let sharp_w = clamp(reflection.z * 0.09 + smoothstep(0.45, 1.55, slope_mag) * 0.012 + vf1.y * 0.010 - far * 0.08, 0.0, 0.070);
    let reflected = mix(mix(broad, mid, mid_w), sharp, sharp_w);
    return min(reflected * mix(0.96, 1.16, reflection.x), vec3<f32>(0.46, 0.52, 0.58));
}


fn foam_query(stable_xz: vec2<f32>, height: f32, slope_mag: f32, foam_layer: vec4<f32>, flow: vec4<f32>, footprint: f32, far: f32) -> f32 {
    let flow_dir = safe_normalize2(flow.xy);
    let tex = foam_texture(stable_xz, flow_dir);
    let source = foam_layer.x * 0.045 + foam_layer.y * 0.16 + foam_layer.z * 0.060 + foam_layer.w * 0.030;
    let crest_gate = smoothstep(frame.foam_threshold + 0.20, frame.foam_threshold + 1.35, slope_mag) * smoothstep(0.06, 0.75, height);
    let lod = smoothstep(0.60, 2.40, 1.0 / max(footprint, 0.001)) * (1.0 - smoothstep(1700.0, 4700.0, far));
    let patterned = tex.x * 0.10 + tex.y * 0.055;
    return saturate((source * 0.18 + crest_gate * 0.080) * patterned * frame.foam_amount * lod);
}


fn far_sea_color(view_dir: vec3<f32>, dist: f32) -> vec3<f32> {
    let fog = smoothstep(1500.0, 7600.0, dist);
    let sky = sky_reflection(normalize(vec3<f32>(view_dir.x, max(0.16, abs(view_dir.y) * 0.42), view_dir.z)));
    let deep = sky * vec3<f32>(0.09, 0.12, 0.15) + vec3<f32>(0.006, 0.012, 0.018);
    let horizon = sky * vec3<f32>(0.18, 0.22, 0.27) + vec3<f32>(0.010, 0.016, 0.022);
    return mix(deep, horizon, fog * 0.55 + smoothstep(-0.04, 0.26, view_dir.y) * 0.12);
}

fn wire_density(uv: vec2<f32>) -> f32 {
    let grid = uv * frame.plane_resolution;
    let fw = max(fwidth(grid), vec2<f32>(0.0001, 0.0001));
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
    let wave = wave_layers[vertex_index];
    let foam = foam_layers[vertex_index];
    let optical = optical_layers[vertex_index];

    // Stable shading coordinates and displaced render coordinates are deliberately
    // separate. Sampling material/variation from the displaced position made the
    // surface shimmer when the camera moved across the projected grid.
    let stable_xz = position.xz + frame.ocean_origin;
    let displaced_xz = stable_xz + vec2<f32>(s.disp_x, s.disp_z);
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
    out.edge_fade = s.edge_fade;
    out.surface_xz = stable_xz;
    out.cascade_mix = s.cascade_mix;
    out.wave0_layer = vec4<f32>(wave.support.y, wave.wind.y, wave.chop.y, wave.capillary.y);
    out.wave1_layer = vec4<f32>(wave.support.x, wave.wind.x, wave.chop.x, wave.support.w);
    out.foam_layer = vec4<f32>(foam.crest.y, foam.crest.x, foam.fold.x, foam.foam.x);
    out.optical_layer = vec4<f32>(optical.reflection.w, optical.lod.z, optical.scatter.x, optical.absorption.x);
    out.reflection_layer = vec4<f32>(optical.reflection.x, optical.reflection.y, optical.reflection.z, optical.lod.y);
    out.flow_layer = vec4<f32>(foam.foam.y, foam.foam.z, optical.lod.w, foam.foam.w);
    return out;
}

@fragment
fn fs_main(in: VSOut) -> @location(0) vec4<f32> {
    let debug_mode = i32(frame.debug_mode + 0.5);
    let rel = in.surface_xz - vec2<f32>(frame.camera_pos.x, frame.camera_pos.z);
    let dist = max(abs(rel.x), abs(rel.y));
    let far = smoothstep(1150.0, 6200.0, dist);
    let edge = clamp(in.edge_fade, 0.0, 1.0);

    let v = normalize(frame.camera_pos - in.world_pos);
    let l = normalize(frame.sun_dir);
    let ddx_xz = dpdx(in.surface_xz);
    let ddy_xz = dpdy(in.surface_xz);
    let footprint = clamp(max(length(ddx_xz), length(ddy_xz)), 0.030, 75.0);
    let detail_grad = normal_detail_gradient(in.surface_xz, footprint, dist) * edge * mix(0.62, 1.05, in.reflection_layer.w);

    var n = normalize(in.base_normal + vec3<f32>(-detail_grad.x, 0.0, -detail_grad.y));
    let n_base_v = saturate(dot(normalize(in.base_normal), v));
    let filtered = normalize(vec3<f32>(n.x * 0.32, 1.0, n.z * 0.32));
    let view_soft = clamp(smoothstep(0.58, 0.10, n_base_v) * 0.22 + far * 0.36 + (1.0 - edge) * 0.88, 0.0, 0.76);
    n = normalize(mix(n, filtered, view_soft));

    let n_dot_v = saturate(dot(n, v));
    let n_dot_l = saturate(dot(n, l));
    let layer_relief = abs(in.wave1_layer.x) * 0.035 + abs(in.wave1_layer.y) * 0.060 + abs(in.wave1_layer.z) * 0.055;
    let slope_mag = in.slope_mag + length(detail_grad) * 0.18 + in.foam_layer.x * 0.024 + layer_relief * 0.86;

    let body = depth_absorbed_body(in.height, slope_mag, far, in.surface_xz, n_dot_v, n_dot_l, in.wave0_layer, in.wave1_layer, in.optical_layer);
    let reflected = rough_reflection(v, n, in.surface_xz, slope_mag, far, in.wave0_layer, in.optical_layer, in.reflection_layer, in.flow_layer);
    let fresnel = fresnel_schlick(n_dot_v);
    let refl_weight = clamp(fresnel * frame.reflection_amount * in.optical_layer.x * 1.22, 0.0, mix(0.12, 0.50, smoothstep(0.48, 0.0, n_dot_v))) * edge;

    let h = normalize(l + v);
    let n_dot_h = saturate(dot(n, h));
    let v_dot_h = saturate(dot(v, h));
    let rough = clamp(frame.roughness + far * 0.10 - in.reflection_layer.z * 0.045, 0.42, 0.90);
    let alpha = max(rough * rough, 0.065);
    let a2 = alpha * alpha;
    let denom = n_dot_h * n_dot_h * (a2 - 1.0) + 1.0;
    let spec_d = a2 / max(PI * denom * denom, 0.0001);
    let spec_f = fresnel_schlick(v_dot_h);
    let spec = spec_d * spec_f * n_dot_l / max(4.0 * n_dot_v, 0.05);
    let sun_specular = vec3<f32>(1.0, 0.84, 0.58) * spec * edge * 0.000075;

    let foam = foam_query(in.surface_xz, in.height, slope_mag, in.foam_layer, in.flow_layer, footprint, dist);
    let foam_color = vec3<f32>(0.28, 0.35, 0.39);
    let shimmer = fluid_shimmer(in.surface_xz, v, n, in.flow_layer, footprint, dist, far) * edge;
    var color = body * (1.0 - refl_weight * 0.06) + reflected * refl_weight + shimmer + sun_specular * (1.0 - foam * 0.90);
    color = mix(color, foam_color, smoothstep(0.30, 0.98, foam) * 0.075);

    let leeward = 1.0 - smoothstep(0.04, 0.58, dot(n, l));
    let trough = 1.0 - smoothstep(-0.40, 0.12, in.height);
    color = color * (1.0 - (leeward * 0.018 + trough * 0.032) * (1.0 - far * 0.55));

    let far_col = far_sea_color(normalize(in.world_pos - frame.camera_pos), dist);
    color = mix(color, far_col, clamp(smoothstep(3600.0, 8400.0, dist) * 0.30 + (1.0 - smoothstep(0.04, 0.82, edge)) * 0.92, 0.0, 0.90));

    if debug_mode == 0 {
        let w = wire_density(in.uv);
        return vec4(vec3<f32>(0.05, 0.25, 0.38) + vec3<f32>(w), 1.0);
    }
    if debug_mode == 2 {
        let hdbg = clamp(in.height * 0.24 + 0.5, 0.0, 1.0);
        return vec4(vec3<f32>(hdbg), 1.0);
    }
    if debug_mode == 3 { return vec4(vec3<f32>(clamp(slope_mag * 0.45, 0.0, 1.0)), 1.0); }
    if debug_mode == 4 { return vec4(n * 0.5 + 0.5, 1.0); }
    if debug_mode == 5 { return vec4(vec3<f32>(foam), 1.0); }
    if debug_mode == 6 { return vec4(in.wave0_layer.xyz, 1.0); }
    if debug_mode == 7 { return vec4(vec3<f32>(refl_weight), 1.0); }
    if debug_mode == 8 { return vec4(vec3<f32>(fresnel), 1.0); }
    if debug_mode == 9 {
        return vec4(pow(1.0 - exp(-body * 1.20), vec3<f32>(1.0 / 2.2)), 1.0);
    }

    color = 1.0 - exp(-color * 1.30);
    color = pow(max(color, vec3<f32>(0.0)), vec3<f32>(1.0 / 2.2));
    return vec4(color, 1.0);
}
