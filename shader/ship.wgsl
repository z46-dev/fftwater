struct ShipUniforms {
    view_proj: mat4x4<f32>,
    model: mat4x4<f32>,
    normal_model: mat4x4<f32>,
    camera_pos_pad: vec4<f32>,
    light_dir_pad: vec4<f32>,
};

@group(0) @binding(0)
var<uniform> ship: ShipUniforms;

@group(1) @binding(0)
var ship_tex: texture_2d<f32>;

@group(1) @binding(1)
var ship_sampler: sampler;

struct VertexIn {
    @location(0) position: vec3<f32>,
    @location(1) normal: vec3<f32>,
    @location(2) uv: vec2<f32>,
};

struct VertexOut {
    @builtin(position) position: vec4<f32>,
    @location(0) world_pos: vec3<f32>,
    @location(1) normal: vec3<f32>,
    @location(2) uv: vec2<f32>,
    @location(3) source_y: f32,
};

@vertex
fn vs_main(in: VertexIn) -> VertexOut {
    let world = ship.model * vec4<f32>(in.position, 1.0);
    var out: VertexOut;
    out.position = ship.view_proj * world;
    out.world_pos = world.xyz;
    out.normal = normalize((ship.normal_model * vec4<f32>(in.normal, 0.0)).xyz);
    out.uv = in.uv;
    out.source_y = world.y;
    return out;
}

@vertex
fn vs_reflection(in: VertexIn) -> VertexOut {
    let source_world = ship.model * vec4<f32>(in.position, 1.0);
    let reflected_world = vec4<f32>(
        source_world.x,
        ship.camera_pos_pad.w * 2.0 - source_world.y,
        source_world.z,
        source_world.w
    );

    var out: VertexOut;
    out.position = ship.view_proj * reflected_world;
    out.world_pos = reflected_world.xyz;
    out.normal = normalize((ship.normal_model * vec4<f32>(in.normal, 0.0)).xyz) * vec3<f32>(1.0, -1.0, 1.0);
    out.uv = in.uv;
    out.source_y = source_world.y;
    return out;
}

@vertex
fn vs_shadow(in: VertexIn) -> VertexOut {
    let source_world = ship.model * vec4<f32>(in.position, 1.0);
    let to_light = normalize(vec3<f32>(-0.42, 0.78, -0.46));
    let height = max(source_world.y - ship.camera_pos_pad.w, 0.0);
    let projected_xz = source_world.xz - to_light.xz * (height / max(to_light.y, 0.01));
    let projected_world = vec4<f32>(
        projected_xz.x,
        ship.camera_pos_pad.w + 0.02,
        projected_xz.y,
        source_world.w
    );

    var out: VertexOut;
    out.position = ship.view_proj * projected_world;
    out.world_pos = projected_world.xyz;
    out.normal = vec3<f32>(0.0, 1.0, 0.0);
    out.uv = in.uv;
    out.source_y = source_world.y;
    return out;
}

@fragment
fn fs_main(in: VertexOut) -> @location(0) vec4<f32> {
    // Analytically antialias the hull clipping plane. This works in the normal
    // single-sample path, so a clean waterline does not require multisampling
    // the entire fullscreen sky and ocean. In 4x mode the same alpha drives
    // alpha-to-coverage for a sample-accurate edge.
    let waterline_delta = in.world_pos.y - ship.camera_pos_pad.w;
    let waterline_width = max(fwidth(waterline_delta) * 1.35, 0.035);
    let camera_underwater = ship.camera_pos_pad.y < ship.camera_pos_pad.w;
    let waterline_coverage = select(
        smoothstep(-waterline_width, waterline_width, waterline_delta),
        1.0 - smoothstep(-waterline_width, waterline_width, waterline_delta),
        camera_underwater
    );
    if (waterline_coverage <= 0.001) {
        discard;
    }

    let n = normalize(in.normal);
    let l = normalize(-ship.light_dir_pad.xyz);
    let v = normalize(ship.camera_pos_pad.xyz - in.world_pos);
    let h = normalize(l + v);

    let tex = textureSample(ship_tex, ship_sampler, in.uv);
    let ndl = clamp(dot(n, l), 0.0, 1.0);
    let ndh = clamp(dot(n, h), 0.0, 1.0);

    let ambient = vec3<f32>(0.27, 0.30, 0.31);
    let diffuse = tex.rgb * (ambient + ndl * vec3<f32>(0.70, 0.72, 0.69));
    let spec = pow(ndh, 58.0) * 0.12;
    var color = diffuse + vec3<f32>(0.95, 0.88, 0.72) * spec;
    if camera_underwater {
        let distance_to_camera = length(ship.camera_pos_pad.xyz - in.world_pos);
        let camera_depth = max(ship.camera_pos_pad.w - ship.camera_pos_pad.y, 0.0);
        let water_depth = max(ship.camera_pos_pad.w - in.world_pos.y, 0.0);
        let depth_darkening = smoothstep(20.0, 230.0, camera_depth);
        let distance_density = mix(0.00055, 0.0075, depth_darkening);
        let fog = 1.0 - exp(-distance_to_camera * distance_density - water_depth * 0.008);
        color *= mix(vec3<f32>(0.88, 1.00, 0.97), vec3<f32>(0.44, 0.72, 0.72), depth_darkening);
        color = max(color, tex.rgb * mix(vec3<f32>(0.48, 0.58, 0.56), vec3<f32>(0.11, 0.20, 0.22), depth_darkening));
        let fog_color = mix(vec3<f32>(0.060, 0.265, 0.315), vec3<f32>(0.008, 0.072, 0.105), depth_darkening);
        color = mix(color, fog_color, clamp(fog, 0.0, mix(0.42, 0.92, depth_darkening)));
    }

    // Keep cutout/transparent exporter materials from becoming heavy gray sheets,
    // but do not discard all semi-transparent details.
    if (tex.a < 0.08) {
        discard;
    }
    return vec4<f32>(color, tex.a * waterline_coverage);
}

@fragment
fn fs_reflection(in: VertexOut) -> @location(0) vec4<f32> {
    let waterline_width = max(fwidth(in.source_y) * 1.35, 0.035);
    let waterline_coverage = smoothstep(
        -waterline_width,
        waterline_width,
        in.source_y - ship.camera_pos_pad.w
    );
    if waterline_coverage <= 0.001 {
        discard;
    }

    let tex = textureSample(ship_tex, ship_sampler, in.uv);
    if tex.a < 0.08 {
        discard;
    }
    let n = normalize(in.normal);
    let l = normalize(-ship.light_dir_pad.xyz);
    let diffuse = 0.24 + clamp(dot(n, l), 0.0, 1.0) * 0.54;
    let reflected_color = tex.rgb * diffuse * vec3<f32>(0.76, 0.84, 0.88);
    return vec4<f32>(reflected_color, tex.a * waterline_coverage);
}

@fragment
fn fs_shadow(in: VertexOut) -> @location(0) vec4<f32> {
    if in.source_y <= ship.camera_pos_pad.w {
        discard;
    }
    return vec4<f32>(0.0, 0.0, 0.0, 0.62);
}
