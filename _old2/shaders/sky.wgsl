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

struct VSOut {
    @builtin(position) position: vec4<f32>,
    @location(0) ndc: vec2<f32>,
};

@group(0) @binding(0) var<uniform> frame: Frame;

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

fn cloud_field(p0: vec2<f32>) -> f32 {
    var p = p0;
    var amp = 0.55;
    var sum = 0.0;
    for (var i = 0u; i < 4u; i = i + 1u) {
        sum = sum + noise2(p) * amp;
        p = p * 2.05 + vec2<f32>(17.0, 11.0);
        amp = amp * 0.52;
    }
    return sum;
}

fn far_ocean_color(rd: vec3<f32>, sky_horizon: vec3<f32>) -> vec3<f32> {
    // Procedural infinite-ocean fallback behind the real mesh. The previous pass
    // made a hard charcoal strip at the horizon; WoWS uses haze and sky-colored
    // distance water there, while keeping the near water dark.
    let deep = vec3<f32>(0.026, 0.052, 0.076);
    let mid = vec3<f32>(0.072, 0.100, 0.122);
    let horizon = vec3<f32>(0.156, 0.174, 0.188);
    var col = mix(deep, mid, smoothstep(-0.92, -0.24, rd.y));
    col = mix(col, horizon, smoothstep(-0.30, 0.065, rd.y));
    let horizon_blend = smoothstep(-0.10, 0.12, rd.y);
    return mix(col, sky_horizon, horizon_blend * 0.86);
}

fn sky_color(ray: vec3<f32>) -> vec3<f32> {
    let rd = normalize(ray);
    let up = saturate(rd.y * 0.5 + 0.5);

    let horizon = vec3<f32>(0.62, 0.68, 0.73);
    let mid = vec3<f32>(0.30, 0.47, 0.62);
    let zenith = vec3<f32>(0.11, 0.25, 0.44);
    var col = mix(horizon, mid, smoothstep(0.0, 0.62, up));
    col = mix(col, zenith, smoothstep(0.42, 1.0, up));

    let sun_dir = normalize(frame.sun_dir);
    let sun_dot = saturate(dot(rd, sun_dir));
    let sun_disc = smoothstep(0.9990, 0.99988, sun_dot);
    let sun_glow = pow(sun_dot, 64.0) * 0.24 + pow(sun_dot, 10.0) * 0.07;
    col = col + vec3<f32>(1.0, 0.86, 0.58) * (sun_disc * 4.0 + sun_glow);

    let wind = normalize(vec2<f32>(frame.wind_dir_x, frame.wind_dir_z));
    let cloud_space = rd.xz / max(0.12, rd.y + 0.24);
    let cloud = smoothstep(0.58, 0.84, cloud_field(cloud_space * 0.72 + wind * frame.time * 0.0028)) *
        smoothstep(-0.05, 0.24, rd.y) *
        (1.0 - smoothstep(0.70, 0.98, rd.y));
    col = mix(col, vec3<f32>(0.73, 0.79, 0.84), cloud * 0.30);

    let haze = exp(-max(rd.y, 0.0) * 7.5);
    col = mix(col, horizon, haze * 0.22);

    if rd.y < 0.07 {
        let sea = far_ocean_color(rd, horizon);
        let sea_weight = 1.0 - smoothstep(-0.045, 0.070, rd.y);
        col = mix(col, sea, sea_weight);
    }

    return col;
}

@vertex
fn vs_main(@builtin(vertex_index) vertex_index: u32) -> VSOut {
    var positions = array<vec2<f32>, 3>(
        vec2<f32>(-1.0, -1.0),
        vec2<f32>( 3.0, -1.0),
        vec2<f32>(-1.0,  3.0),
    );

    let p = positions[vertex_index];
    var out: VSOut;
    out.position = vec4<f32>(p, 0.0, 1.0);
    out.ndc = p;
    return out;
}

@fragment
fn fs_main(in: VSOut) -> @location(0) vec4<f32> {
    let tan_half_fov = 0.57735026919;
    let ray = normalize(
        frame.camera_forward +
        frame.camera_right * in.ndc.x * frame.aspect * tan_half_fov +
        frame.camera_up * in.ndc.y * tan_half_fov
    );

    return vec4<f32>(sky_color(ray), 1.0);
}
