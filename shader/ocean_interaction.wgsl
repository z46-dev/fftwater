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
var output_field: texture_storage_2d<rgba16float, write>;

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

// Generate only the disturbance touching the ship this frame. The persistent
// ping-pong field is the wake trail; procedurally drawing an imagined trail
// behind the ship every frame makes stationary ships continuously create foam
// and repeatedly reinforces the same straight stripe.
fn ship_disturbance(world: vec2<f32>, ship: WakeShip) -> vec4<f32> {
    let forward = normalize(ship.dir_size.xy + vec2<f32>(0.0001));
    let right = vec2<f32>(forward.y, -forward.x);
    let rel = world - ship.pos_speed.xy;
    let along = dot(rel, forward);
    let lateral = dot(rel, right);
    let ship_length = max(ship.dir_size.z, 20.0);
    let beam = max(ship.dir_size.w, ship_length * 0.10);
    let speed = abs(ship.pos_speed.z);
    let moving = smoothstep(0.20, 2.0, speed);
    let strength = max(ship.pos_speed.w, 0.0) * moving;
    if strength <= 0.0001 {
        return vec4<f32>(0.0);
    }

    let half_length = ship_length * 0.5;
    let longitudinal = along / max(half_length, 1.0);
    let hull_gate = 1.0 - smoothstep(0.82, 1.04, abs(longitudinal));
    let taper = sqrt(max(1.0 - longitudinal * longitudinal, 0.0));
    let half_beam = max(beam * 0.5 * taper, beam * 0.10);

    // A narrow pressure ridge follows the actual waterline. Bow pressure is a
    // local stamp, not a generated train of waves extending into the past.
    let side_distance = (abs(lateral) - half_beam) / max(beam * 0.12, 0.8);
    let shoulders = gaussian(side_distance) * hull_gate * strength;
    let bow = gaussian((along - half_length * 0.90) / max(ship_length * 0.085, 1.5)) *
              gaussian(lateral / max(beam * 0.42, 1.0)) * strength;

    // Propeller wash is injected in a compact patch at and immediately behind
    // the stern. As the ship advances, old patches remain in previous_field and
    // naturally form the trail.
    let stern_center = -half_length * 0.98;
    let stern_along = (along - stern_center) / max(ship_length * 0.045, 1.5);
    let propeller_scale = clamp(ship.params.y / 4.0, 0.45, 1.25);
    let shaft_offset = beam * mix(0.10, 0.18, propeller_scale);
    // Keep each shaft at least half an interaction texel wide. Narrower stamps
    // flicker between texels and disappear at normal camera distances.
    let shaft_width = max(beam * 0.085, 3.4);
    let shaft_wash = (
        gaussian((lateral - shaft_offset) / shaft_width) +
        gaussian((lateral + shaft_offset) / shaft_width)
    ) * 0.5;
    let center_wash = gaussian(lateral / max(beam * 0.20, 3.8));
    let wake_phase = sin(dot(world, vec2<f32>(0.115, -0.073)) + ship.params.z) *
                     sin(dot(world, vec2<f32>(-0.047, 0.139)) - ship.params.z * 1.7);
    let spatial_breakup = 0.46 + 0.54 * smoothstep(
        -0.25,
        0.72,
        wake_phase
    );
    let wash = gaussian(stern_along) *
               (shaft_wash * 0.78 + center_wash * 0.22) *
               spatial_breakup * strength;

    let speed_energy = clamp(speed / 15.0, 0.15, 1.4);
    let outward = select(-1.0, 1.0, lateral >= 0.0);
    let churn = sin(dot(world, vec2<f32>(0.19, 0.11)) + ship.params.z * 2.3);
    // Preserve a coherent outward component in the stern disturbance. The
    // simulation uses this vector to spread old propeller wash laterally;
    // without it every deposited patch remains a constant-width paint stripe.
    let wash_flow = right * outward * wash *
                    (0.060 + speed_energy * 0.026) *
                    (0.78 + churn * 0.22);
    let slope = -forward * bow * (0.044 + speed_energy * 0.018) +
                right * outward * shoulders * 0.026 +
                wash_flow;
    let height = bow * 0.068 + wash * (-0.028 + wake_phase * 0.021);
    // Do not fill the whole hull shoulder with foam. That creates a bright
    // ship-sized capsule at distance. Bow aeration stays compact; sustained
    // foam is deposited only by stern wash.
    let foam = wash * (0.28 + speed_energy * 0.18);
    return vec4<f32>(slope, height, foam);
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
    let texel_world = wake.field.z / max(f32(dims.x), 1.0);

    // WoWS' local simulation uses a damped neighborhood update. This is a
    // deliberately small version of that idea: preserve world-space history,
    // let it spread by a fraction of a texel, and damp displacement faster than
    // foam. No new disturbance appears when dt is zero.
    let center = sample_previous(world, dims);
    let east = sample_previous(world + vec2<f32>(texel_world, 0.0), dims);
    let west = sample_previous(world - vec2<f32>(texel_world, 0.0), dims);
    let north = sample_previous(world + vec2<f32>(0.0, texel_world), dims);
    let south = sample_previous(world - vec2<f32>(0.0, texel_world), dims);
    let neighbors = (east + west + north + south) * 0.25;

    // Conservative four-neighbour transport turns the coherent stern slope
    // into slow lateral wash spreading. This widens older wake sections into
    // a V without generating any disturbance away from previously deposited
    // ship interaction.
    let incoming_foam =
        max(-east.x, 0.0) * east.w +
        max( west.x, 0.0) * west.w +
        max(-north.y, 0.0) * north.w +
        max( south.y, 0.0) * south.w;
    let outgoing_foam = (
        max( center.x, 0.0) + max(-center.x, 0.0) +
        max( center.y, 0.0) + max(-center.y, 0.0)
    ) * center.w;
    let foam_transport = (incoming_foam - outgoing_foam) *
                         clamp(dt * 28.0, 0.0, 0.22);
    let transported_foam = max(center.w + foam_transport, 0.0);
    var value = vec4<f32>(
        mix(center.xy, neighbors.xy, clamp(dt * 0.30, 0.0, 0.05)) * exp(-dt * 0.16),
        mix(center.z, neighbors.z, clamp(dt * 0.22, 0.0, 0.04)) * exp(-dt * 0.11),
        // Keep old wash directional. Excess isotropic diffusion was turning a
        // long-lived trail back into a widening cloud.
        // Roughly 12.6s half-life: long enough to read as a wake, short enough
        // for old tracks to visibly disappear.
        mix(transported_foam, neighbors.w, clamp(dt * 0.018, 0.0, 0.006)) * exp(-dt * 0.055)
    );

    let ship_count = min(i32(wake.previous_time_count.w + 0.5), 4);
    for (var i = 0; i < ship_count; i = i + 1) {
        let source = ship_disturbance(world, wake.ships[i]);
        value = vec4<f32>(
            value.xy + source.xy * dt * 1.20,
            value.z + source.z * dt * 1.00,
            value.w + source.w * dt * 1.00 * (1.0 - value.w)
        );
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
