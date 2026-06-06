const PI: f32 = 3.141592653589793;
const N: u32 = 128u;
const LOG2_N: u32 = 7u;
const INV_N2: f32 = 0.00006103515625; // 1.0 / (128.0 * 128.0)
const CASCADE_COUNT: u32 = 4u;
const GRID_EXPONENT: f32 = 1.42;

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

struct SpectrumSample {
    h0: vec2<f32>,
    h0_conj_neg: vec2<f32>,
    k: vec2<f32>,
    k_len: f32,
    omega: f32,
};

struct FFTSample {
    value: vec2<f32>,
};

struct FieldMapSample {
    height: f32,
    slope_x: f32,
    slope_z: f32,
    disp_x: f32,
    disp_z: f32,
    _pad0: vec3<f32>,
};

struct CombinedField {
    height: f32,
    slope_x: f32,
    slope_z: f32,
    disp_x: f32,
    disp_z: f32,
};

struct ShortWaveResult {
    height: f32,
    slope: vec2<f32>,
    disp: vec2<f32>,
    foam: f32,
};

@group(0) @binding(0) var<uniform> frame: Frame;
@group(0) @binding(1) var<storage, read_write> ocean_samples: array<OceanSample>;
@group(0) @binding(2) var<storage, read> spectrum: array<SpectrumSample>;
@group(0) @binding(3) var<storage, read_write> fft_a: array<FFTSample>;
@group(0) @binding(4) var<storage, read_write> fft_b: array<FFTSample>;
@group(0) @binding(5) var<storage, read_write> field_map: array<FieldMapSample>;

fn saturate(x: f32) -> f32 {
    return clamp(x, 0.0, 1.0);
}

fn c_add(a: vec2<f32>, b: vec2<f32>) -> vec2<f32> {
    return a + b;
}

fn c_mul(a: vec2<f32>, b: vec2<f32>) -> vec2<f32> {
    return vec2<f32>(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x);
}

fn c_exp(theta: f32) -> vec2<f32> {
    return vec2<f32>(cos(theta), sin(theta));
}

fn cascade_params(index: u32) -> vec4<f32> {
    if index == 0u {
        return frame.cascade0;
    }
    if index == 1u {
        return frame.cascade1;
    }
    if index == 2u {
        return frame.cascade2;
    }
    return frame.cascade3;
}

fn rotate2(v: vec2<f32>, cs: vec2<f32>) -> vec2<f32> {
    return vec2<f32>(v.x * cs.x - v.y * cs.y, v.x * cs.y + v.y * cs.x);
}

fn rotate2_inv(v: vec2<f32>, cs: vec2<f32>) -> vec2<f32> {
    return vec2<f32>(v.x * cs.x + v.y * cs.y, -v.x * cs.y + v.y * cs.x);
}

fn cascade_rotation(index: u32) -> vec2<f32> {
    // Different sample-space rotations keep the FFT domains from stacking their
    // square lattice and wind rows in the same screen direction. The vectors are
    // precomputed cos/sin pairs.
    if index == 0u { return vec2<f32>(0.991445,  0.130526); } //  7.5 deg
    if index == 1u { return vec2<f32>(0.933580, -0.358368); } // -21.0 deg
    if index == 2u { return vec2<f32>(0.766044,  0.642788); } //  40.0 deg
    return vec2<f32>(0.642788, -0.766044);                   // -50.0 deg
}

fn cascade_sample_offset(index: u32) -> vec2<f32> {
    if index == 0u { return vec2<f32>(137.0, -91.0); }
    if index == 1u { return vec2<f32>(-53.0, 211.0); }
    if index == 2u { return vec2<f32>(19.0, -37.0); }
    return vec2<f32>(-7.0, 13.0);
}

fn spectrum_offset(cascade: u32) -> u32 {
    return cascade * N * N;
}

fn field_offset(cascade: u32) -> u32 {
    return cascade * N * N;
}

fn h_t(s: SpectrumSample) -> vec2<f32> {
    let t = frame.time * max(frame.time_scale, 0.0);
    let phase = s.omega * t;
    return c_add(c_mul(s.h0, c_exp(phase)), c_mul(s.h0_conj_neg, c_exp(-phase)));
}

fn evolve_value(i: u32, mode: u32) -> vec2<f32> {
    let s = spectrum[i];
    let h = h_t(s);

    if mode == 0u {
        return h;
    }
    if mode == 1u {
        return vec2<f32>(-s.k.x * h.y, s.k.x * h.x);
    }
    if mode == 2u {
        return vec2<f32>(-s.k.y * h.y, s.k.y * h.x);
    }
    if s.k_len <= 1e-5 {
        return vec2<f32>(0.0);
    }
    if mode == 3u {
        let f = s.k.x / s.k_len;
        return vec2<f32>(h.y * f, -h.x * f);
    }
    let f = s.k.y / s.k_len;
    return vec2<f32>(h.y * f, -h.x * f);
}

fn evolve_at(global_id: u32, mode: u32) {
    if global_id >= CASCADE_COUNT * N * N {
        return;
    }
    fft_a[global_id].value = evolve_value(global_id, mode);
}

@compute @workgroup_size(64)
fn evolve_height(@builtin(global_invocation_id) gid: vec3<u32>) {
    evolve_at(gid.x, 0u);
}

@compute @workgroup_size(64)
fn evolve_slope_x(@builtin(global_invocation_id) gid: vec3<u32>) {
    evolve_at(gid.x, 1u);
}

@compute @workgroup_size(64)
fn evolve_slope_z(@builtin(global_invocation_id) gid: vec3<u32>) {
    evolve_at(gid.x, 2u);
}

@compute @workgroup_size(64)
fn evolve_disp_x(@builtin(global_invocation_id) gid: vec3<u32>) {
    evolve_at(gid.x, 3u);
}

@compute @workgroup_size(64)
fn evolve_disp_z(@builtin(global_invocation_id) gid: vec3<u32>) {
    evolve_at(gid.x, 4u);
}

var<workgroup> fft_work: array<vec2<f32>, 128>;

fn bit_reverse(v: u32) -> u32 {
    var x = v;
    var r = 0u;
    for (var i = 0u; i < LOG2_N; i = i + 1u) {
        r = (r << 1u) | (x & 1u);
        x = x >> 1u;
    }
    return r;
}

fn fft_in_workgroup_inverse(local_i: u32) {
    var m = 2u;
    for (var stage = 0u; stage < LOG2_N; stage = stage + 1u) {
        let half = m >> 1u;
        let j = local_i % m;
        let block = local_i - j;
        let a_index = block + j;
        let b_index = a_index + half;

        if j < half {
            let theta = 2.0 * PI * f32(j) / f32(m);
            let w = c_exp(theta);
            let a = fft_work[a_index];
            let b = c_mul(fft_work[b_index], w);
            fft_work[a_index] = a + b;
            fft_work[b_index] = a - b;
        }

        workgroupBarrier();
        m = m << 1u;
    }
}

@compute @workgroup_size(128)
fn fft_rows(
    @builtin(local_invocation_id) lid: vec3<u32>,
    @builtin(workgroup_id) wid: vec3<u32>
) {
    let local_i = lid.x;
    let row = wid.y;
    let cascade = wid.z;
    if local_i >= N || row >= N || cascade >= CASCADE_COUNT {
        return;
    }

    let base = spectrum_offset(cascade);
    let read_i = bit_reverse(local_i);
    fft_work[local_i] = fft_a[base + row * N + read_i].value;
    workgroupBarrier();

    fft_in_workgroup_inverse(local_i);

    fft_b[base + row * N + local_i].value = fft_work[local_i];
}

fn store_field(i: u32, mode: u32, v: f32) {
    if mode == 0u {
        field_map[i].height = v;
    } else if mode == 1u {
        field_map[i].slope_x = v;
    } else if mode == 2u {
        field_map[i].slope_z = v;
    } else if mode == 3u {
        field_map[i].disp_x = v;
    } else {
        field_map[i].disp_z = v;
    }
}

fn fft_columns_to_field(local_z: u32, col: u32, cascade: u32, mode: u32) {
    if local_z >= N || col >= N || cascade >= CASCADE_COUNT {
        return;
    }

    let base = field_offset(cascade);
    let read_i = bit_reverse(local_z);
    fft_work[local_z] = fft_b[base + read_i * N + col].value;
    workgroupBarrier();

    fft_in_workgroup_inverse(local_z);

    let out_i = base + local_z * N + col;
    store_field(out_i, mode, fft_work[local_z].x * INV_N2);
}

@compute @workgroup_size(128)
fn fft_height_columns(
    @builtin(local_invocation_id) lid: vec3<u32>,
    @builtin(workgroup_id) wid: vec3<u32>
) {
    fft_columns_to_field(lid.x, wid.y, wid.z, 0u);
}

@compute @workgroup_size(128)
fn fft_slope_x_columns(
    @builtin(local_invocation_id) lid: vec3<u32>,
    @builtin(workgroup_id) wid: vec3<u32>
) {
    fft_columns_to_field(lid.x, wid.y, wid.z, 1u);
}

@compute @workgroup_size(128)
fn fft_slope_z_columns(
    @builtin(local_invocation_id) lid: vec3<u32>,
    @builtin(workgroup_id) wid: vec3<u32>
) {
    fft_columns_to_field(lid.x, wid.y, wid.z, 2u);
}

@compute @workgroup_size(128)
fn fft_disp_x_columns(
    @builtin(local_invocation_id) lid: vec3<u32>,
    @builtin(workgroup_id) wid: vec3<u32>
) {
    fft_columns_to_field(lid.x, wid.y, wid.z, 3u);
}

@compute @workgroup_size(128)
fn fft_disp_z_columns(
    @builtin(local_invocation_id) lid: vec3<u32>,
    @builtin(workgroup_id) wid: vec3<u32>
) {
    fft_columns_to_field(lid.x, wid.y, wid.z, 4u);
}

fn wrap_i32(v: i32, n: i32) -> i32 {
    return ((v % n) + n) % n;
}

fn field_at(cascade: u32, x: i32, z: i32) -> FieldMapSample {
    let ix = u32(wrap_i32(x, i32(N)));
    let iz = u32(wrap_i32(z, i32(N)));
    let base = field_offset(cascade);
    return field_map[base + iz * N + ix];
}

fn sample_cascade_field(cascade: u32, world_xz: vec2<f32>) -> FieldMapSample {
    let params = cascade_params(cascade);
    let domain = max(params.x, 1.0);
    let cs = cascade_rotation(cascade);
    let sample_xz = rotate2_inv(world_xz + cascade_sample_offset(cascade), cs);
    let p = fract(sample_xz / domain + vec2<f32>(0.5, 0.5)) * f32(N);
    let x0 = i32(floor(p.x));
    let z0 = i32(floor(p.y));
    let f = fract(p);

    let a = field_at(cascade, x0, z0);
    let b = field_at(cascade, x0 + 1, z0);
    let c = field_at(cascade, x0, z0 + 1);
    let d = field_at(cascade, x0 + 1, z0 + 1);

    let slope_local = vec2<f32>(
        mix(mix(a.slope_x, b.slope_x, f.x), mix(c.slope_x, d.slope_x, f.x), f.y),
        mix(mix(a.slope_z, b.slope_z, f.x), mix(c.slope_z, d.slope_z, f.x), f.y)
    );
    let disp_local = vec2<f32>(
        mix(mix(a.disp_x, b.disp_x, f.x), mix(c.disp_x, d.disp_x, f.x), f.y),
        mix(mix(a.disp_z, b.disp_z, f.x), mix(c.disp_z, d.disp_z, f.x), f.y)
    );
    let slope_world = rotate2(slope_local, cs);
    let disp_world = rotate2(disp_local, cs);

    var o: FieldMapSample;
    o.height = mix(mix(a.height, b.height, f.x), mix(c.height, d.height, f.x), f.y);
    o.slope_x = slope_world.x;
    o.slope_z = slope_world.y;
    o.disp_x = disp_world.x;
    o.disp_z = disp_world.y;
    o._pad0 = vec3<f32>(0.0);
    return o;
}

fn sample_combined_field(world_xz: vec2<f32>) -> CombinedField {
    var out: CombinedField;
    out.height = 0.0;
    out.slope_x = 0.0;
    out.slope_z = 0.0;
    out.disp_x = 0.0;
    out.disp_z = 0.0;

    for (var cascade = 0u; cascade < CASCADE_COUNT; cascade = cascade + 1u) {
        let p = cascade_params(cascade);
        let f = sample_cascade_field(cascade, world_xz);
        out.height = out.height + f.height * p.y;
        out.slope_x = out.slope_x + f.slope_x * p.z;
        out.slope_z = out.slope_z + f.slope_z * p.z;
        out.disp_x = out.disp_x + f.disp_x * p.w;
        out.disp_z = out.disp_z + f.disp_z * p.w;
    }

    return out;
}

fn cascade_contribution(world_xz: vec2<f32>) -> vec3<f32> {
    var contrib = vec3<f32>(0.0, 0.0, 0.0);
    for (var cascade = 0u; cascade < CASCADE_COUNT; cascade = cascade + 1u) {
        let p = cascade_params(cascade);
        let f = sample_cascade_field(cascade, world_xz);
        let v = abs(f.height * p.y) * 0.75 + length(vec2<f32>(f.slope_x, f.slope_z)) * p.z * 0.12;
        if cascade == 0u {
            contrib.x = v;
        } else if cascade == 1u {
            contrib.y = v;
        } else {
            contrib.z = v;
        }
    }
    let total = contrib.x + contrib.y + contrib.z;
    if total > 1e-5 {
        return contrib / total;
    }
    return vec3<f32>(0.0, 0.0, 0.0);
}

fn ocean_origin() -> vec2<f32> {
    return frame.ocean_origin;
}

fn grid_uv(ix: u32, iz: u32) -> vec2<f32> {
    let res = max(frame.plane_resolution, 1.0);
    return vec2<f32>(f32(ix) / res, f32(iz) / res);
}

fn grid_local_xz(ix: u32, iz: u32) -> vec2<f32> {
    let uv = grid_uv(ix, iz);
    let q = uv * 2.0 - vec2<f32>(1.0, 1.0);
    let sign_q = sign(q);
    let warped = sign_q * pow(abs(q), vec2<f32>(GRID_EXPONENT, GRID_EXPONENT));
    return warped * (frame.plane_size * 0.5);
}

fn square_edge_fade(uv: vec2<f32>) -> f32 {
    let q = abs(uv * 2.0 - vec2<f32>(1.0, 1.0));
    let edge = max(q.x, q.y);
    // Keep most of the 7.6 km mesh fully alive, then fade very gently into the
    // sky shader's far-ocean layer. This prevents high-camera views from seeing
    // an abrupt end while preserving near/mid geometry.
    return 1.0 - smoothstep(0.82, 0.998, edge);
}

fn short_wave_dir(i: u32, wind: vec2<f32>, cross_wind: vec2<f32>) -> vec2<f32> {
    // Broadly distributed directions: WoWS-like water reads as many little
    // intersecting ripples riding over larger waves, not a single conveyor belt.
    if i == 0u { return normalize(wind * 1.00 + cross_wind * 0.05); }
    if i == 1u { return normalize(wind * 0.90 + cross_wind * 0.44); }
    if i == 2u { return normalize(wind * 0.68 + cross_wind * 0.74); }
    if i == 3u { return normalize(wind * 0.38 + cross_wind * 0.93); }
    if i == 4u { return normalize(wind * 0.04 + cross_wind * 1.00); }
    if i == 5u { return normalize(-wind * 0.30 + cross_wind * 0.95); }
    if i == 6u { return normalize(-wind * 0.62 + cross_wind * 0.78); }
    if i == 7u { return normalize(-wind * 0.86 + cross_wind * 0.50); }
    if i == 8u { return normalize(-wind * 0.99 + cross_wind * 0.10); }
    if i == 9u { return normalize(-wind * 0.92 - cross_wind * 0.38); }
    if i == 10u { return normalize(-wind * 0.68 - cross_wind * 0.74); }
    if i == 11u { return normalize(-wind * 0.34 - cross_wind * 0.94); }
    if i == 12u { return normalize(wind * 0.02 - cross_wind * 1.00); }
    if i == 13u { return normalize(wind * 0.38 - cross_wind * 0.93); }
    if i == 14u { return normalize(wind * 0.70 - cross_wind * 0.72); }
    if i == 15u { return normalize(wind * 0.92 - cross_wind * 0.39); }
    if i == 16u { return normalize(wind * 0.54 + cross_wind * 0.84); }
    if i == 17u { return normalize(-wind * 0.52 + cross_wind * 0.85); }
    return normalize(wind * 0.22 - cross_wind * 0.98);
}

fn short_wave_filter(wavelength: f32, footprint: f32) -> f32 {
    // Vertex-space sine waves below the local cell footprint alias into the
    // obvious screen-door/grid pattern seen while zooming. Keep sub-cell detail in
    // the fragment normal layer instead of baking it into mesh displacement.
    return smoothstep(2.15, 4.65, wavelength / max(footprint, 0.05));
}

fn short_wave_warp(world_xz: vec2<f32>, wavelength: f32, phase_offset: f32) -> vec2<f32> {
    let t = frame.time * max(frame.time_scale, 0.0);
    let a = sin(dot(world_xz, vec2<f32>(0.031, 0.017)) + t * 0.13 + phase_offset);
    let b = cos(dot(world_xz, vec2<f32>(-0.019, 0.037)) - t * 0.10 + phase_offset * 0.73);
    return vec2<f32>(a, b) * min(wavelength * 0.16, 2.6);
}

fn add_short_wave(
    r0: ShortWaveResult,
    world_xz: vec2<f32>,
    dir: vec2<f32>,
    wavelength: f32,
    amp: f32,
    speed: f32,
    phase_offset: f32,
    footprint: f32
) -> ShortWaveResult {
    var r = r0;
    let filter = short_wave_filter(wavelength, footprint);
    let k = 2.0 * PI / wavelength;
    let t = frame.time * max(frame.time_scale, 0.0);
    let warped_xz = world_xz + short_wave_warp(world_xz, wavelength, phase_offset);
    let phase = dot(warped_xz, dir) * k + t * speed + phase_offset;
    let s = sin(phase);
    let c = cos(phase);
    let s2 = sin(phase * 2.0 + phase_offset * 0.37);
    let c2 = cos(phase * 2.0 + phase_offset * 0.37);

    // Sharpen crests slightly but keep these as small wavelets layered over the
    // FFT water. The adaptive filter is what prevents the close-camera grid.
    let a = amp * filter;
    let shaped = s + 0.20 * s2;
    let slope = a * k * (c + 0.40 * c2);
    r.height = r.height + a * shaped;
    r.slope = r.slope + dir * slope;
    r.disp = r.disp - dir * (a * 0.075 * c);
    r.foam = max(r.foam, smoothstep(0.36, 0.92, abs(slope)) * smoothstep(0.56, 0.93, s) * filter);
    return r;
}

fn short_wave_field(world_xz: vec2<f32>, footprint: f32) -> ShortWaveResult {
    let wind = normalize(vec2<f32>(frame.wind_dir_x, frame.wind_dir_z));
    let cross_wind = vec2<f32>(-wind.y, wind.x);

    var r: ShortWaveResult;
    r.height = 0.0;
    r.slope = vec2<f32>(0.0);
    r.disp = vec2<f32>(0.0);
    r.foam = 0.0;

    // Geometry-scale ripples. These are deliberately many, low, and fast: they
    // create intersecting small waves riding on the FFT field rather than adding
    // a few obvious sine rows.
    r = add_short_wave(r, world_xz, short_wave_dir(0u, wind, cross_wind), 12.5, 0.043,  1.36, 0.3, footprint);
    r = add_short_wave(r, world_xz, short_wave_dir(1u, wind, cross_wind), 9.4,  0.037, -1.68, 1.2, footprint);
    r = add_short_wave(r, world_xz, short_wave_dir(2u, wind, cross_wind), 7.6,  0.031,  2.02, 2.1, footprint);
    r = add_short_wave(r, world_xz, short_wave_dir(3u, wind, cross_wind), 6.2,  0.026, -2.32, 3.5, footprint);
    r = add_short_wave(r, world_xz, short_wave_dir(4u, wind, cross_wind), 5.2,  0.022,  2.56, 4.7, footprint);
    r = add_short_wave(r, world_xz, short_wave_dir(5u, wind, cross_wind), 4.4,  0.018, -2.86, 5.8, footprint);
    r = add_short_wave(r, world_xz, short_wave_dir(6u, wind, cross_wind), 3.7,  0.014,  3.12, 0.9, footprint);
    r = add_short_wave(r, world_xz, short_wave_dir(7u, wind, cross_wind), 3.1,  0.011, -3.40, 2.8, footprint);
    r = add_short_wave(r, world_xz, short_wave_dir(8u, wind, cross_wind), 2.6,  0.008,  3.68, 4.1, footprint);
    r = add_short_wave(r, world_xz, short_wave_dir(9u, wind, cross_wind), 2.2,  0.006, -3.96, 5.3, footprint);
    r = add_short_wave(r, world_xz, short_wave_dir(10u, wind, cross_wind), 1.85, 0.0042, 4.32, 1.6, footprint);
    r = add_short_wave(r, world_xz, short_wave_dir(11u, wind, cross_wind), 1.55, 0.0030, -4.62, 3.2, footprint);
    r = add_short_wave(r, world_xz, short_wave_dir(12u, wind, cross_wind), 1.32, 0.0022, 4.90, 4.9, footprint);
    r = add_short_wave(r, world_xz, short_wave_dir(13u, wind, cross_wind), 1.10, 0.0016, -5.18, 0.4, footprint);
    r = add_short_wave(r, world_xz, short_wave_dir(14u, wind, cross_wind), 0.94, 0.0011, 5.48, 2.6, footprint);
    r = add_short_wave(r, world_xz, short_wave_dir(15u, wind, cross_wind), 0.78, 0.0008, -5.72, 4.4, footprint);
    return r;
}


fn medium_wave_dir(i: u32, wind: vec2<f32>, cross_wind: vec2<f32>) -> vec2<f32> {
    // Low/mid-frequency relief intentionally comes from multiple headings. This
    // adds WoWS-like confused sea shape without depending on a single wind row.
    if i == 0u { return normalize(wind * 0.92 + cross_wind * 0.38); }
    if i == 1u { return normalize(wind * 0.52 - cross_wind * 0.85); }
    if i == 2u { return normalize(-wind * 0.18 + cross_wind * 0.98); }
    if i == 3u { return normalize(-wind * 0.64 - cross_wind * 0.77); }
    if i == 4u { return normalize(wind * 0.20 + cross_wind * 0.98); }
    if i == 5u { return normalize(-wind * 0.88 + cross_wind * 0.47); }
    if i == 6u { return normalize(wind * 0.76 - cross_wind * 0.65); }
    return normalize(-wind * 0.36 - cross_wind * 0.93);
}

fn medium_wave_warp(world_xz: vec2<f32>, phase_offset: f32) -> vec2<f32> {
    let t = frame.time * max(frame.time_scale, 0.0);
    let a = sin(dot(world_xz, vec2<f32>(0.010, -0.017)) + t * 0.055 + phase_offset);
    let b = cos(dot(world_xz, vec2<f32>(-0.014, 0.009)) - t * 0.047 + phase_offset * 0.61);
    return vec2<f32>(a, b) * 5.2;
}

fn add_medium_wave(
    r0: ShortWaveResult,
    world_xz: vec2<f32>,
    dir: vec2<f32>,
    wavelength: f32,
    amp: f32,
    speed: f32,
    phase_offset: f32,
    chop: f32
) -> ShortWaveResult {
    var r = r0;
    let k = 2.0 * PI / wavelength;
    let t = frame.time * max(frame.time_scale, 0.0);
    let warped_xz = world_xz + medium_wave_warp(world_xz, phase_offset);
    let phase = dot(warped_xz, dir) * k + t * speed + phase_offset;
    let s = sin(phase);
    let c = cos(phase);
    let s2 = sin(phase * 2.0 + phase_offset * 0.27);
    let c2 = cos(phase * 2.0 + phase_offset * 0.27);
    let shaped = s + 0.16 * s2;

    r.height = r.height + amp * shaped;
    r.slope = r.slope + dir * (amp * k * (c + 0.32 * c2));
    r.disp = r.disp - dir * (amp * chop * c);
    r.foam = max(r.foam, smoothstep(0.42, 1.15, abs(amp * k * (c + 0.32 * c2))) * smoothstep(0.56, 0.94, s));
    return r;
}

fn medium_wave_field(world_xz: vec2<f32>) -> ShortWaveResult {
    let wind = normalize(vec2<f32>(frame.wind_dir_x, frame.wind_dir_z));
    let cross_wind = vec2<f32>(-wind.y, wind.x);

    var r: ShortWaveResult;
    r.height = 0.0;
    r.slope = vec2<f32>(0.0);
    r.disp = vec2<f32>(0.0);
    r.foam = 0.0;

    // Shorter medium waves than the previous pass: the overall height remains in
    // the same range, but the height changes over tens of meters instead of broad
    // cloudy hundred-meter slabs.
    r = add_medium_wave(r, world_xz, medium_wave_dir(0u, wind, cross_wind), 72.0, 0.17,  0.92, 0.2, 0.50);
    r = add_medium_wave(r, world_xz, medium_wave_dir(1u, wind, cross_wind), 54.0, 0.145, -1.10, 1.4, 0.46);
    r = add_medium_wave(r, world_xz, medium_wave_dir(2u, wind, cross_wind), 41.0, 0.118,  1.28, 2.8, 0.40);
    r = add_medium_wave(r, world_xz, medium_wave_dir(3u, wind, cross_wind), 31.0, 0.095, -1.48, 4.1, 0.35);
    r = add_medium_wave(r, world_xz, medium_wave_dir(4u, wind, cross_wind), 23.5, 0.074,  1.70, 5.5, 0.30);
    r = add_medium_wave(r, world_xz, medium_wave_dir(5u, wind, cross_wind), 18.0, 0.055, -1.96, 0.9, 0.25);
    r = add_medium_wave(r, world_xz, medium_wave_dir(6u, wind, cross_wind), 13.8, 0.040,  2.22, 2.2, 0.20);
    r = add_medium_wave(r, world_xz, medium_wave_dir(7u, wind, cross_wind), 10.6, 0.028, -2.50, 3.7, 0.16);
    return r;
}

fn min_cascade_domain() -> f32 {
    return min(min(frame.cascade0.x, frame.cascade1.x), min(frame.cascade2.x, frame.cascade3.x));
}

@compute @workgroup_size(64)
fn finalize_samples(@builtin(global_invocation_id) gid: vec3<u32>) {
    let vertex_id = gid.x;
    if vertex_id >= arrayLength(&ocean_samples) {
        return;
    }

    let grid_res = u32(frame.plane_resolution);
    let stride = grid_res + 1u;
    let ix = vertex_id % stride;
    let iz = vertex_id / stride;

    let uv = grid_uv(ix, iz);
    let local_xz = grid_local_xz(ix, iz);
    let edge = square_edge_fade(uv);
    let edge_geom = edge * edge;
    let world_xz = ocean_origin() + local_xz;

    let combined = sample_combined_field(world_xz);
    let px = grid_local_xz(min(ix + 1u, grid_res), iz);
    let pz = grid_local_xz(ix, min(iz + 1u, grid_res));
    let cell_footprint = max(0.35, max(length(px - local_xz), length(pz - local_xz)));
    let derivative_step = max(min_cascade_domain() / f32(N), 0.42);
    let xp = sample_combined_field(world_xz + vec2<f32>(derivative_step, 0.0));
    let xm = sample_combined_field(world_xz - vec2<f32>(derivative_step, 0.0));
    let zp = sample_combined_field(world_xz + vec2<f32>(0.0, derivative_step));
    let zm = sample_combined_field(world_xz - vec2<f32>(0.0, derivative_step));

    let fft_scale = max(frame.fft_height_scale, 0.0);
    let ddx_dx = ((xp.disp_x - xm.disp_x) * fft_scale * frame.chop_scale * edge_geom) / (2.0 * derivative_step);
    let ddz_dx = ((xp.disp_z - xm.disp_z) * fft_scale * frame.chop_scale * edge_geom) / (2.0 * derivative_step);
    let ddx_dz = ((zp.disp_x - zm.disp_x) * fft_scale * frame.chop_scale * edge_geom) / (2.0 * derivative_step);
    let ddz_dz = ((zp.disp_z - zm.disp_z) * fft_scale * frame.chop_scale * edge_geom) / (2.0 * derivative_step);
    let jacobian = (1.0 + ddx_dx) * (1.0 + ddz_dz) - ddx_dz * ddz_dx;

    let local_dist = max(abs(local_xz.x), abs(local_xz.y));
    let near_detail = (1.0 - smoothstep(1450.0, 3100.0, local_dist)) * edge_geom;
    let sw = short_wave_field(world_xz, cell_footprint);
    let mw = medium_wave_field(world_xz);
    let broad_energy = smoothstep(0.03, 0.32, abs(combined.height * fft_scale + mw.height)) +
        smoothstep(0.10, 0.55, length(vec2<f32>(combined.slope_x, combined.slope_z) * fft_scale + mw.slope));
    let medium_strength = edge_geom * (0.95 + broad_energy * 0.06);
    let short_strength = near_detail * (0.28 + clamp(frame.normal_detail_scale, 0.0, 3.8) * 0.08) * (0.82 + broad_energy * 0.10);

    let height = (combined.height * fft_scale + mw.height * medium_strength) * edge_geom + sw.height * short_strength * 0.20;
    let slope_x = (combined.slope_x * fft_scale + mw.slope.x * medium_strength) * edge_geom + sw.slope.x * short_strength * 0.48;
    let slope_z = (combined.slope_z * fft_scale + mw.slope.y * medium_strength) * edge_geom + sw.slope.y * short_strength * 0.48;
    let disp_x = (combined.disp_x * fft_scale * frame.chop_scale + mw.disp.x * medium_strength) * edge_geom + sw.disp.x * short_strength * 0.20;
    let disp_z = (combined.disp_z * fft_scale * frame.chop_scale + mw.disp.y * medium_strength) * edge_geom + sw.disp.y * short_strength * 0.20;
    let slope_mag = length(vec2<f32>(slope_x, slope_z)) * frame.height_scale;

    let fold_foam = smoothstep(frame.foam_threshold + 0.08, frame.foam_threshold - 0.10, jacobian);
    let crest_foam = smoothstep(0.035, 0.28, height * frame.height_scale) * smoothstep(0.20, 0.72, slope_mag);
    let ripple_foam = sw.foam * smoothstep(0.28, 0.82, slope_mag);
    let medium_foam = mw.foam * smoothstep(0.18, 0.60, slope_mag);
    let foam = saturate((fold_foam * 0.28 + crest_foam * 0.48 + ripple_foam * 0.34 + medium_foam * 0.18) * frame.foam_amount * edge);

    ocean_samples[vertex_id].height = height;
    ocean_samples[vertex_id].slope_x = slope_x;
    ocean_samples[vertex_id].slope_z = slope_z;
    ocean_samples[vertex_id].disp_x = disp_x;
    ocean_samples[vertex_id].disp_z = disp_z;
    ocean_samples[vertex_id].jacobian = jacobian;
    ocean_samples[vertex_id].foam = foam;
    ocean_samples[vertex_id].edge_fade = edge;
    ocean_samples[vertex_id].cascade_mix = cascade_contribution(world_xz);
    ocean_samples[vertex_id]._pad = 0.0;
}
