#version 330

in vec3 vertexPosition;
in vec3 vertexNormal;
in vec2 vertexTexCoord;

uniform mat4 mvp;
uniform mat4 matModel;
uniform float time;
uniform float cascadeCount;
uniform float cascadeSize0;
uniform float cascadeSize1;
uniform float cascadeSize2;
uniform float renderGridSpacing;
uniform sampler2D cascadeHeightDisp0;
uniform sampler2D cascadeHeightDisp1;
uniform sampler2D cascadeHeightDisp2;
uniform sampler2D cascadeSlopeFold0;
uniform sampler2D cascadeSlopeFold1;
uniform sampler2D cascadeSlopeFold2;

out vec3 fragWorldPos;
out vec3 fragNormal;
out vec2 fragTexCoord;
out float fragHeight;
out vec2 fragSlope;
out float fragSlopeMagnitude;
out float fragCurvature;
out float fragJacobian;
out float fragFolding;

vec2 cascadeUV(vec2 p, float size) {
    return p / size + vec2(0.5);
}

vec4 sampleHeightDisp(int index, vec2 p) {
    if (index == 0) {
        return texture(cascadeHeightDisp0, cascadeUV(p, cascadeSize0));
    }

    if (index == 1) {
        return texture(cascadeHeightDisp1, cascadeUV(p, cascadeSize1));
    }

    return texture(cascadeHeightDisp2, cascadeUV(p, cascadeSize2));
}

vec4 sampleSlopeFold(int index, vec2 p) {
    if (index == 0) {
        return texture(cascadeSlopeFold0, cascadeUV(p, cascadeSize0));
    }

    if (index == 1) {
        return texture(cascadeSlopeFold1, cascadeUV(p, cascadeSize1));
    }

    return texture(cascadeSlopeFold2, cascadeUV(p, cascadeSize2));
}

vec4 sampleTotalHeightDisp(vec2 p) {
    vec4 total = vec4(0.0, 0.0, 0.0, 1.0);

    if (cascadeCount > 0.5) {
        vec4 hd = sampleHeightDisp(0, p);
        total.rgb += hd.rgb;
        total.a = min(total.a, hd.a);
    }

    if (cascadeCount > 1.5) {
        vec4 hd = sampleHeightDisp(1, p);
        total.rgb += hd.rgb;
        total.a = min(total.a, hd.a);
    }

    if (cascadeCount > 2.5) {
        vec4 hd = sampleHeightDisp(2, p);
        total.rgb += hd.rgb;
        total.a = min(total.a, hd.a);
    }

    return total;
}

vec3 sampleTotalSlopeFold(vec2 p) {
    vec3 total = vec3(0.0);

    if (cascadeCount > 0.5) {
        vec4 sf = sampleSlopeFold(0, p);
        total.xy += sf.rg;
        total.z = max(total.z, sf.b);
    }

    if (cascadeCount > 1.5) {
        vec4 sf = sampleSlopeFold(1, p);
        total.xy += sf.rg;
        total.z = max(total.z, sf.b);
    }

    if (cascadeCount > 2.5) {
        vec4 sf = sampleSlopeFold(2, p);
        total.xy += sf.rg;
        total.z = max(total.z, sf.b);
    }

    return total;
}

vec2 rotate2(vec2 v, float angle) {
    float c = cos(angle);
    float s = sin(angle);
    return vec2(c * v.x - s * v.y, s * v.x + c * v.y);
}

vec4 sampleLayerHeightDisp(vec2 p, float scale, float angle, vec2 offset) {
    vec4 hd = sampleTotalHeightDisp(rotate2(p, angle) * scale + offset);
    hd.gb = rotate2(hd.gb, -angle);
    return hd;
}

vec3 sampleLayerSlopeFold(vec2 p, float scale, float angle, vec2 offset) {
    vec3 sf = sampleTotalSlopeFold(rotate2(p, angle) * scale + offset);
    sf.xy = rotate2(sf.xy, -angle) * scale;
    return sf;
}

float macroSwellHeight(vec2 p) {
    float t = time * 0.08;
    float a = sin(dot(p, normalize(vec2(0.86, 0.51))) * 0.0021 + t);
    float b = sin(dot(p, normalize(vec2(-0.38, 0.92))) * 0.0014 - t * 0.73 + 1.7);
    float c = sin(dot(p, normalize(vec2(0.21, -0.98))) * 0.0032 + t * 1.21 + 4.1);
    return (a * 0.85 + b * 0.65 + c * 0.28) * 0.42;
}

vec2 geometryDomainWarp(vec2 p) {
    float t = time * 0.035;
    float x = sin(dot(p, vec2(0.0017, 0.0009)) + t) + sin(dot(p, vec2(-0.0008, 0.0013)) - t * 1.31 + 2.4);
    float z = sin(dot(p, vec2(0.0011, -0.0015)) - t * 0.83 + 4.6) + sin(dot(p, vec2(0.0006, 0.0019)) + t * 1.17);
    return vec2(x, z) * 58.0;
}

vec2 macroSwellSlope(vec2 p) {
    float t = time * 0.08;
    vec2 d0 = normalize(vec2(0.86, 0.51));
    vec2 d1 = normalize(vec2(-0.38, 0.92));
    vec2 d2 = normalize(vec2(0.21, -0.98));
    vec2 slope = vec2(0.0);
    slope += d0 * cos(dot(p, d0) * 0.0021 + t) * 0.0021 * 0.85;
    slope += d1 * cos(dot(p, d1) * 0.0014 - t * 0.73 + 1.7) * 0.0014 * 0.65;
    slope += d2 * cos(dot(p, d2) * 0.0032 + t * 1.21 + 4.1) * 0.0032 * 0.28;
    return slope * 0.42;
}

vec4 sampleAntiTiledHeightDisp(vec2 p) {
    vec4 a = sampleLayerHeightDisp(p, 1.0, 0.0, vec2(0.0));
    vec4 b = sampleLayerHeightDisp(p, 0.731, 0.74, vec2(117.0, -283.0));
    vec4 c = sampleLayerHeightDisp(p, 1.337, -1.18, vec2(-421.0, 199.0));
    vec4 total = a * 0.70 + b * 0.22 + c * 0.08;
    total.r += macroSwellHeight(p);
    total.a = min(a.a, min(b.a, c.a));
    return total;
}

vec3 sampleAntiTiledSlopeFold(vec2 p) {
    vec3 a = sampleLayerSlopeFold(p, 1.0, 0.0, vec2(0.0));
    vec3 b = sampleLayerSlopeFold(p, 0.731, 0.74, vec2(117.0, -283.0));
    vec3 c = sampleLayerSlopeFold(p, 1.337, -1.18, vec2(-421.0, 199.0));
    vec3 total = a * 0.70 + b * 0.22 + c * 0.08;
    total.xy += macroSwellSlope(p);
    total.z = max(a.z, max(b.z * 0.65, c.z * 0.45));
    return total;
}

float curvatureFromSlope(vec2 p) {
    float eps = max(renderGridSpacing * 0.75, 0.25);
    vec2 slopeR = sampleAntiTiledSlopeFold(p + vec2(eps, 0.0)).xy;
    vec2 slopeL = sampleAntiTiledSlopeFold(p - vec2(eps, 0.0)).xy;
    vec2 slopeU = sampleAntiTiledSlopeFold(p + vec2(0.0, eps)).xy;
    vec2 slopeD = sampleAntiTiledSlopeFold(p - vec2(0.0, eps)).xy;
    return ((slopeR.x - slopeL.x) + (slopeU.y - slopeD.y)) / (2.0 * eps);
}

void main() {
    vec4 baseWorld = matModel * vec4(vertexPosition, 1.0);
    vec2 waveSamplePos = baseWorld.xz + geometryDomainWarp(baseWorld.xz);
    vec4 heightDisp = sampleAntiTiledHeightDisp(waveSamplePos);
    vec3 slopeFold = sampleAntiTiledSlopeFold(waveSamplePos);
    vec3 displaced = vertexPosition + vec3(heightDisp.g, heightDisp.r, heightDisp.b);
    vec3 normal = normalize(vec3(-slopeFold.x, 1.0, -slopeFold.y));

    vec4 world = matModel * vec4(displaced, 1.0);
    fragWorldPos = world.xyz;
    fragNormal = normalize(mat3(matModel) * normal);
    fragTexCoord = vertexTexCoord;
    fragHeight = displaced.y;
    fragSlope = slopeFold.xy;
    fragSlopeMagnitude = length(slopeFold.xy);
    fragCurvature = -curvatureFromSlope(waveSamplePos);
    fragJacobian = heightDisp.a;
    fragFolding = slopeFold.z;
    gl_Position = mvp * vec4(displaced, 1.0);
}
