#version 330

in vec3 vertexPosition;
in vec3 vertexNormal;
in vec2 vertexTexCoord;

uniform mat4 mvp;
uniform mat4 matModel;
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

vec3 normalFromSlopeTextures(vec2 p) {
    vec2 slope = sampleTotalSlopeFold(p).xy;
    return normalize(vec3(-slope.x, 1.0, -slope.y));
}

float curvatureFromSlope(vec2 p) {
    float eps = max(renderGridSpacing * 0.75, 0.25);
    vec2 slopeR = sampleTotalSlopeFold(p + vec2(eps, 0.0)).xy;
    vec2 slopeL = sampleTotalSlopeFold(p - vec2(eps, 0.0)).xy;
    vec2 slopeU = sampleTotalSlopeFold(p + vec2(0.0, eps)).xy;
    vec2 slopeD = sampleTotalSlopeFold(p - vec2(0.0, eps)).xy;
    return ((slopeR.x - slopeL.x) + (slopeU.y - slopeD.y)) / (2.0 * eps);
}

void main() {
    vec4 heightDisp = sampleTotalHeightDisp(vertexPosition.xz);
    vec3 slopeFold = sampleTotalSlopeFold(vertexPosition.xz);
    vec3 displaced = vertexPosition + vec3(heightDisp.g, heightDisp.r, heightDisp.b);
    vec3 normal = normalize(vec3(-slopeFold.x, 1.0, -slopeFold.y));

    vec4 world = matModel * vec4(displaced, 1.0);
    fragWorldPos = world.xyz;
    fragNormal = normalize(mat3(matModel) * normal);
    fragTexCoord = vertexTexCoord;
    fragHeight = displaced.y;
    fragSlope = slopeFold.xy;
    fragSlopeMagnitude = length(slopeFold.xy);
    fragCurvature = -curvatureFromSlope(vertexPosition.xz);
    fragJacobian = heightDisp.a;
    fragFolding = slopeFold.z;
    gl_Position = mvp * vec4(displaced, 1.0);
}
