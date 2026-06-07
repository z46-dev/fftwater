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

// Persistent H0(k) modes from ocean_init.wgsl.
// RGBA layout:
//   R = H0 real
//   G = H0 imaginary
//   B = angular frequency omega(k)
//   A = cascade displacement/chop scale
@group(0) @binding(1)
var h0_modes: texture_2d<f32>;

// Packed primary spectra consumed by ocean_fft.wgsl.
// RG = height H(k,t)
// BA = horizontal displacement X spectrum, -i*kx/|k|*H(k,t)
@group(0) @binding(2)
var evolved_primary_out: texture_storage_2d<rgba32float, write>;

// Packed auxiliary spectra consumed by ocean_fft.wgsl.
// RG = horizontal displacement Z spectrum, -i*kz/|k|*H(k,t)
// BA = curvature spectrum, -|k|^2*H(k,t), used as a crest/foam seed
@group(0) @binding(3)
var evolved_aux_out: texture_storage_2d<rgba32float, write>;

const TAU: f32 = 6.28318530718;
const G: f32 = 9.81;
const MIN_K: f32 = 0.0001;

fn finite_or(v: f32, fallback: f32, limit: f32) -> f32 {
    let good = (v == v) && abs(v) <= limit;
    return select(fallback, clamp(v, -limit, limit), good);
}

fn sanitize_h0(v: vec4<f32>) -> vec4<f32> {
    return vec4<f32>(
        finite_or(v.x, 0.0, 4.0),
        finite_or(v.y, 0.0, 4.0),
        finite_or(v.z, 0.0, 20.0),
        finite_or(v.w, 0.0, 6.0)
    );
}

fn sanitize_complex(v: vec2<f32>, limit: f32) -> vec2<f32> {
    return vec2<f32>(finite_or(v.x, 0.0, limit), finite_or(v.y, 0.0, limit));
}

fn complex_mul(a: vec2<f32>, b: vec2<f32>) -> vec2<f32> {
    return vec2<f32>(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x);
}

fn complex_mul_minus_i_scale(h: vec2<f32>, scale: f32) -> vec2<f32> {
    // -i * scale * (a + ib) = scale*b - i*scale*a.
    return vec2<f32>(scale * h.y, -scale * h.x);
}

fn cascade_domain(index: i32) -> f32 {
    if index == 0 {
        return 900.0;
    }
    if index == 1 {
        return 360.0;
    }
    if index == 2 {
        return 150.0;
    }
    return 62.0;
}

fn index_to_mode(index: i32, mode_dim: i32) -> i32 {
    // Must match ocean_init.wgsl: spectra are stored in FFT-native frequency
    // order, not centered order. A vanilla staged IFFT expects DC at texel 0,
    // positive frequencies next, and wrapped negative frequencies at the end.
    if index <= mode_dim / 2 {
        return index;
    }
    return index - mode_dim;
}

fn mode_to_index(mode: i32, mode_dim: i32) -> i32 {
    return ((mode % mode_dim) + mode_dim) % mode_dim;
}

fn mode_to_k(ix: i32, iy: i32, cascade_index: i32) -> vec2<f32> {
    return vec2<f32>(f32(ix), f32(iy)) * (TAU / cascade_domain(cascade_index));
}

fn coord_for_mode(ix: i32, iy: i32, cascade_index: i32, mode_dim: i32, total_h: i32) -> vec2<i32> {
    let coord = vec2<i32>(
        mode_to_index(ix, mode_dim),
        cascade_index * mode_dim + mode_to_index(iy, mode_dim)
    );

    if coord.x < 0 || coord.y < 0 || coord.x >= mode_dim || coord.y >= total_h {
        return vec2<i32>(-1, -1);
    }

    return coord;
}

fn load_h0(ix: i32, iy: i32, cascade_index: i32, mode_dim: i32, total_h: i32) -> vec4<f32> {
    let coord = coord_for_mode(ix, iy, cascade_index, mode_dim, total_h);
    if coord.x < 0 {
        return vec4<f32>(0.0, 0.0, 0.0, 0.0);
    }
    return sanitize_h0(textureLoad(h0_modes, coord, 0));
}

@compute @workgroup_size(8, 8, 1)
fn cs_main(@builtin(global_invocation_id) gid: vec3<u32>) {
    let dims = textureDimensions(h0_modes, 0);
    if gid.x >= dims.x || gid.y >= dims.y {
        return;
    }

    let mode_dim = i32(dims.x);
    let total_h = i32(dims.y);
    let cascade_index = i32(gid.y) / mode_dim;
    let local_y = i32(gid.y) - cascade_index * mode_dim;

    let ix = index_to_mode(i32(gid.x), mode_dim);
    let iy = index_to_mode(local_y, mode_dim);
    let coord = vec2<i32>(i32(gid.x), i32(gid.y));

    if ix == 0 && iy == 0 {
        textureStore(evolved_primary_out, coord, vec4<f32>(0.0, 0.0, 0.0, 0.0));
        textureStore(evolved_aux_out, coord, vec4<f32>(0.0, 0.0, 0.0, 0.0));
        return;
    }

    let k_vec = mode_to_k(ix, iy, cascade_index);
    let k_len = length(k_vec);
    if k_len < MIN_K {
        textureStore(evolved_primary_out, coord, vec4<f32>(0.0, 0.0, 0.0, 0.0));
        textureStore(evolved_aux_out, coord, vec4<f32>(0.0, 0.0, 0.0, 0.0));
        return;
    }

    let h0_k = load_h0(ix, iy, cascade_index, mode_dim, total_h);
    let h0_neg = load_h0(-ix, -iy, cascade_index, mode_dim, total_h);

    // H(k,t) = H0(k) exp(i omega t) + conj(H0(-k)) exp(-i omega t).
    let omega = max(h0_k.z, sqrt(G * k_len));
    let angle = omega * frame.resolution_time_grid.z;
    let rot_pos = vec2<f32>(cos(angle), sin(angle));
    let rot_neg = vec2<f32>(cos(angle), -sin(angle));

    let term_pos = complex_mul(h0_k.xy, rot_pos);
    let term_neg = complex_mul(vec2<f32>(h0_neg.x, -h0_neg.y), rot_neg);
    let h = sanitize_complex(term_pos + term_neg, 8.0);

    let k_hat = k_vec / k_len;
    let chop = finite_or(h0_k.w, 0.0, 4.0);

    // Real vector displacement spectra.  This replaces the previous render-time
    // slope hack with the usual choppy-water spectral form:
    //   D_x(k) = -i * k_x/|k| * H(k)
    //   D_z(k) = -i * k_z/|k| * H(k)
    let dx = sanitize_complex(complex_mul_minus_i_scale(h, k_hat.x * chop), 20.0);
    let dz = sanitize_complex(complex_mul_minus_i_scale(h, k_hat.y * chop), 20.0);

    // Curvature is linear in frequency space, so it gets its own FFT too.
    let curvature = sanitize_complex(h * (-k_len * k_len), 10.0);

    textureStore(evolved_primary_out, coord, vec4<f32>(h.x, h.y, dx.x, dx.y));
    textureStore(evolved_aux_out, coord, vec4<f32>(dz.x, dz.y, curvature.x, curvature.y));
}
