@group(0) @binding(0)
var variation_out: texture_storage_2d<rgba32float, write>;

const TAU: f32 = 6.28318530718;

fn hash21(p: vec2<f32>) -> f32 {
    return fract(sin(dot(p, vec2<f32>(127.1, 311.7))) * 43758.5453123);
}

fn smooth_noise(p: vec2<f32>) -> f32 {
    let i = floor(p);
    let f = fract(p);
    let u = f * f * (vec2<f32>(3.0, 3.0) - 2.0 * f);
    let a = hash21(i + vec2<f32>(0.0, 0.0));
    let b = hash21(i + vec2<f32>(1.0, 0.0));
    let c = hash21(i + vec2<f32>(0.0, 1.0));
    let d = hash21(i + vec2<f32>(1.0, 1.0));
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

fn fbm(p: vec2<f32>) -> f32 {
    var q = p;
    var amp = 0.54;
    var sum = 0.0;
    var norm = 0.0;
    for (var i = 0; i < 5; i = i + 1) {
        sum += smooth_noise(q) * amp;
        norm += amp;
        q = mat2x2<f32>(1.74, 1.09, -1.09, 1.74) * q + vec2<f32>(21.7, -13.4);
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
    let p = uv * 256.0;

    // R: broad space-variation/wave-weight mask.
    let large = fbm(p * 0.030 + vec2<f32>(17.0, 31.0)) * 0.72
              + periodic_wave_noise(uv, vec2<f32>(4.0, 3.0), 0.17) * 0.28;

    // G: mid/short wave roughness regions, stretched along the dominant wind.
    let wind_uv = vec2<f32>(uv.x * 0.78 + uv.y * 0.18, -uv.x * 0.24 + uv.y * 1.34);
    let rough = fbm(wind_uv * 18.0 + vec2<f32>(-9.0, 44.0)) * 0.62
              + periodic_wave_noise(wind_uv, vec2<f32>(9.0, 13.0), 0.43) * 0.38;

    // B: low-frequency foam breakup. Broad soft patches only.
    let foam_low = smoothstep(0.42, 0.88, fbm(p * 0.055 + vec2<f32>(73.0, -22.0)));

    // A: high-frequency foam lace/detail. Keep it sparse so it gates foam rather
    // than painting bright noise everywhere.
    let lace_base = fbm(p * 0.310 + vec2<f32>(-31.0, 5.0));
    let lace_lines = periodic_wave_noise(wind_uv, vec2<f32>(34.0, 21.0), 0.61);
    let foam_high = smoothstep(0.58, 0.93, lace_base * 0.62 + lace_lines * 0.38);

    textureStore(variation_out, vec2<i32>(id.xy), vec4<f32>(
        clamp(large, 0.0, 1.0),
        clamp(rough, 0.0, 1.0),
        clamp(foam_low, 0.0, 1.0),
        clamp(foam_high, 0.0, 1.0)
    ));
}
