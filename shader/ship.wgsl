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
};

@vertex
fn vs_main(in: VertexIn) -> VertexOut {
    let world = ship.model * vec4<f32>(in.position, 1.0);
    var out: VertexOut;
    out.position = ship.view_proj * world;
    out.world_pos = world.xyz;
    out.normal = normalize((ship.normal_model * vec4<f32>(in.normal, 0.0)).xyz);
    out.uv = in.uv;
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
    let waterline_coverage = smoothstep(-waterline_width, waterline_width, waterline_delta);
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
    let color = diffuse + vec3<f32>(0.95, 0.88, 0.72) * spec;

    // Keep cutout/transparent exporter materials from becoming heavy gray sheets,
    // but do not discard all semi-transparent details.
    if (tex.a < 0.08) {
        discard;
    }
    return vec4<f32>(color, tex.a * waterline_coverage);
}
