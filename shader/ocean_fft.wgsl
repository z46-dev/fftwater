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

// Input packed spectral/tile data.  This shader performs the same staged IFFT
// over both complex lanes at once: RG and BA.  The renderer runs the chain once
// for height+Dx and once for Dz+curvature.
@group(0) @binding(1)
var fft_in: texture_2d<f32>;

// Output ping/pong mode texture.  Cascades are stacked vertically.
@group(0) @binding(2)
var fft_out: texture_storage_2d<rgba32float, write>;

const TAU: f32 = 6.28318530718;
const MAX_DIM: u32 = 64u;

fn finite_or(v: f32, fallback: f32, limit: f32) -> f32 {
    let good = (v == v) && abs(v) <= limit;
    return select(fallback, clamp(v, -limit, limit), good);
}

fn sanitize(v: vec4<f32>) -> vec4<f32> {
    return vec4<f32>(
        finite_or(v.x, 0.0, 128.0),
        finite_or(v.y, 0.0, 128.0),
        finite_or(v.z, 0.0, 128.0),
        finite_or(v.w, 0.0, 128.0)
    );
}

fn cmul(a: vec2<f32>, b: vec2<f32>) -> vec2<f32> {
    return vec2<f32>(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x);
}

fn bit_reverse6(v: u32) -> u32 {
    var x = v & 63u;
    x = ((x & 0x15u) << 1u) | ((x & 0x2Au) >> 1u);
    x = ((x & 0x03u) << 4u) | ((x & 0x0Cu) << 0u) | ((x & 0x30u) >> 4u);
    return x;
}

fn load_at(x: u32, y: u32) -> vec4<f32> {
    let dims = textureDimensions(fft_in, 0);
    let cx = min(x, dims.x - 1u);
    let cy = min(y, dims.y - 1u);
    return sanitize(textureLoad(fft_in, vec2<i32>(i32(cx), i32(cy)), 0));
}

fn store_at(x: u32, y: u32, v: vec4<f32>) {
    textureStore(fft_out, vec2<i32>(i32(x), i32(y)), sanitize(v));
}

fn butterfly(a: vec4<f32>, b: vec4<f32>, tw: vec2<f32>, subtract: bool, normalize: f32) -> vec4<f32> {
    let wb0 = cmul(b.xy, tw);
    let wb1 = cmul(b.zw, tw);

    var out0: vec2<f32>;
    var out1: vec2<f32>;
    if subtract {
        out0 = a.xy - wb0;
        out1 = a.zw - wb1;
    } else {
        out0 = a.xy + wb0;
        out1 = a.zw + wb1;
    }

    return vec4<f32>(out0 * normalize, out1 * normalize);
}

fn bit_reverse_horizontal(gid: vec3<u32>) {
    let dims = textureDimensions(fft_out);
    if gid.x >= dims.x || gid.y >= dims.y {
        return;
    }

    let dim = min(dims.x, MAX_DIM);
    let src_x = bit_reverse6(gid.x) & (dim - 1u);
    store_at(gid.x, gid.y, load_at(src_x, gid.y));
}

fn bit_reverse_vertical(gid: vec3<u32>) {
    let dims = textureDimensions(fft_out);
    if gid.x >= dims.x || gid.y >= dims.y {
        return;
    }

    let dim = min(dims.x, MAX_DIM);
    let cascade = gid.y / dim;
    let local_y = gid.y - cascade * dim;
    let src_y = cascade * dim + (bit_reverse6(local_y) & (dim - 1u));
    store_at(gid.x, gid.y, load_at(gid.x, src_y));
}

fn fft_stage_horizontal(gid: vec3<u32>, stage: u32) {
    let dims = textureDimensions(fft_out);
    if gid.x >= dims.x || gid.y >= dims.y {
        return;
    }

    let dim = min(dims.x, MAX_DIM);
    let m = 1u << (stage + 1u);
    let half = m >> 1u;
    let local = gid.x & (m - 1u);
    let base = gid.x - local;
    let j = local & (half - 1u);

    let a = load_at(base + j, gid.y);
    let b = load_at(base + j + half, gid.y);

    let angle = TAU * f32(j) / f32(m);
    let tw = vec2<f32>(cos(angle), sin(angle));
    store_at(gid.x, gid.y, butterfly(a, b, tw, local >= half, 1.0));
}

fn fft_stage_vertical(gid: vec3<u32>, stage: u32, final_stage: bool) {
    let dims = textureDimensions(fft_out);
    if gid.x >= dims.x || gid.y >= dims.y {
        return;
    }

    let dim = min(dims.x, MAX_DIM);
    let cascade = gid.y / dim;
    let local_y = gid.y - cascade * dim;
    let m = 1u << (stage + 1u);
    let half = m >> 1u;
    let local = local_y & (m - 1u);
    let base_local = local_y - local;
    let j = local & (half - 1u);
    let base = cascade * dim + base_local;

    let a = load_at(gid.x, base + j);
    let b = load_at(gid.x, base + j + half);

    let angle = TAU * f32(j) / f32(m);
    let tw = vec2<f32>(cos(angle), sin(angle));
    // Match the direct inverse sum convention used by the previous spectral
    // compute path: do not average the IFFT by N or N^2 here. The H0 amplitudes
    // are authored/tuned for a summed spatial field, and normalizing by N made
    // the geometric ocean displacement visually disappear. The final_stage
    // parameter remains so the entry-point API can grow diagnostics later.
    store_at(gid.x, gid.y, butterfly(a, b, tw, local >= half, 1.0));
}

@compute @workgroup_size(8, 8, 1)
fn cs_bitrev_h(@builtin(global_invocation_id) gid: vec3<u32>) {
    bit_reverse_horizontal(gid);
}

@compute @workgroup_size(8, 8, 1)
fn cs_stage_h0(@builtin(global_invocation_id) gid: vec3<u32>) { fft_stage_horizontal(gid, 0u); }
@compute @workgroup_size(8, 8, 1)
fn cs_stage_h1(@builtin(global_invocation_id) gid: vec3<u32>) { fft_stage_horizontal(gid, 1u); }
@compute @workgroup_size(8, 8, 1)
fn cs_stage_h2(@builtin(global_invocation_id) gid: vec3<u32>) { fft_stage_horizontal(gid, 2u); }
@compute @workgroup_size(8, 8, 1)
fn cs_stage_h3(@builtin(global_invocation_id) gid: vec3<u32>) { fft_stage_horizontal(gid, 3u); }
@compute @workgroup_size(8, 8, 1)
fn cs_stage_h4(@builtin(global_invocation_id) gid: vec3<u32>) { fft_stage_horizontal(gid, 4u); }
@compute @workgroup_size(8, 8, 1)
fn cs_stage_h5(@builtin(global_invocation_id) gid: vec3<u32>) { fft_stage_horizontal(gid, 5u); }

@compute @workgroup_size(8, 8, 1)
fn cs_bitrev_v(@builtin(global_invocation_id) gid: vec3<u32>) {
    bit_reverse_vertical(gid);
}

@compute @workgroup_size(8, 8, 1)
fn cs_stage_v0(@builtin(global_invocation_id) gid: vec3<u32>) { fft_stage_vertical(gid, 0u, false); }
@compute @workgroup_size(8, 8, 1)
fn cs_stage_v1(@builtin(global_invocation_id) gid: vec3<u32>) { fft_stage_vertical(gid, 1u, false); }
@compute @workgroup_size(8, 8, 1)
fn cs_stage_v2(@builtin(global_invocation_id) gid: vec3<u32>) { fft_stage_vertical(gid, 2u, false); }
@compute @workgroup_size(8, 8, 1)
fn cs_stage_v3(@builtin(global_invocation_id) gid: vec3<u32>) { fft_stage_vertical(gid, 3u, false); }
@compute @workgroup_size(8, 8, 1)
fn cs_stage_v4(@builtin(global_invocation_id) gid: vec3<u32>) { fft_stage_vertical(gid, 4u, false); }
@compute @workgroup_size(8, 8, 1)
fn cs_stage_v5(@builtin(global_invocation_id) gid: vec3<u32>) { fft_stage_vertical(gid, 5u, true); }
