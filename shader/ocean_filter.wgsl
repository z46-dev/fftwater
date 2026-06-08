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

// Raw direct inverse field from ocean_spectrum.wgsl.
@group(0) @binding(1)
var spectrum_raw: texture_2d<f32>;

// Filtered/stabilized field consumed by water.wgsl.
@group(0) @binding(2)
var spectrum_filtered: texture_storage_2d<rgba32float, write>;

fn finite_or(v: f32, fallback: f32, limit: f32) -> f32 {
    let good = (v == v) && abs(v) <= limit;
    return select(fallback, clamp(v, -limit, limit), good);
}

fn sanitize_field(v: vec4<f32>) -> vec4<f32> {
    return vec4<f32>(
        finite_or(v.x, 0.0, 16.0),
        finite_or(v.y, 0.0, 5.0),
        finite_or(v.z, 0.0, 16.0),
        finite_or(v.w, 0.0, 1.0)
    );
}

fn wrap_index(v: i32, n: i32) -> i32 {
    return ((v % n) + n) % n;
}

fn load_raw(coord: vec2<i32>, n: i32) -> vec4<f32> {
    let c = vec2<i32>(wrap_index(coord.x, n), wrap_index(coord.y, n));
    return sanitize_field(textureLoad(spectrum_raw, c, 0));
}

@compute @workgroup_size(8, 8, 1)
fn cs_main(@builtin(global_invocation_id) gid: vec3<u32>) {
    let n_u = max(u32(frame.spectrum_params.w), 1u);
    if gid.x >= n_u || gid.y >= n_u {
        return;
    }

    let n = i32(n_u);
    let p = vec2<i32>(i32(gid.x), i32(gid.y));

    let c  = load_raw(p, n);
    let l  = load_raw(p + vec2<i32>(-1,  0), n);
    let r  = load_raw(p + vec2<i32>( 1,  0), n);
    let d  = load_raw(p + vec2<i32>( 0, -1), n);
    let u  = load_raw(p + vec2<i32>( 0,  1), n);
    let dl = load_raw(p + vec2<i32>(-1, -1), n);
    let dr = load_raw(p + vec2<i32>( 1, -1), n);
    let ul = load_raw(p + vec2<i32>(-1,  1), n);
    let ur = load_raw(p + vec2<i32>( 1,  1), n);

    // Small Gaussian-like spatial stabilization. This is the first ping-pong
    // field pass: future FFT stages can write raw displacement/foam, then this
    // pass remains as the finite-value and foam-stability boundary before
    // shading. It also suppresses isolated white texel/square foam spikes.
    var filtered = (c * 11.0 + (l + r + d + u) * 0.95 + (dl + dr + ul + ur) * 0.20) / 15.6;
    filtered = sanitize_field(filtered);

    let axial_foam = (l.w + r.w + d.w + u.w) * 0.25;
    let diagonal_foam = (dl.w + dr.w + ul.w + ur.w) * 0.25;
    let local_support = axial_foam * 0.72 + diagonal_foam * 0.28;

    // If one texel says "full foam" but its neighbors do not, treat it as a
    // data-path spike rather than a breaking wave. Real crest foam should have
    // spatial support across nearby cells.
    var foam = min(filtered.w, local_support * 1.25 + 0.006);
    foam = smoothstep(0.055, 0.760, foam);
    filtered.w = clamp(foam, 0.0, 0.42);

    textureStore(spectrum_filtered, p, filtered);
}
