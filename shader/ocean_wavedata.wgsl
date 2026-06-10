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

// Stabilized field from ocean_filter.wgsl.
// RGBA = displacement x, height, displacement z, foam seed.
@group(0) @binding(1)
var spectrum_filtered: texture_2d<f32>;

// WoWS-style derived wave data consumed by the material pass.
// RGBA = gradient x, gradient z, roughness/moment, foam coverage.
@group(0) @binding(2)
var wave_data_out: texture_storage_2d<rgba32float, write>;

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

fn load_field(coord: vec2<i32>, n: i32) -> vec4<f32> {
    let c = vec2<i32>(wrap_index(coord.x, n), wrap_index(coord.y, n));
    return sanitize_field(textureLoad(spectrum_filtered, c, 0));
}

fn saturate(v: f32) -> f32 {
    return clamp(v, 0.0, 1.0);
}

@compute @workgroup_size(8, 8, 1)
fn cs_main(@builtin(global_invocation_id) gid: vec3<u32>) {
    let n_u = max(u32(frame.spectrum_params.w), 1u);
    if gid.x >= n_u || gid.y >= n_u {
        return;
    }

    let n = i32(n_u);
    let p = vec2<i32>(i32(gid.x), i32(gid.y));
    let dx = max(frame.spectrum_params.z / f32(n_u), 0.25);

    let c  = load_field(p, n);
    let l  = load_field(p + vec2<i32>(-1,  0), n);
    let r  = load_field(p + vec2<i32>( 1,  0), n);
    let d  = load_field(p + vec2<i32>( 0, -1), n);
    let u  = load_field(p + vec2<i32>( 0,  1), n);
    let dl = load_field(p + vec2<i32>(-1, -1), n);
    let dr = load_field(p + vec2<i32>( 1, -1), n);
    let ul = load_field(p + vec2<i32>(-1,  1), n);
    let ur = load_field(p + vec2<i32>( 1,  1), n);

    // Height gradient is the main low/mid-frequency material normal term.
    // Keeping it in a texture mirrors the WoWS pattern where displacement,
    // gradients, moments, and foam are separate water inputs rather than every
    // shader stage rediscovering them differently.
    let grad = vec2<f32>((r.y - l.y) / (2.0 * dx), (u.y - d.y) / (2.0 * dx));
    let lap = (l.y + r.y + d.y + u.y - 4.0 * c.y) / max(dx * dx, 0.0001);

    // Horizontal displacement Jacobian. When it compresses, the wave is becoming
    // choppy/breaking. This is the same class of signal used by FFT ocean
    // renderers for whitecap/foam generation.
    let ddx_dx = (r.x - l.x) / (2.0 * dx);
    let ddz_dz = (u.z - d.z) / (2.0 * dx);
    let ddx_dz = (u.x - d.x) / (2.0 * dx);
    let ddz_dx = (r.z - l.z) / (2.0 * dx);
    let jacobian = (1.0 + ddx_dx) * (1.0 + ddz_dz) - ddx_dz * ddz_dx;
    let compression = saturate((1.0 - jacobian) * 2.45);

    let axial_foam = (l.w + r.w + d.w + u.w) * 0.25;
    let diagonal_foam = (dl.w + dr.w + ul.w + ur.w) * 0.25;
    let neighbor_support = axial_foam * 0.72 + diagonal_foam * 0.28;

    let slope_mag = length(grad);
    let bend = length(vec2<f32>(r.y - 2.0 * c.y + l.y, u.y - 2.0 * c.y + d.y)) / max(dx * dx, 0.0001);
    let curvature_break = smoothstep(0.00018, 0.0022, -lap);
    let slope_break = smoothstep(0.0028, 0.024, slope_mag);
    let compression_break = smoothstep(0.006, 0.18, compression);
    let crest_support = smoothstep(0.00022, 0.0045, abs(lap) + bend * 0.65) * slope_break;

    var foam = c.w * 0.50 + neighbor_support * 0.26;
    foam += curvature_break * slope_break * 0.24;
    foam += compression_break * 0.22;
    foam = min(foam, neighbor_support * 1.78 + c.w * 0.66 + crest_support * 0.18 + 0.026);
    foam = saturate(foam);

    // Moment is not a true higher-order wave moment yet, but it is the right
    // contract: one material texture channel tells the shader how rough/broken
    // this patch of water is. Later this can be replaced by the exact WoWS
    // moments/foam inputs without changing the render bind layout again.
    var moment = slope_mag * 5.60 + abs(lap) * 118.0 + bend * 76.0 + compression * 1.35 + foam * 0.62;
    moment = saturate(moment);

    let out_grad = vec2<f32>(finite_or(grad.x, 0.0, 1.45), finite_or(grad.y, 0.0, 1.45));
    textureStore(wave_data_out, p, vec4<f32>(out_grad.x, out_grad.y, moment, foam));
}
