struct WakeShip {
    // xy = world xz, z = forward speed, w = wake strength.
    pos_speed: vec4<f32>,
    // xy = forward xz, z = length, w = beam.
    dir_size: vec4<f32>,
    // x = draft, y = propeller count, z = phase offset, w reserved.
    params: vec4<f32>,
};

struct WakeUniforms {
    // xy = current field origin, z = span, w = dt.
    field: vec4<f32>,
    // xy = previous field origin, z = time, w = ship count.
    previous_time_count: vec4<f32>,
    ships: array<WakeShip, 4>,
};

@group(0) @binding(0)
var<uniform> wake: WakeUniforms;
@group(0) @binding(1)
var previous_field: texture_2d<f32>;
@group(0) @binding(2)
var output_field: texture_storage_2d<rgba32float, write>;

const TAU: f32 = 6.28318530718;

fn finite_or(v: f32, fallback: f32, limit: f32) -> f32 {
    let good = (v == v) && abs(v) <= limit;
    return select(fallback, clamp(v, -limit, limit), good);
}

fn safe_field(v: vec4<f32>) -> vec4<f32> {
    return vec4<f32>(
        finite_or(v.x, 0.0, 1.8),
        finite_or(v.y, 0.0, 1.8),
        finite_or(v.z, 0.0, 1.2),
        finite_or(v.w, 0.0, 1.0)
    );
}

fn load_previous(coord: vec2<i32>, dims: vec2<i32>) -> vec4<f32> {
    if coord.x < 0 || coord.y < 0 || coord.x >= dims.x || coord.y >= dims.y {
        return vec4<f32>(0.0);
    }
    return safe_field(textureLoad(previous_field, coord, 0));
}

fn sample_previous(world: vec2<f32>, dims: vec2<i32>) -> vec4<f32> {
    let uv = (world - wake.previous_time_count.xy) / max(wake.field.z, 1.0);
    if uv.x <= 0.0 || uv.y <= 0.0 || uv.x >= 1.0 || uv.y >= 1.0 {
        return vec4<f32>(0.0);
    }
    let coord = uv * vec2<f32>(dims) - vec2<f32>(0.5);
    let i0 = vec2<i32>(floor(coord));
    let f = fract(coord);
    let a = load_previous(i0, dims);
    let b = load_previous(i0 + vec2<i32>(1, 0), dims);
    let c = load_previous(i0 + vec2<i32>(0, 1), dims);
    let d = load_previous(i0 + vec2<i32>(1, 1), dims);
    return safe_field(mix(mix(a, b, f.x), mix(c, d, f.x), f.y));
}

fn gaussian(x: f32) -> f32 {
    return exp(-x * x);
}

fn add_ship_wake(world: vec2<f32>, ship: WakeShip, time: f32) -> vec4<f32> {
    let forward = normalize(ship.dir_size.xy + vec2<f32>(0.0001));
    let right = vec2<f32>(forward.y, -forward.x);
    let rel = world - ship.pos_speed.xy;
    let along = dot(rel, forward);
    let lateral = dot(rel, right);
    let ship_length = max(ship.dir_size.z, 20.0);
    let beam = max(ship.dir_size.w, ship_length * 0.10);
    let speed = max(ship.pos_speed.z, 0.0);
    let strength = ship.pos_speed.w * smoothstep(0.5, 8.0, speed);
    let stern = -ship_length * 0.42;
    let behind = max(-(along - stern), 0.0);
    let wake_gate = select(0.0, exp(-behind / max(ship_length * 4.8, 1.0)), along < stern);

    // Bow pressure and diverging hull shoulders.
    let bow_rel = vec2<f32>((along - ship_length * 0.47) / max(ship_length * 0.11, 1.0), lateral / max(beam * 0.42, 1.0));
    let bow = gaussian(length(bow_rel)) * strength;
    let side_along = abs(along) / max(ship_length * 0.48, 1.0);
    let side_band = gaussian((abs(lateral) - beam * 0.48) / max(beam * 0.15, 0.5)) *
                    (1.0 - smoothstep(0.72, 1.08, side_along)) * strength;

    // Persistent propeller wash widens and loses coherence downstream.
    let trail_width = beam * (0.08 + behind / max(ship_length, 1.0) * 0.050);
    let prop = gaussian(lateral / max(trail_width, 0.75)) * wake_gate * strength;
    let prop_phase = behind * 0.19 - time * (2.1 + speed * 0.035) + ship.params.z;
    let prop_break = 0.36 + 0.64 * pow(0.5 + 0.5 * sin(prop_phase), 1.7);
    let prop_foam = prop * prop_break;
    let shaft_offset = beam * 0.13;
    let shaft_width = 0.8 + behind * 0.006;
    let shaft_tracks = (
        gaussian((lateral - shaft_offset) / shaft_width) +
        gaussian((lateral + shaft_offset) / shaft_width)
    ) * wake_gate * strength;
    let shaft_pulse = 0.28 + 0.72 * pow(0.5 + 0.5 * sin(prop_phase * 1.37 + lateral * 0.12), 2.0);

    // Kelvin arms at the deep-water half-angle (~19.47 degrees).
    let arm_center = behind * 0.354;
    let arm_width = beam * 0.20 + behind * 0.020;
    let arm_dist = min(abs(lateral - arm_center), abs(lateral + arm_center));
    let arm = gaussian(arm_dist / max(arm_width, 0.8)) * wake_gate * strength;
    let wavelength = max(10.0, speed * speed / 9.81 * 0.72);
    let phase = TAU * behind / wavelength - time * (1.0 + speed * 0.055) + ship.params.z;
    let kelvin_height = sin(phase) * arm * 0.20;
    let kelvin_slope = cos(phase) * arm * (TAU / wavelength) * 0.20;
    let arm_sign = select(-1.0, 1.0, lateral >= 0.0);
    let arm_dir = normalize(-forward + right * arm_sign * 0.354);

    var result = vec4<f32>(0.0);
    let slope = -forward * bow * 0.045 +
                right * sign(lateral) * side_band * 0.025 +
                arm_dir * kelvin_slope;
    result = vec4<f32>(
        slope,
        bow * 0.08 + kelvin_height,
        bow * 0.07 + side_band * 0.11 + prop_foam * 0.38 +
        shaft_tracks * shaft_pulse * 0.31 + arm * 0.065
    );
    return result;
}

@compute @workgroup_size(8, 8, 1)
fn cs_main(@builtin(global_invocation_id) gid: vec3<u32>) {
    let dims_u = textureDimensions(output_field);
    if gid.x >= dims_u.x || gid.y >= dims_u.y {
        return;
    }
    let dims = vec2<i32>(dims_u);
    let uv = (vec2<f32>(gid.xy) + vec2<f32>(0.5)) / vec2<f32>(dims_u);
    let world = wake.field.xy + uv * wake.field.z;
    let dt = clamp(wake.field.w, 0.0, 0.10);
    let time = wake.previous_time_count.z;

    var value = sample_previous(world, dims);
    value = vec4<f32>(
        value.xy * exp(-dt * 1.75),
        value.z * exp(-dt * 1.45),
        value.w * exp(-dt * 0.48)
    );

    let ship_count = min(i32(wake.previous_time_count.w + 0.5), 4);
    for (var i = 0; i < ship_count; i = i + 1) {
        value += add_ship_wake(world, wake.ships[i], time) * dt * 1.35;
    }

    // Non-wrapping circular boundary fade.
    let edge = length(uv - vec2<f32>(0.5)) * 2.0;
    value *= 1.0 - smoothstep(0.82, 0.99, edge);
    value = vec4<f32>(
        clamp(value.xy, vec2<f32>(-1.2), vec2<f32>(1.2)),
        clamp(value.z, -0.8, 0.8),
        clamp(value.w, 0.0, 1.0)
    );
    textureStore(output_field, vec2<i32>(gid.xy), safe_field(value));
}
