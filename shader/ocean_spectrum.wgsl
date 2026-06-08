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

// Primary FFT tile output from ocean_fft.wgsl.
// RG = spatial height complex residue; BA = spatial displacement-x complex residue.
// Real parts carry the physical fields used by this pass.
@group(0) @binding(1)
var fft_primary_tiles: texture_2d<f32>;

// Auxiliary FFT tile output from ocean_fft.wgsl.
// RG = spatial displacement-z complex residue; BA = spatial curvature complex residue.
@group(0) @binding(2)
var fft_aux_tiles: texture_2d<f32>;

// Spatial displacement/foam field consumed by the filter and render passes.
// RGBA layout:
//   R = horizontal displacement x
//   G = height
//   B = horizontal displacement z
//   A = large/mid foam energy
@group(0) @binding(3)
var spectrum_out: texture_storage_2d<rgba32float, write>;

struct WaveContrib {
    height: f32,
    disp: vec2<f32>,
    slope: vec2<f32>,
    curvature: f32,
};

struct CascadeParams {
    domain: f32,
    height_gain: f32,
    chop_gain: f32,
    slope_scale: f32,
    curvature_gain: f32,
};

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

fn finite_or(v: f32, fallback: f32, limit: f32) -> f32 {
    let good = (v == v) && abs(v) <= limit;
    return select(fallback, clamp(v, -limit, limit), good);
}

fn sanitize_tile(v: vec4<f32>) -> vec4<f32> {
    return vec4<f32>(
        finite_or(v.x, 0.0, 64.0),
        finite_or(v.y, 0.0, 64.0),
        finite_or(v.z, 0.0, 64.0),
        finite_or(v.w, 0.0, 64.0)
    );
}

fn sanitize_wave(w: WaveContrib) -> WaveContrib {
    var r: WaveContrib;
    r.height = finite_or(w.height, 0.0, 3.2);
    r.disp = vec2<f32>(finite_or(w.disp.x, 0.0, 12.0), finite_or(w.disp.y, 0.0, 12.0));
    r.slope = vec2<f32>(finite_or(w.slope.x, 0.0, 5.0), finite_or(w.slope.y, 0.0, 5.0));
    r.curvature = finite_or(w.curvature, 0.0, 0.18);
    return r;
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

fn cascade_params(index: i32) -> CascadeParams {
    var c: CascadeParams;

    if index == 0 {
        c.domain = 900.0;
        c.height_gain = 0.24;
        c.chop_gain = 1.35;
        c.slope_scale = 1.30;
        c.curvature_gain = 0.52;
    } else if index == 1 {
        c.domain = 360.0;
        c.height_gain = 0.23;
        c.chop_gain = 1.85;
        c.slope_scale = 1.95;
        c.curvature_gain = 0.78;
    } else if index == 2 {
        c.domain = 150.0;
        c.height_gain = 0.13;
        c.chop_gain = 1.45;
        c.slope_scale = 2.75;
        c.curvature_gain = 1.18;
    } else {
        c.domain = 62.0;
        c.height_gain = 0.045;
        c.chop_gain = 0.55;
        c.slope_scale = 3.60;
        c.curvature_gain = 1.75;
    }

    return c;
}

fn wrap01(v: vec2<f32>) -> vec2<f32> {
    return fract(v);
}

fn load_primary_texel(coord: vec2<i32>, cascade_index: i32, mode_dim: i32, total_h: i32) -> vec4<f32> {
    let x = ((coord.x % mode_dim) + mode_dim) % mode_dim;
    let y_local = ((coord.y % mode_dim) + mode_dim) % mode_dim;
    let y = cascade_index * mode_dim + y_local;
    if y < 0 || y >= total_h {
        return vec4<f32>(0.0, 0.0, 0.0, 0.0);
    }
    return sanitize_tile(textureLoad(fft_primary_tiles, vec2<i32>(x, y), 0));
}

fn load_aux_texel(coord: vec2<i32>, cascade_index: i32, mode_dim: i32, total_h: i32) -> vec4<f32> {
    let x = ((coord.x % mode_dim) + mode_dim) % mode_dim;
    let y_local = ((coord.y % mode_dim) + mode_dim) % mode_dim;
    let y = cascade_index * mode_dim + y_local;
    if y < 0 || y >= total_h {
        return vec4<f32>(0.0, 0.0, 0.0, 0.0);
    }
    return sanitize_tile(textureLoad(fft_aux_tiles, vec2<i32>(x, y), 0));
}

fn bilerp4(a: vec4<f32>, b: vec4<f32>, d: vec4<f32>, e: vec4<f32>, f: vec2<f32>) -> vec4<f32> {
    return mix(mix(a, b, f.x), mix(d, e, f.x), f.y);
}

fn sample_primary(p: vec2<f32>, cascade_index: i32, mode_dim: i32, total_h: i32) -> vec4<f32> {
    let c = cascade_params(cascade_index);
    let uv = wrap01(p / c.domain);
    let coord = uv * f32(mode_dim);
    let i0 = vec2<i32>(floor(coord));
    let f = fract(coord);

    let a = load_primary_texel(i0 + vec2<i32>(0, 0), cascade_index, mode_dim, total_h);
    let b = load_primary_texel(i0 + vec2<i32>(1, 0), cascade_index, mode_dim, total_h);
    let d = load_primary_texel(i0 + vec2<i32>(0, 1), cascade_index, mode_dim, total_h);
    let e = load_primary_texel(i0 + vec2<i32>(1, 1), cascade_index, mode_dim, total_h);
    return sanitize_tile(bilerp4(a, b, d, e, f));
}

fn sample_aux(p: vec2<f32>, cascade_index: i32, mode_dim: i32, total_h: i32) -> vec4<f32> {
    let c = cascade_params(cascade_index);
    let uv = wrap01(p / c.domain);
    let coord = uv * f32(mode_dim);
    let i0 = vec2<i32>(floor(coord));
    let f = fract(coord);

    let a = load_aux_texel(i0 + vec2<i32>(0, 0), cascade_index, mode_dim, total_h);
    let b = load_aux_texel(i0 + vec2<i32>(1, 0), cascade_index, mode_dim, total_h);
    let d = load_aux_texel(i0 + vec2<i32>(0, 1), cascade_index, mode_dim, total_h);
    let e = load_aux_texel(i0 + vec2<i32>(1, 1), cascade_index, mode_dim, total_h);
    return sanitize_tile(bilerp4(a, b, d, e, f));
}

fn sample_height(p: vec2<f32>, cascade_index: i32, mode_dim: i32, total_h: i32) -> f32 {
    let c = cascade_params(cascade_index);
    return finite_or(sample_primary(p, cascade_index, mode_dim, total_h).x * c.height_gain, 0.0, 8.0);
}

fn cascade_wave(p: vec2<f32>, cascade_index: i32, mode_dim: i32, total_h: i32) -> WaveContrib {
    let c = cascade_params(cascade_index);
    let dx = max(c.domain / f32(mode_dim), 0.25);

    let primary = sample_primary(p, cascade_index, mode_dim, total_h);
    let aux = sample_aux(p, cascade_index, mode_dim, total_h);

    let h_c = finite_or(primary.x * c.height_gain, 0.0, 8.0);
    let h_l = sample_height(p - vec2<f32>(dx, 0.0), cascade_index, mode_dim, total_h);
    let h_r = sample_height(p + vec2<f32>(dx, 0.0), cascade_index, mode_dim, total_h);
    let h_d = sample_height(p - vec2<f32>(0.0, dx), cascade_index, mode_dim, total_h);
    let h_u = sample_height(p + vec2<f32>(0.0, dx), cascade_index, mode_dim, total_h);

    let slope = vec2<f32>((h_r - h_l) / (2.0 * dx), (h_u - h_d) / (2.0 * dx));

    var w: WaveContrib;
    w.height = h_c;
    // Displacement now comes from the spectral vector IFFTs rather than from a
    // render-time height-gradient hack. That is the important step toward the
    // WoWS-style choppy surface: the crest geometry is phase-correct with H(k,t).
    w.disp = vec2<f32>(primary.z, aux.x) * c.chop_gain * frame.water_params0.y;
    w.slope = slope * c.slope_scale;
    w.curvature = aux.z * c.curvature_gain;
    return sanitize_wave(w);
}

fn spectrum_large_mid(p: vec2<f32>) -> WaveContrib {
    let dims = textureDimensions(fft_primary_tiles, 0);
    let mode_dim = i32(dims.x);
    let total_h = i32(dims.y);

    var w = empty_wave();
    w = add_wave(w, cascade_wave(p, 0, mode_dim, total_h));
    w = add_wave(w, cascade_wave(p, 1, mode_dim, total_h));
    w = add_wave(w, cascade_wave(p, 2, mode_dim, total_h));
    w = add_wave(w, cascade_wave(p, 3, mode_dim, total_h));
    return sanitize_wave(w);
}

fn large_mid_foam_energy(p: vec2<f32>, w: WaveContrib) -> f32 {
    let t = frame.resolution_time_grid.z;
    let slope_mag = length(w.slope);
    let crest = smoothstep(0.0080, 0.0450, -w.curvature);
    let breaking = smoothstep(0.110, 0.300, slope_mag) * crest;

    let wind_streak = noise2(p * vec2<f32>(0.030, 0.085) + vec2<f32>(t * 0.16, -t * 0.42));
    let lace = noise2(p * 0.240 + vec2<f32>(-t * 0.95, t * 0.51));
    let breakup = smoothstep(0.42, 0.82, wind_streak) * smoothstep(0.36, 0.74, lace);

    return clamp(breaking * mix(0.045, 0.34, breakup), 0.0, 0.34);
}

@compute @workgroup_size(8, 8, 1)
fn cs_main(@builtin(global_invocation_id) gid: vec3<u32>) {
    let n = max(u32(frame.spectrum_params.w), 1u);
    if gid.x >= n || gid.y >= n {
        return;
    }

    let origin = frame.spectrum_params.xy;
    let span = frame.spectrum_params.z;
    let uv = (vec2<f32>(f32(gid.x), f32(gid.y)) + vec2<f32>(0.5, 0.5)) / f32(n);
    let p = origin + uv * span;

    let w = sanitize_wave(spectrum_large_mid(p));
    let foam = clamp(finite_or(large_mid_foam_energy(p, w), 0.0, 1.0), 0.0, 1.0);
    textureStore(
        spectrum_out,
        vec2<i32>(i32(gid.x), i32(gid.y)),
        vec4<f32>(w.disp.x, w.height, w.disp.y, foam)
    );
}
