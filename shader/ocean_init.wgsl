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

// Persistent H0(k) mode texture.  Cascades are stacked vertically.
// RGBA layout:
//   R = H0 real
//   G = H0 imaginary
//   B = angular frequency omega(k)
//   A = cascade displacement scale
@group(0) @binding(1)
var h0_out: texture_storage_2d<rgba32float, write>;

struct CascadeParams {
    domain: f32,
    wind_speed: f32,
    amplitude: f32,
    damping: f32,
    spread_back: f32,
    max_h0: f32,
    chop: f32,
};

const PI: f32 = 3.14159265359;
const TAU: f32 = 6.28318530718;
const G: f32 = 9.81;
const MIN_K: f32 = 0.0001;

fn finite_or(v: f32, fallback: f32, limit: f32) -> f32 {
    let good = (v == v) && abs(v) <= limit;
    return select(fallback, clamp(v, -limit, limit), good);
}

fn hash21(p: vec2<f32>) -> f32 {
    return fract(sin(dot(p, vec2<f32>(127.1, 311.7))) * 43758.5453123);
}

fn hash22(p: vec2<f32>) -> vec2<f32> {
    return vec2<f32>(
        hash21(p + vec2<f32>(17.13, 91.77)),
        hash21(p + vec2<f32>(53.31, 12.47))
    );
}

fn gaussian_pair(seed: vec2<f32>) -> vec2<f32> {
    let u = hash22(seed);
    let r = sqrt(max(0.0, -2.0 * log(max(u.x, 0.000001))));
    let a = TAU * u.y;
    return vec2<f32>(r * cos(a), r * sin(a));
}

fn cascade_params(index: i32) -> CascadeParams {
    var c: CascadeParams;

    if index == 0 {
        // Long swell. Lower amplitude than the previous patch: the point is
        // visible broad motion, not huge single ridges.
        c.domain = 900.0;
        c.wind_speed = 27.0;
        c.amplitude = 0.0000000086;
        c.damping = 0.00100;
        c.spread_back = 0.22;
        c.max_h0 = 0.066;
        c.chop = 0.58;
    } else if index == 1 {
        // Cross chop / mid waves. This band is intentionally close in energy to
        // the swell so the surface has interference instead of one dominant set.
        c.domain = 360.0;
        c.wind_speed = 25.5;
        c.amplitude = 0.000000118;
        c.damping = 0.00190;
        c.spread_back = 0.42;
        c.max_h0 = 0.176;
        c.chop = 0.92;
    } else if index == 2 {
        // Short wind waves. These should contribute slope and choppy texture
        // more than bulk vertical displacement. Geometry cresting is applied
        // later in the water vertex shader; raw spectral height is kept bounded
        // to prevent the projected grid from folding near the camera.
        c.domain = 150.0;
        c.wind_speed = 21.0;
        c.amplitude = 0.000000225;
        c.damping = 0.00410;
        c.spread_back = 0.58;
        c.max_h0 = 0.154;
        c.chop = 1.02;
    } else {
        // Micro cascade. Kept physically in the spectral data path instead of
        // faking all high-frequency life in the fragment shader. It should be a
        // crest/normal source, not a large horizontal displacement source.
        c.domain = 62.0;
        c.wind_speed = 18.0;
        c.amplitude = 0.000000150;
        c.damping = 0.00820;
        c.spread_back = 0.78;
        c.max_h0 = 0.086;
        c.chop = 0.66;
    }

    return c;
}

fn wind_dir_for_cascade(index: i32) -> vec2<f32> {
    if index == 0 {
        return normalize(vec2<f32>(0.78, 0.63));
    }
    if index == 1 {
        return normalize(vec2<f32>(0.34, 0.94));
    }
    if index == 2 {
        return normalize(vec2<f32>(0.93, -0.37));
    }
    return normalize(vec2<f32>(-0.22, 0.98));
}

fn cross_wind_dir_for_cascade(index: i32) -> vec2<f32> {
    if index == 0 {
        return normalize(vec2<f32>(0.93, 0.37));
    }
    if index == 1 {
        return normalize(vec2<f32>(-0.54, 0.84));
    }
    if index == 2 {
        return normalize(vec2<f32>(0.55, 0.83));
    }
    return normalize(vec2<f32>(0.79, 0.61));
}

fn counter_wind_dir_for_cascade(index: i32) -> vec2<f32> {
    if index == 0 {
        return normalize(vec2<f32>(-0.42, 0.91));
    }
    if index == 1 {
        return normalize(vec2<f32>(0.98, -0.18));
    }
    if index == 2 {
        return normalize(vec2<f32>(-0.80, 0.60));
    }
    return normalize(vec2<f32>(0.36, -0.93));
}

fn directional_lobe(k_hat: vec2<f32>, wind: vec2<f32>, spread_back: f32) -> f32 {
    let a = dot(k_hat, wind);
    let forward = max(a, 0.0);
    let backward = max(-a, 0.0) * spread_back;
    return forward * forward + backward * backward;
}


fn spectral_band_shape(k_len: f32, cascade_index: i32) -> f32 {
    let params = cascade_params(cascade_index);
    let mode_radius = k_len * params.domain / TAU;

    // A plain Phillips spectrum puts too much visual authority into the first
    // few low-frequency bins.  WoWS-style water has strong crossing mid/short
    // wave trains, so bias each cascade toward a band of modes instead of just
    // making the ocean taller.  This keeps bulk height controlled while making
    // the geometry visibly restless.
    let remove_single_swell = smoothstep(1.25, 3.75, mode_radius);

    if cascade_index == 0 {
        let swell_band = smoothstep(2.0, 5.5, mode_radius) * (1.0 - smoothstep(14.0, 24.0, mode_radius));
        return mix(0.15, 0.58, remove_single_swell) * (0.64 + 0.24 * swell_band);
    }
    if cascade_index == 1 {
        let cross_band = smoothstep(3.0, 8.0, mode_radius) * (1.0 - smoothstep(26.0, 42.0, mode_radius));
        return mix(0.46, 1.24, remove_single_swell) * (0.88 + 0.76 * cross_band);
    }
    if cascade_index == 2 {
        let chop_band = smoothstep(5.0, 12.0, mode_radius) * (1.0 - smoothstep(34.0, 55.0, mode_radius));
        return mix(0.76, 1.46, remove_single_swell) * (0.96 + 1.05 * chop_band);
    }

    let micro_band = smoothstep(6.0, 15.0, mode_radius) * (1.0 - smoothstep(38.0, 62.0, mode_radius));
    return mix(0.92, 1.62, remove_single_swell) * (1.04 + 1.20 * micro_band);
}

fn phillips_energy(k_vec: vec2<f32>, cascade_index: i32) -> f32 {
    let params = cascade_params(cascade_index);
    let k_len = max(length(k_vec), MIN_K);
    let k2 = k_len * k_len;
    let k4 = k2 * k2;
    let k_hat = k_vec / k_len;

    // WoWS-style water reads as many overlapping, partly counteracting wave
    // trains. Keep a dominant wind direction, but seed cross and counter lobes
    // directly into H0 so the FFT field itself has interference instead of one
    // giant coherent swell.
    let primary = directional_lobe(k_hat, wind_dir_for_cascade(cascade_index), params.spread_back);
    let cross = directional_lobe(k_hat, cross_wind_dir_for_cascade(cascade_index), min(params.spread_back + 0.22, 0.85));
    let counter = directional_lobe(k_hat, counter_wind_dir_for_cascade(cascade_index), min(params.spread_back + 0.34, 0.95));
    let isotropic = 0.5 + 0.5 * abs(k_hat.x * k_hat.y);
    let directional = max(0.105, primary * 0.52 + cross * 0.26 + counter * 0.14 + isotropic * 0.08);

    let largest_wave = params.wind_speed * params.wind_speed / G;
    let low_cut = exp(-1.0 / max(k2 * largest_wave * largest_wave, 0.000001));
    let high_cut = exp(-k2 * params.damping * params.damping);

    let band_shape = spectral_band_shape(k_len, cascade_index);
    let p = params.amplitude * low_cut * high_cut * directional * band_shape / max(k4, 0.000000001);
    return max(finite_or(p, 0.0, 1000.0), 0.0);
}

fn index_to_mode(index: i32, mode_dim: i32) -> i32 {
    // FFT-native frequency order: 0, +1, +2, ..., +N/2, -N/2+1, ..., -1.
    // Earlier patches stored modes in centered order and then ran a vanilla FFT
    // over them, which effectively injected an fftshift/checker phase into the
    // spatial tile. Keep the physical k value here, but store it in native FFT
    // order so the staged IFFT produces a coherent height field.
    if index <= mode_dim / 2 {
        return index;
    }
    return index - mode_dim;
}

fn mode_to_k(ix: i32, iy: i32, cascade_index: i32) -> vec2<f32> {
    let params = cascade_params(cascade_index);
    return vec2<f32>(f32(ix), f32(iy)) * (TAU / params.domain);
}

fn h0_for_mode(ix: i32, iy: i32, cascade_index: i32) -> vec4<f32> {
    if ix == 0 && iy == 0 {
        return vec4<f32>(0.0, 0.0, 0.0, 0.0);
    }

    let params = cascade_params(cascade_index);
    let k_vec = mode_to_k(ix, iy, cascade_index);
    let k_len = length(k_vec);
    if k_len < MIN_K {
        return vec4<f32>(0.0, 0.0, 0.0, 0.0);
    }

    let energy = phillips_energy(k_vec, cascade_index);
    let g = gaussian_pair(vec2<f32>(f32(ix) + f32(cascade_index) * 37.0, f32(iy) - f32(cascade_index) * 19.0));
    let amp = min(sqrt(max(energy, 0.0) * 0.5), params.max_h0);
    let h0 = vec2<f32>(
        finite_or(g.x * amp, 0.0, params.max_h0),
        finite_or(g.y * amp, 0.0, params.max_h0)
    );

    let omega = sqrt(G * k_len) * (1.0 + f32(cascade_index) * 0.34);
    return vec4<f32>(h0.x, h0.y, omega, params.chop);
}

@compute @workgroup_size(8, 8, 1)
fn cs_main(@builtin(global_invocation_id) gid: vec3<u32>) {
    let dims = textureDimensions(h0_out);
    if gid.x >= dims.x || gid.y >= dims.y {
        return;
    }

    let mode_dim = i32(dims.x);
    let cascade_index = i32(gid.y) / mode_dim;
    let local_y = i32(gid.y) - cascade_index * mode_dim;

    let ix = index_to_mode(i32(gid.x), mode_dim);
    let iy = index_to_mode(local_y, mode_dim);
    let h0 = h0_for_mode(ix, iy, cascade_index);

    textureStore(h0_out, vec2<i32>(i32(gid.x), i32(gid.y)), h0);
}
