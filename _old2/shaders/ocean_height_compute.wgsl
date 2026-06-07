const PI: f32 = 3.141592653589793;
const N: u32 = 128u;
const LOG2_N: u32 = 7u;
const INV_N2: f32 = 0.00006103515625;
const CASCADE_COUNT: u32 = 4u;

// Must match internal/ocean/mesh.go.
const MESH_RES: u32 = 544u;
const MESH_OUTER: f32 = 5200.0;
const PROJECTED_GRID_SCALE: f32 = 4.80;

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

struct WaveLayers {
    // signed height, energy, geom LOD weight, variation for support/main/chop/capillary.
    support: vec4<f32>,
    wind: vec4<f32>,
    chop: vec4<f32>,
    capillary: vec4<f32>,
};

struct FoamLayers {
    // crest/fold/foam are separate query products, not a single final mask.
    crest: vec4<f32>,
    fold: vec4<f32>,
    foam: vec4<f32>,
};

struct OpticalLayers {
    // Material/reflection layer data is separated from displacement and foam.
    absorption: vec4<f32>,
    scatter: vec4<f32>,
    reflection: vec4<f32>,
    lod: vec4<f32>,
};

struct MeshCoord {
    local_xz: vec2<f32>,
    uv: vec2<f32>,
    level: f32,
};

struct WaveQuery {
    height: f32,
    slope: vec2<f32>,
    disp: vec2<f32>,
    height0: f32,
    height1: f32,
    height2: f32,
    height3: f32,
    slope0: f32,
    slope1: f32,
    slope2: f32,
    slope3: f32,
    energy0: f32,
    energy1: f32,
    energy2: f32,
    energy3: f32,
    jacobian: f32,
};

struct DeformSample {
    height: f32,
    slope: vec2<f32>,
    disp: vec2<f32>,
    crest: f32,
    foam: f32,
    space: f32,
    detail: f32,
};

@group(0) @binding(0) var<uniform> frame: Frame;
@group(0) @binding(1) var<storage, read_write> ocean_samples: array<OceanSample>;
@group(0) @binding(2) var<storage, read> spectrum: array<SpectrumSample>;
@group(0) @binding(3) var<storage, read_write> fft_a: array<FFTSample>;
@group(0) @binding(4) var<storage, read_write> fft_b: array<FFTSample>;
@group(0) @binding(5) var<storage, read_write> field_map: array<FieldMapSample>;
@group(0) @binding(6) var<storage, read_write> wave_layers: array<WaveLayers>;
@group(0) @binding(7) var<storage, read_write> foam_layers: array<FoamLayers>;
@group(0) @binding(8) var<storage, read_write> optical_layers: array<OpticalLayers>;

var<workgroup> fft_work: array<vec2<f32>, 128>;

fn saturate(x: f32) -> f32 { return clamp(x, 0.0, 1.0); }

fn safe_normalize2(v: vec2<f32>) -> vec2<f32> {
    let l = length(v);
    if l < 0.00001 { return vec2<f32>(1.0, 0.0); }
    return v / l;
}

fn c_mul(a: vec2<f32>, b: vec2<f32>) -> vec2<f32> {
    return vec2<f32>(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x);
}

fn c_exp(theta: f32) -> vec2<f32> { return vec2<f32>(cos(theta), sin(theta)); }

fn rotate2(v: vec2<f32>, cs: vec2<f32>) -> vec2<f32> {
    return vec2<f32>(v.x * cs.x - v.y * cs.y, v.x * cs.y + v.y * cs.x);
}

fn rotate2_inv(v: vec2<f32>, cs: vec2<f32>) -> vec2<f32> {
    return vec2<f32>(v.x * cs.x + v.y * cs.y, -v.x * cs.y + v.y * cs.x);
}

fn hash21(p: vec2<f32>) -> f32 {
    return fract(sin(dot(p, vec2<f32>(127.1, 311.7))) * 43758.5453);
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

fn ocean_origin() -> vec2<f32> { return frame.ocean_origin; }

fn cascade_params(index: u32) -> vec4<f32> {
    if index == 0u { return frame.cascade0; }
    if index == 1u { return frame.cascade1; }
    if index == 2u { return frame.cascade2; }
    return frame.cascade3;
}

fn cascade_rotation(index: u32) -> vec2<f32> {
    if index == 0u { return vec2<f32>(0.991445, 0.130526); }
    if index == 1u { return vec2<f32>(0.933580, -0.358368); }
    if index == 2u { return vec2<f32>(0.766044, 0.642788); }
    return vec2<f32>(0.642788, -0.766044);
}

fn cascade_rotation_alt(index: u32) -> vec2<f32> {
    if index == 0u { return vec2<f32>(0.984808, -0.173648); }
    if index == 1u { return vec2<f32>(0.601815, 0.798636); }
    if index == 2u { return vec2<f32>(0.104528, -0.994522); }
    return vec2<f32>(0.939693, 0.342020);
}

fn cascade_sample_offset(index: u32) -> vec2<f32> {
    if index == 0u { return vec2<f32>(137.0, -91.0); }
    if index == 1u { return vec2<f32>(-53.0, 211.0); }
    if index == 2u { return vec2<f32>(19.0, -37.0); }
    return vec2<f32>(-7.0, 13.0);
}

fn spectrum_offset(cascade: u32) -> u32 { return cascade * N * N; }
fn field_offset(cascade: u32) -> u32 { return cascade * N * N; }

fn h_t(s: SpectrumSample) -> vec2<f32> {
    let t = frame.time * max(frame.time_scale, 0.0);
    let phase = s.omega * t;
    return c_mul(s.h0, c_exp(phase)) + c_mul(s.h0_conj_neg, c_exp(-phase));
}

fn evolve_value(i: u32, mode: u32) -> vec2<f32> {
    let s = spectrum[i];
    let h = h_t(s);
    if mode == 0u { return h; }
    if mode == 1u { return vec2<f32>(-s.k.x * h.y, s.k.x * h.x); }
    if mode == 2u { return vec2<f32>(-s.k.y * h.y, s.k.y * h.x); }
    if s.k_len <= 0.00001 { return vec2<f32>(0.0); }
    if mode == 3u {
        let f = s.k.x / s.k_len;
        return vec2<f32>(h.y * f, -h.x * f);
    }
    let f = s.k.y / s.k_len;
    return vec2<f32>(h.y * f, -h.x * f);
}

fn evolve_at(global_id: u32, mode: u32) {
    if global_id >= CASCADE_COUNT * N * N { return; }
    fft_a[global_id].value = evolve_value(global_id, mode);
}

@compute @workgroup_size(64, 1, 1)
fn evolve_height(@builtin(global_invocation_id) gid: vec3<u32>) { evolve_at(gid.x, 0u); }

@compute @workgroup_size(64, 1, 1)
fn evolve_slope_x(@builtin(global_invocation_id) gid: vec3<u32>) { evolve_at(gid.x, 1u); }

@compute @workgroup_size(64, 1, 1)
fn evolve_slope_z(@builtin(global_invocation_id) gid: vec3<u32>) { evolve_at(gid.x, 2u); }

@compute @workgroup_size(64, 1, 1)
fn evolve_disp_x(@builtin(global_invocation_id) gid: vec3<u32>) { evolve_at(gid.x, 3u); }

@compute @workgroup_size(64, 1, 1)
fn evolve_disp_z(@builtin(global_invocation_id) gid: vec3<u32>) { evolve_at(gid.x, 4u); }

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

@compute @workgroup_size(128, 1, 1)
fn fft_rows(@builtin(local_invocation_id) lid: vec3<u32>, @builtin(workgroup_id) wid: vec3<u32>) {
    let local_i = lid.x;
    let row = wid.y;
    let cascade = wid.z;
    if local_i >= N || row >= N || cascade >= CASCADE_COUNT { return; }
    let base = spectrum_offset(cascade);
    let read_i = bit_reverse(local_i);
    fft_work[local_i] = fft_a[base + row * N + read_i].value;
    workgroupBarrier();
    fft_in_workgroup_inverse(local_i);
    fft_b[base + row * N + local_i].value = fft_work[local_i];
}

fn store_field(i: u32, mode: u32, v: f32) {
    if mode == 0u { field_map[i].height = v; }
    else if mode == 1u { field_map[i].slope_x = v; }
    else if mode == 2u { field_map[i].slope_z = v; }
    else if mode == 3u { field_map[i].disp_x = v; }
    else { field_map[i].disp_z = v; }
}

fn fft_columns_to_field(local_z: u32, col: u32, cascade: u32, mode: u32) {
    if local_z >= N || col >= N || cascade >= CASCADE_COUNT { return; }
    let base = field_offset(cascade);
    let read_i = bit_reverse(local_z);
    fft_work[local_z] = fft_b[base + read_i * N + col].value;
    workgroupBarrier();
    fft_in_workgroup_inverse(local_z);
    let out_i = base + local_z * N + col;
    store_field(out_i, mode, fft_work[local_z].x * INV_N2);
}

@compute @workgroup_size(128, 1, 1)
fn fft_height_columns(@builtin(local_invocation_id) lid: vec3<u32>, @builtin(workgroup_id) wid: vec3<u32>) {
    fft_columns_to_field(lid.x, wid.y, wid.z, 0u);
}

@compute @workgroup_size(128, 1, 1)
fn fft_slope_x_columns(@builtin(local_invocation_id) lid: vec3<u32>, @builtin(workgroup_id) wid: vec3<u32>) {
    fft_columns_to_field(lid.x, wid.y, wid.z, 1u);
}

@compute @workgroup_size(128, 1, 1)
fn fft_slope_z_columns(@builtin(local_invocation_id) lid: vec3<u32>, @builtin(workgroup_id) wid: vec3<u32>) {
    fft_columns_to_field(lid.x, wid.y, wid.z, 2u);
}

@compute @workgroup_size(128, 1, 1)
fn fft_displacement_x_columns(@builtin(local_invocation_id) lid: vec3<u32>, @builtin(workgroup_id) wid: vec3<u32>) {
    fft_columns_to_field(lid.x, wid.y, wid.z, 3u);
}

@compute @workgroup_size(128, 1, 1)
fn fft_displacement_z_columns(@builtin(local_invocation_id) lid: vec3<u32>, @builtin(workgroup_id) wid: vec3<u32>) {
    fft_columns_to_field(lid.x, wid.y, wid.z, 4u);
}

fn wrap_i32(v: i32, n: i32) -> i32 { return ((v % n) + n) % n; }

fn field_at(cascade: u32, x: i32, z: i32) -> FieldMapSample {
    let ix = u32(wrap_i32(x, i32(N)));
    let iz = u32(wrap_i32(z, i32(N)));
    return field_map[field_offset(cascade) + iz * N + ix];
}

fn sample_field_once(cascade: u32, world_xz: vec2<f32>, offset: vec2<f32>, cs: vec2<f32>, scale: f32) -> FieldMapSample {
    let domain = max(cascade_params(cascade).x, 1.0);
    let sample_xz = rotate2_inv(world_xz * scale + offset, cs);
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
    let slope_world = rotate2(slope_local, cs) * scale;
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

fn mix_field(a: FieldMapSample, b: FieldMapSample, w: f32) -> FieldMapSample {
    var o: FieldMapSample;
    o.height = mix(a.height, b.height, w);
    o.slope_x = mix(a.slope_x, b.slope_x, w);
    o.slope_z = mix(a.slope_z, b.slope_z, w);
    o.disp_x = mix(a.disp_x, b.disp_x, w);
    o.disp_z = mix(a.disp_z, b.disp_z, w);
    o._pad0 = vec3<f32>(0.0);
    return o;
}

fn sample_cascade_field(cascade: u32, world_xz: vec2<f32>) -> FieldMapSample {
    let primary = sample_field_once(cascade, world_xz, cascade_sample_offset(cascade), cascade_rotation(cascade), 1.0);
    if cascade < 2u { return primary; }
    let domain = max(cascade_params(cascade).x, 1.0);
    let alt_offset = cascade_sample_offset(cascade) * 1.733 + vec2<f32>(domain * 0.371, -domain * 0.219);
    let scale = select(1.091, 0.947, cascade == 3u);
    let secondary = sample_field_once(cascade, world_xz, alt_offset, cascade_rotation_alt(cascade), scale);
    let blend = select(0.28, 0.42, cascade == 3u);
    return mix_field(primary, secondary, blend);
}

fn projected_distance(r: f32) -> f32 {
    let e = exp(PROJECTED_GRID_SCALE);
    return ((exp(r * PROJECTED_GRID_SCALE) - 1.0) / max(e - 1.0, 0.0001)) * MESH_OUTER;
}

fn mesh_coord(vertex_id: u32) -> MeshCoord {
    let row = MESH_RES + 1u;
    let ix = vertex_id % row;
    let iz = vertex_id / row;
    let uv = vec2<f32>(f32(ix), f32(iz)) / f32(MESH_RES);
    let q = uv * 2.0 - vec2<f32>(1.0, 1.0);
    let r = max(abs(q.x), abs(q.y));

    var local = vec2<f32>(0.0, 0.0);
    if r > 0.000001 {
        local = q / r * projected_distance(r);
    }

    var c: MeshCoord;
    c.local_xz = local;
    c.uv = uv;
    // Continuous distance LOD. This replaces the explicit close/mid/far band id,
    // so all wave products fade by camera distance rather than by which mesh band
    // emitted a vertex.
    c.level = 4.0 * smoothstep(0.0, MESH_OUTER, max(abs(local.x), abs(local.y)));
    return c;
}

fn outer_edge_fade(coord: MeshCoord) -> f32 {
    let d = min(min(coord.uv.x, coord.uv.y), min(1.0 - coord.uv.x, 1.0 - coord.uv.y));
    return smoothstep(0.0, 0.045, d);
}

fn clipmap_distance(world_xz: vec2<f32>) -> f32 {
    let rel = world_xz - vec2<f32>(frame.camera_pos.x, frame.camera_pos.z);
    return max(abs(rel.x), abs(rel.y));
}

fn geom_lod_weight(cascade: u32, world_xz: vec2<f32>) -> f32 {
    // Distance-continuous weights prevent visible close/mid/far bands. The mesh is
    // still ringed, but wave energy no longer changes just because a vertex came
    // from a different LOD band.
    let d = clipmap_distance(world_xz);
    if cascade == 0u { return mix(0.88, 0.76, smoothstep(1200.0, 5200.0, d)); }
    if cascade == 1u { return mix(0.92, 0.64, smoothstep(1800.0, 5600.0, d)); }
    if cascade == 2u { return mix(0.58, 0.16, smoothstep(900.0, 4300.0, d)); }
    return 0.0;
}

fn slope_lod_weight(cascade: u32, world_xz: vec2<f32>) -> f32 {
    let d = clipmap_distance(world_xz);
    if cascade == 0u { return mix(0.76, 0.68, smoothstep(1800.0, 5600.0, d)); }
    if cascade == 1u { return mix(1.24, 0.82, smoothstep(1600.0, 5600.0, d)); }
    if cascade == 2u { return mix(1.78, 0.54, smoothstep(900.0, 4700.0, d)); }
    return mix(1.42, 0.18, smoothstep(620.0, 3400.0, d));
}

fn variation_map(p: vec2<f32>) -> vec2<f32> {
    // Stable world-space variation / space-variation map substitute. The earlier
    // sine-only field could line up with wave trains; this is broad, rotated,
    // non-commensurate value noise plus a very weak analytic drift.
    let n0 = smooth_noise2(p * 0.00095 + vec2<f32>(7.3, -3.1));
    let n1 = smooth_noise2(rotate2(p * 0.00165, vec2<f32>(0.788011, 0.615661)) + vec2<f32>(-19.0, 23.0));
    let n2 = smooth_noise2(rotate2(p * 0.00335, vec2<f32>(0.292372, 0.956305)) + vec2<f32>(43.0, -11.0));
    let n3 = smooth_noise2(rotate2(p * 0.00610, vec2<f32>(0.939693, -0.342020)) + vec2<f32>(-31.0, -47.0));
    let drift = sin(dot(p, vec2<f32>(0.00083, -0.00057)) + 1.7) * 0.05 +
        sin(dot(p, vec2<f32>(-0.00049, 0.00091)) + 4.1) * 0.04;
    let space = clamp(0.50 + (n0 - 0.5) * 0.44 + (n1 - 0.5) * 0.26 + (n2 - 0.5) * 0.12 + drift, 0.20, 0.84);
    let detail = clamp(0.52 + (n1 - 0.5) * 0.34 - (n2 - 0.5) * 0.20 + (n3 - 0.5) * 0.24 - drift * 0.36, 0.18, 0.90);
    return vec2<f32>(space, detail);
}

fn init_deform_sample(space: f32, detail: f32) -> DeformSample {
    var d: DeformSample;
    d.height = 0.0;
    d.slope = vec2<f32>(0.0);
    d.disp = vec2<f32>(0.0);
    d.crest = 0.0;
    d.foam = 0.0;
    d.space = space;
    d.detail = detail;
    return d;
}

fn add_deform_wave(d0: DeformSample, p: vec2<f32>, dir: vec2<f32>, wavelength: f32, amp: f32, speed: f32, phase0: f32, lod: f32) -> DeformSample {
    var d = d0;
    let k = 2.0 * PI / wavelength;
    let t = frame.time * max(frame.time_scale, 0.0);
    let cross = vec2<f32>(-dir.y, dir.x);
    let bend = sin(dot(p, cross) * k * 0.37 + phase0 * 1.91) * 0.70 + sin(dot(p, dir.yx) * k * 0.19 + 2.4) * 0.34;
    let phase = dot(p, dir) * k + t * speed + phase0 + bend;
    let sn = sin(phase);
    let cs = cos(phase);
    let a = amp * lod;
    d.height = d.height + sn * a;
    d.slope = d.slope + dir * (cs * a * k);
    d.disp = d.disp + dir * (sn * a * wavelength * 0.035);
    let crest = smoothstep(0.48, 0.96, sn) * smoothstep(0.08, 0.85, abs(cs));
    d.crest = max(d.crest, crest * lod);
    d.foam = d.foam + crest * a * 28.0;
    return d;
}

fn macro_deform_field(world_xz: vec2<f32>, level: f32) -> DeformSample {
    let wind = safe_normalize2(vec2<f32>(frame.wind_dir_x, frame.wind_dir_z));
    let cross = vec2<f32>(-wind.y, wind.x);
    let v0 = variation_map(world_xz * 0.53);
    let v1 = variation_map(world_xz * 1.17 + vec2<f32>(-41.0, 83.0));
    let near_lod = 1.0 - smoothstep(2.7, 4.2, level);
    let mid_lod = 1.0 - smoothstep(3.2, 4.7, level);
    let envelope = mix(0.90, 1.12, v0.x) * mix(0.94, 1.10, v1.y);
    var d = init_deform_sample(v0.x, v1.y);

    // Variation/deform is now small and frequent. It bends the water-data layers
    // like WoWS variation/deform inputs, instead of creating giant extra hills.
    d = add_deform_wave(d, world_xz, safe_normalize2(wind * 0.94 + cross * 0.34), 13.5, 0.00155 * envelope, 1.08, 0.1, mid_lod);
    d = add_deform_wave(d, world_xz, safe_normalize2(wind * 0.48 - cross * 0.88), 8.4, 0.00128 * envelope, -1.28, 2.3, mid_lod);
    d = add_deform_wave(d, world_xz, safe_normalize2(wind * 0.18 + cross * 0.98), 5.2, 0.00108 * mix(0.90, 1.22, v1.x), 1.62, 4.7, near_lod);
    d = add_deform_wave(d, world_xz, safe_normalize2(-wind * 0.36 + cross * 0.93), 3.4, 0.00078 * mix(0.90, 1.24, v1.y), -2.05, 1.4, near_lod);
    d.foam = saturate(d.foam * frame.foam_amount * 0.045);
    return d;
}

fn query_wave_data(world_xz: vec2<f32>, level: f32) -> WaveQuery {
    var q: WaveQuery;
    q.height = 0.0;
    q.slope = vec2<f32>(0.0);
    q.disp = vec2<f32>(0.0);
    q.height0 = 0.0;
    q.height1 = 0.0;
    q.height2 = 0.0;
    q.height3 = 0.0;
    q.slope0 = 0.0;
    q.slope1 = 0.0;
    q.slope2 = 0.0;
    q.slope3 = 0.0;
    q.energy0 = 0.0;
    q.energy1 = 0.0;
    q.energy2 = 0.0;
    q.energy3 = 0.0;
    q.jacobian = 1.0;
    let var_pair = variation_map(world_xz * 0.67);
    let height_amp = mix(0.94, 1.06, var_pair.x);
    let slope_amp = mix(0.88, 1.24, var_pair.y);

    for (var cascade = 0u; cascade < CASCADE_COUNT; cascade = cascade + 1u) {
        let params = cascade_params(cascade);
        let f = sample_cascade_field(cascade, world_xz);
        let geom = geom_lod_weight(cascade, world_xz);
        let detail = slope_lod_weight(cascade, world_xz);
        var height_gain = 1.0;
        var slope_gain = 1.0;
        var disp_gain = 1.0;
        if cascade == 0u {
            height_gain = 0.68;
            slope_gain = 0.95;
            disp_gain = 0.40;
        } else if cascade == 1u {
            height_gain = 1.20;
            slope_gain = 1.92;
            disp_gain = 1.18;
        } else if cascade == 2u {
            height_gain = 0.68;
            slope_gain = 2.85;
            disp_gain = 0.72;
        } else {
            height_gain = 0.12;
            slope_gain = 3.60;
            disp_gain = 0.08;
        }
        let h = f.height * params.y * geom * height_amp * height_gain;
        let slope = vec2<f32>(f.slope_x, f.slope_z) * params.z * detail * slope_amp * slope_gain;
        let disp = vec2<f32>(f.disp_x, f.disp_z) * params.w * geom * height_amp * disp_gain;
        let slope_energy = length(slope);
        let energy = abs(h) * 0.44 + slope_energy * 0.20;
        q.height = q.height + h;
        q.slope = q.slope + slope;
        q.disp = q.disp + disp;
        if cascade == 0u {
            q.height0 = h;
            q.slope0 = slope_energy;
            q.energy0 = energy;
        } else if cascade == 1u {
            q.height1 = h;
            q.slope1 = slope_energy;
            q.energy1 = energy;
        } else if cascade == 2u {
            q.height2 = h;
            q.slope2 = slope_energy;
            q.energy2 = energy;
        } else {
            q.height3 = h;
            q.slope3 = slope_energy;
            q.energy3 = energy;
        }
    }

    let fold = length(q.disp) * 0.007 + length(q.slope) * 0.13;
    q.jacobian = 1.0 - saturate(fold);
    return q;
}

@compute @workgroup_size(64, 1, 1)
fn finalize_samples(@builtin(global_invocation_id) gid: vec3<u32>) {
    let idx = gid.x;
    if idx >= arrayLength(&ocean_samples) { return; }
    let coord = mesh_coord(idx);
    let edge = outer_edge_fade(coord);
    let world_xz = coord.local_xz + ocean_origin();
    let scale = max(frame.fft_height_scale, 0.0);
    let query = query_wave_data(world_xz, coord.level);
    let deform = macro_deform_field(world_xz, coord.level);
    let raw_height = query.height * 1.12 + deform.height * 0.12;
    let raw_slope = query.slope * 2.20 + deform.slope * 1.54;
    let raw_disp = query.disp * 1.22 + deform.disp * 0.28;
    let height = raw_height * scale * edge;
    let slope = raw_slope * scale * edge;
    let disp = raw_disp * scale * frame.chop_scale * edge;
    let slope_len = length(slope) * frame.height_scale;
    let vmap = variation_map(world_xz * 0.41 + vec2<f32>(61.0, -29.0));

    let crest = max(deform.crest * 0.28, smoothstep(0.38, 1.24, slope_len) * smoothstep(0.05, 0.62, height * frame.height_scale));
    let jacobian = query.jacobian - saturate(length(deform.slope) * 1.45 + deform.crest * 0.06);
    let fold = smoothstep(frame.foam_threshold + 0.18, frame.foam_threshold - 0.06, jacobian);
    let foam_seed = saturate((crest * 0.14 + fold * 0.060 + query.energy2 * 0.045 + query.energy3 * 0.020 + deform.foam * 0.028) * frame.foam_amount * edge);
    let flow_dir = safe_normalize2(slope + safe_normalize2(vec2<f32>(frame.wind_dir_x, frame.wind_dir_z)) * 0.24);

    var out: OceanSample;
    out.height = height;
    out.slope_x = slope.x;
    out.slope_z = slope.y;
    out.disp_x = disp.x;
    out.disp_z = disp.y;
    out.jacobian = jacobian;
    out.foam = foam_seed;
    out.edge_fade = edge;
    out.cascade_mix = vec3<f32>(query.energy0, query.energy1, query.energy2) / max(query.energy0 + query.energy1 + query.energy2, 0.0001);
    out._pad = 0.0;
    ocean_samples[idx] = out;

    let support = clamp(raw_height * scale * 0.18, -1.0, 1.0);
    let main = clamp((query.energy1 + abs(deform.height) * 0.22) * scale * 0.62, 0.0, 1.0);
    let chop = clamp((query.energy2 + query.energy3 * 1.15 + length(deform.slope) * 1.20) * scale * 2.10, 0.0, 1.0);
    let capillary = clamp(query.energy3 * scale * 3.6 + slope_len * 0.18, 0.0, 1.0);
    let reflection_mask = mix(0.84, 1.22, vmap.x) * mix(0.92, 1.14, main) * mix(0.94, 1.12, deform.space);
    let rough_bias = mix(0.090, -0.045, chop) + mix(-0.020, 0.028, vmap.y);
    let scatter_bias = mix(0.86, 1.16, vmap.x * 0.46 + vmap.y * 0.40 + deform.detail * 0.14);
    let absorb_bias = mix(0.92, 1.12, saturate(abs(raw_height) * scale * 0.055 + query.energy1 * scale * 0.22 + vmap.x * 0.22));
    let broad_refl = clamp(0.68 + query.energy0 * scale * 0.018 - chop * 0.055 + deform.space * 0.055, 0.42, 0.96);
    let mid_refl = clamp(0.36 + main * 0.22 + chop * 0.16 + vmap.x * 0.12, 0.22, 0.86);
    let sharp_refl = clamp(0.05 + chop * 0.18 + capillary * 0.24 + vmap.y * 0.035, 0.02, 0.38);
    let subpixel_weight = clamp(0.58 + capillary * 0.72, 0.42, 1.20);

    let support_lod = geom_lod_weight(0u, world_xz);
    let main_lod = geom_lod_weight(1u, world_xz);
    let chop_lod = geom_lod_weight(2u, world_xz);
    let cap_lod = slope_lod_weight(3u, world_xz);

    var wave_layer: WaveLayers;
    wave_layer.support = vec4<f32>(clamp((query.height0 + deform.height * 0.18) * scale * 0.26, -1.0, 1.0), saturate((query.energy0 + abs(deform.height) * 0.10) * scale * 0.26), support_lod, deform.space);
    wave_layer.wind = vec4<f32>(clamp((query.height1 + deform.height * 0.16) * scale * 0.44, -1.0, 1.0), saturate((query.energy1 + abs(deform.height) * 0.20) * scale * 0.76), main_lod, deform.detail);
    wave_layer.chop = vec4<f32>(clamp((query.height2 + deform.height * 0.10) * scale * 0.72, -1.0, 1.0), chop, chop_lod, slope_lod_weight(2u, world_xz));
    wave_layer.capillary = vec4<f32>(clamp(query.height3 * scale * 0.72, -1.0, 1.0), capillary, cap_lod, subpixel_weight);
    wave_layers[idx] = wave_layer;

    var foam_layer: FoamLayers;
    foam_layer.crest = vec4<f32>(crest * edge, slope_len, smoothstep(0.10, 0.68, height * frame.height_scale), query.slope1 + query.slope2 + deform.crest * 0.25);
    foam_layer.fold = vec4<f32>(fold * edge, 1.0 - jacobian, length(disp), (query.energy2 + deform.foam * 0.32) * scale);
    foam_layer.foam = vec4<f32>(foam_seed, flow_dir.x, flow_dir.y, deform.detail);
    foam_layers[idx] = foam_layer;

    var optical_layer: OpticalLayers;
    optical_layer.absorption = vec4<f32>(absorb_bias, clamp(-height * frame.height_scale * 0.10 + 0.56, 0.0, 1.0), support, main);
    optical_layer.scatter = vec4<f32>(scatter_bias, saturate(slope_len * 0.18), chop, capillary);
    optical_layer.reflection = vec4<f32>(broad_refl, mid_refl, sharp_refl, reflection_mask);
    optical_layer.lod = vec4<f32>(coord.level, subpixel_weight, rough_bias, edge);
    optical_layers[idx] = optical_layer;
}
