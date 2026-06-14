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
    let n = normalize(in.normal);
    let l = normalize(-ship.light_dir_pad.xyz);
    let v = normalize(ship.camera_pos_pad.xyz - in.world_pos);
    let h = normalize(l + v);

    let tex = textureSample(ship_tex, ship_sampler, in.uv);
    let ndl = clamp(dot(n, l), 0.0, 1.0);
    let ndh = clamp(dot(n, h), 0.0, 1.0);

    let ambient = vec3<f32>(0.18, 0.22, 0.24);
    let diffuse = tex.rgb * (ambient + ndl * vec3<f32>(0.74, 0.76, 0.72));
    let spec = pow(ndh, 58.0) * 0.12;
    let color = diffuse + vec3<f32>(0.95, 0.88, 0.72) * spec;

    // Keep cutout/transparent exporter materials from becoming heavy gray sheets,
    // but do not discard all semi-transparent details.
    if (tex.a < 0.08) {
        discard;
    }
    return vec4<f32>(color, tex.a);
}
