@group(0) @binding(0)
var variation_out: texture_storage_2d<rgba32float, write>;

const TAU: f32 = 6.28318530718;

fn hash21(p: vec2<f32>) -> f32 {
    return fract(sin(dot(p, vec2<f32>(127.1, 311.7))) * 43758.5453123);
}

fn wrap_cell(v: i32, period: i32) -> i32 {
    return ((v % period) + period) % period;
}

fn periodic_noise(uv: vec2<f32>, cells_in: vec2<i32>, phase: vec2<f32>) -> f32 {
    let cells = max(cells_in, vec2<i32>(1, 1));
    let p = (uv + phase) * vec2<f32>(cells);
    let i = floor(p);
    let f = fract(p);
    let u = f * f * (vec2<f32>(3.0, 3.0) - 2.0 * f);

    let i0 = vec2<i32>(i);
    let x0 = wrap_cell(i0.x, cells.x);
    let y0 = wrap_cell(i0.y, cells.y);
    let x1 = wrap_cell(i0.x + 1, cells.x);
    let y1 = wrap_cell(i0.y + 1, cells.y);

    let a = hash21(vec2<f32>(f32(x0), f32(y0)));
    let b = hash21(vec2<f32>(f32(x1), f32(y0)));
    let c = hash21(vec2<f32>(f32(x0), f32(y1)));
    let d = hash21(vec2<f32>(f32(x1), f32(y1)));
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

fn periodic_fbm(uv: vec2<f32>, base_cells: vec2<i32>, phase: vec2<f32>) -> f32 {
    var cells = max(base_cells, vec2<i32>(1, 1));
    var amp = 0.54;
    var sum = 0.0;
    var norm = 0.0;
    for (var i = 0; i < 5; i = i + 1) {
        sum += periodic_noise(uv, cells, phase + vec2<f32>(f32(i) * 0.173, -f32(i) * 0.119)) * amp;
        norm += amp;
        cells *= 2;
        amp *= 0.50;
    }
    return sum / max(norm, 0.0001);
}

fn periodic_wave_noise(uv: vec2<f32>, freq: vec2<f32>, phase: f32) -> f32 {
    let a = sin(TAU * (uv.x * freq.x + phase));
    let b = sin(TAU * (uv.y * freq.y - phase * 0.73));
    let c = sin(TAU * ((uv.x + uv.y) * (freq.x * 0.37 + freq.y * 0.21) + phase * 1.31));
    return 0.5 + 0.5 * (a * 0.42 + b * 0.34 + c * 0.24);
}

@compute @workgroup_size(8, 8, 1)
fn cs_main(@builtin(global_invocation_id) id: vec3<u32>) {
    let dims = textureDimensions(variation_out);
    if id.x >= dims.x || id.y >= dims.y {
        return;
    }

    let uv = (vec2<f32>(id.xy) + vec2<f32>(0.5, 0.5)) / vec2<f32>(dims);
    // Integer transforms preserve periodicity across both texture boundaries.
    // The previous arbitrary FBM transform did not, so wrapping the generated
    // texture created visible horizontal/vertical cross seams.
    let broad_uv = mat2x2<f32>(1.0, 1.0, -1.0, 2.0) * uv;
    let wind_uv = mat2x2<f32>(2.0, 1.0, -1.0, 1.0) * uv;
    let lace_uv = mat2x2<f32>(3.0, 1.0, -2.0, 1.0) * uv;

    // R: broad space-variation/wave-weight mask.
    let large = periodic_fbm(broad_uv, vec2<i32>(4, 3), vec2<f32>(0.17, 0.31)) * 0.72
              + periodic_wave_noise(uv, vec2<f32>(4.0, 3.0), 0.17) * 0.28;

    // G: mid/short wave roughness regions, stretched along the dominant wind.
    let rough = periodic_fbm(wind_uv, vec2<i32>(9, 13), vec2<f32>(-0.09, 0.44)) * 0.62
              + periodic_wave_noise(wind_uv, vec2<f32>(9.0, 13.0), 0.43) * 0.38;

    // B: low-frequency foam breakup. Broad soft patches only.
    let foam_low = smoothstep(0.42, 0.88, periodic_fbm(broad_uv, vec2<i32>(7, 5), vec2<f32>(0.73, -0.22)));

    // A: high-frequency foam lace/detail. Keep it sparse so it gates foam rather
    // than painting bright noise everywhere.
    let lace_base = periodic_fbm(lace_uv, vec2<i32>(21, 17), vec2<f32>(-0.31, 0.05));
    let lace_lines = periodic_wave_noise(lace_uv, vec2<f32>(34.0, 21.0), 0.61);
    let foam_high = smoothstep(0.58, 0.93, lace_base * 0.62 + lace_lines * 0.38);

    textureStore(variation_out, vec2<i32>(id.xy), vec4<f32>(
        clamp(large, 0.0, 1.0),
        clamp(rough, 0.0, 1.0),
        clamp(foam_low, 0.0, 1.0),
        clamp(foam_high, 0.0, 1.0)
    ));
}
