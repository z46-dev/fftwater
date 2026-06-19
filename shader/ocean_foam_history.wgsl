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
    // x = spectrum origin world x, y = spectrum origin world z,
    // z = spectrum world span, w = spectrum texture dimension.
    spectrum_params: vec4<f32>,
};

@group(0) @binding(0)
var<uniform> frame: FrameUniforms;

// Instantaneous field-derived water data from ocean_wavedata.wgsl.
// RGBA = height-gradient x/z, roughness/moment, instantaneous foam seed.
@group(0) @binding(1)
var wave_data_tex: texture_2d<f32>;

// Previous history.  RGBA = accumulated foam, accumulated roughness,
// crest-memory, breakup/lace mask.
@group(0) @binding(2)
var foam_history_prev: texture_2d<f32>;

@group(0) @binding(3)
var foam_history_out: texture_storage_2d<rgba32float, write>;

fn saturate(v: f32) -> f32 {
    return clamp(v, 0.0, 1.0);
}

fn finite_or(v: f32, fallback: f32, limit: f32) -> f32 {
    let good = (v == v) && abs(v) <= limit;
    return select(fallback, clamp(v, -limit, limit), good);
}

fn sanitize_wave_data(v: vec4<f32>) -> vec4<f32> {
    return vec4<f32>(
        finite_or(v.x, 0.0, 1.4),
        finite_or(v.y, 0.0, 1.4),
        finite_or(v.z, 0.0, 1.0),
        finite_or(v.w, 0.0, 1.0)
    );
}

fn sanitize_history(v: vec4<f32>) -> vec4<f32> {
    return vec4<f32>(
        finite_or(v.x, 0.0, 1.0),
        finite_or(v.y, 0.0, 1.0),
        finite_or(v.z, 0.0, 1.0),
        finite_or(v.w, 0.0, 1.0)
    );
}

fn wrap_index(v: i32, n: i32) -> i32 {
    return ((v % n) + n) % n;
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

fn load_wave(coord: vec2<i32>, n: i32) -> vec4<f32> {
    let c = vec2<i32>(wrap_index(coord.x, n), wrap_index(coord.y, n));
    return sanitize_wave_data(textureLoad(wave_data_tex, c, 0));
}

fn load_history_nearest(coord: vec2<i32>, n: i32) -> vec4<f32> {
    let c = vec2<i32>(wrap_index(coord.x, n), wrap_index(coord.y, n));
    return sanitize_history(textureLoad(foam_history_prev, c, 0));
}

fn sample_history(coord: vec2<f32>, n: i32) -> vec4<f32> {
    let i0 = vec2<i32>(floor(coord));
    let f = fract(coord);

    let a = load_history_nearest(i0 + vec2<i32>(0, 0), n);
    let b = load_history_nearest(i0 + vec2<i32>(1, 0), n);
    let c = load_history_nearest(i0 + vec2<i32>(0, 1), n);
    let d = load_history_nearest(i0 + vec2<i32>(1, 1), n);
    return sanitize_history(mix(mix(a, b, f.x), mix(c, d, f.x), f.y));
}

@compute @workgroup_size(8, 8, 1)
fn cs_clear(@builtin(global_invocation_id) gid: vec3<u32>) {
    let n_u = max(u32(frame.spectrum_params.w), 1u);
    if gid.x >= n_u || gid.y >= n_u {
        return;
    }
    textureStore(foam_history_out, vec2<i32>(i32(gid.x), i32(gid.y)), vec4<f32>(0.0, 0.0, 0.0, 0.0));
}

@compute @workgroup_size(8, 8, 1)
fn cs_main(@builtin(global_invocation_id) gid: vec3<u32>) {
    let n_u = max(u32(frame.spectrum_params.w), 1u);
    if gid.x >= n_u || gid.y >= n_u {
        return;
    }

    let n = i32(n_u);
    let p = vec2<i32>(i32(gid.x), i32(gid.y));
    let uv = (vec2<f32>(f32(gid.x), f32(gid.y)) + vec2<f32>(0.5, 0.5)) / f32(n_u);
    let world = frame.spectrum_params.xy + uv * max(frame.spectrum_params.z, 1.0);

    let c  = load_wave(p, n);
    let l  = load_wave(p + vec2<i32>(-1,  0), n);
    let r  = load_wave(p + vec2<i32>( 1,  0), n);
    let d  = load_wave(p + vec2<i32>( 0, -1), n);
    let u  = load_wave(p + vec2<i32>( 0,  1), n);

    let grad = c.xy;
    let grad_mag = length(grad);
    let moment = c.z;
    let seed_foam = c.w;

    // Advect history opposite the strongest local gradient.  This approximates
    // the WoWS foam-energy ping-pong path: foam is born from compression/folding,
    // then persists and tears along crests instead of appearing as disconnected
    // per-frame white blobs.
    let wind = normalize(vec2<f32>(0.86, -0.51));
    let flow = normalize(grad * 1.85 + wind * 0.42 + vec2<f32>(0.0001, 0.0001));
    let advect_pixels = flow * (0.38 + 3.65 * smoothstep(0.045, 0.58, moment + grad_mag * 0.70));
    let prev = sample_history(vec2<f32>(f32(gid.x), f32(gid.y)) - advect_pixels, n);

    let neighbor_foam = (l.w + r.w + d.w + u.w) * 0.25;
    let neighbor_moment = (l.z + r.z + d.z + u.z) * 0.25;
    let crest_agreement = smoothstep(0.10, 0.62, moment * 0.72 + neighbor_moment * 0.28) *
                          smoothstep(0.020, 0.34, grad_mag);

    // Low/high breakup stand-ins for g_foamLowFreq/g_foamHighFreq. They only
    // modulate FFT-derived foam; they do not create independent foam islands.
    let t = frame.resolution_time_grid.z;
    let low = noise2(world * 0.010 + vec2<f32>(t * 0.025, -t * 0.018));
    let high = noise2(world * 0.060 + vec2<f32>(-t * 0.120, t * 0.073));
    let lace = smoothstep(0.22, 0.86, low * 0.58 + high * 0.42);

    let born = saturate(seed_foam * 0.74 + neighbor_foam * 0.18 + crest_agreement * 0.32);
    let coverage_gate = saturate(moment * 1.65 + grad_mag * 1.05 + seed_foam * 0.82);
    var foam = prev.x * 0.972 + born * (0.035 + 0.078 * lace);
    foam = min(foam, coverage_gate * 0.70 + born * 0.32 + 0.016);
    foam = saturate(foam);

    var roughness = max(prev.y * 0.986, moment * 1.12 + crest_agreement * 0.32 + foam * 0.26);
    roughness = saturate(roughness);

    var crest_memory = max(prev.z * 0.974, crest_agreement * 1.06 + seed_foam * 0.36);
    crest_memory = saturate(crest_memory);

    var breakup = max(prev.w * 0.925, lace * born);
    breakup = saturate(breakup);

    textureStore(foam_history_out, p, vec4<f32>(foam, roughness, crest_memory, breakup));
}
