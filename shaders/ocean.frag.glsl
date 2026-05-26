#version 330

in vec3 fragWorldPos;
in vec3 fragNormal;
in vec2 fragTexCoord;
in float fragHeight;
in vec2 fragSlope;
in float fragSlopeMagnitude;
in float fragCurvature;
in float fragJacobian;
in float fragFolding;

uniform vec3 sunDirection;
uniform vec3 cameraPosition;
uniform float debugMode;
uniform float environmentMode;
uniform float time;
uniform vec2 oceanRenderCenter;
uniform float oceanRenderHalfSize;

uniform vec3 uDeepColor;
uniform vec3 uMidColor;
uniform vec3 uCrestColor;
uniform vec3 uFoamColor;

uniform float uFoamSlopeStart;
uniform float uFoamSlopeEnd;
uniform float uFoamCurvatureStart;
uniform float uFoamCurvatureEnd;
uniform float uFoamAmount;
uniform float uFoamBreakupScale;

uniform vec3 uSunColor;
uniform float uSunStrength;
uniform float uRoughnessBase;
uniform float uRoughnessCrest;
uniform float uF0;

uniform vec3 uTransmissionColor;
uniform float uTransmissionStrength;

uniform float uMicroNormalStrength;
uniform float uMicroDetailScale;
uniform float uMicroDetailSpeed;

out vec4 finalColor;

const float PI = 3.14159265359;

vec3 tonemap(vec3 c) {
    c = vec3(1.0) - exp(-c * 1.08);
    return pow(max(c, vec3(0.0)), vec3(1.0 / 2.2));
}

vec3 skyGradient(vec3 dir) {
    float sunset = step(0.5, environmentMode) * (1.0 - step(1.5, environmentMode));
    float night = step(1.5, environmentMode);
    float day = 1.0 - sunset - night;

    float y = clamp(dir.y * 0.5 + 0.5, 0.0, 1.0);
    vec3 horizon = vec3(0.72, 0.80, 0.84) * day + vec3(1.00, 0.48, 0.25) * sunset + vec3(0.035, 0.055, 0.095) * night;
    vec3 zenith = vec3(0.35, 0.55, 0.72) * day + vec3(0.25, 0.23, 0.46) * sunset + vec3(0.006, 0.010, 0.030) * night;
    return mix(horizon, zenith, pow(y, 0.75));
}

vec3 horizonFogColor(vec3 dir) {
    float sunset = step(0.5, environmentMode) * (1.0 - step(1.5, environmentMode));
    float night = step(1.5, environmentMode);
    float day = 1.0 - sunset - night;
    float up = clamp(dir.y, 0.0, 1.0);

    vec3 hazeColor = vec3(0.78, 0.84, 0.86) * day + vec3(0.95, 0.45, 0.25) * sunset + vec3(0.055, 0.070, 0.105) * night;
    float haze = exp(-up * 10.0);
    return mix(skyGradient(dir), hazeColor, haze * (day * 0.32 + sunset * 0.45 + night * 0.30));
}

float hash21(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float valueNoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);

    float a = hash21(i);
    float b = hash21(i + vec2(1.0, 0.0));
    float c = hash21(i + vec2(0.0, 1.0));
    float d = hash21(i + vec2(1.0, 1.0));

    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

float breakupNoise(vec2 worldXZ) {
    float scale = max(uFoamBreakupScale, 0.001);
    vec2 p = worldXZ * scale;
    float n0 = valueNoise(p);
    float n1 = valueNoise(p * 2.37 + vec2(sin(time * 0.37), cos(time * 0.31)) * 0.18);
    return clamp(n0 * 0.65 + n1 * 0.35, 0.0, 1.0);
}

vec2 microSlope(vec2 worldXZ) {
    float s = max(uMicroDetailScale, 0.001);
    float t = time * uMicroDetailSpeed;
    vec2 p = worldXZ * s;
    vec2 slope = vec2(0.0);

    vec2 d0 = normalize(vec2(0.92, 0.39));
    vec2 d1 = normalize(vec2(-0.38, 0.93));
    vec2 d2 = normalize(vec2(0.71, -0.70));
    vec2 d3 = normalize(vec2(-0.96, -0.28));

    slope += d0 * cos(dot(p, d0) * 2.10 + t * 1.25 + 0.4) * 0.030 * 2.10;
    slope += d1 * cos(dot(p, d1) * 3.35 + t * 1.75 + 2.1) * 0.020 * 3.35;
    slope += d2 * cos(dot(p, d2) * 5.10 + t * 2.10 + 4.0) * 0.012 * 5.10;
    slope += d3 * cos(dot(p, d3) * 7.40 + t * 2.80 + 1.3) * 0.007 * 7.40;

    return slope;
}

float distributionGGX(float ndh, float roughness) {
    float a = roughness * roughness;
    float a2 = a * a;
    float denom = ndh * ndh * (a2 - 1.0) + 1.0;
    return a2 / max(PI * denom * denom, 0.00001);
}

float geometrySchlickGGX(float nd, float roughness) {
    float r = roughness + 1.0;
    float k = (r * r) / 8.0;
    return nd / max(nd * (1.0 - k) + k, 0.00001);
}

float geometrySmith(float ndv, float ndl, float roughness) {
    return geometrySchlickGGX(ndv, roughness) * geometrySchlickGGX(ndl, roughness);
}

vec3 fresnelSchlick(float cosTheta, vec3 f0) {
    return f0 + (vec3(1.0) - f0) * pow(1.0 - clamp(cosTheta, 0.0, 1.0), 5.0);
}

void main() {
    vec3 Nmacro = normalize(fragNormal);
    vec3 V = normalize(cameraPosition - fragWorldPos);
    vec3 L = normalize(sunDirection);

    vec2 micro = microSlope(fragWorldPos.xz);
    vec3 N = normalize(Nmacro + vec3(-micro.x, 0.0, -micro.y) * uMicroNormalStrength);

    float ndv = clamp(dot(N, V), 0.0, 1.0);
    float ndl = clamp(dot(N, L), 0.0, 1.0);
    float macroSlope = fragSlopeMagnitude;
    float crestCurvature = max(fragCurvature, 0.0);

    float slopeMask = smoothstep(uFoamSlopeStart, uFoamSlopeEnd, macroSlope);
    float curvatureMask = smoothstep(uFoamCurvatureStart, uFoamCurvatureEnd, crestCurvature);
    float compressionMask = 1.0 - smoothstep(0.48, 0.86, fragJacobian);
    float foldingMask = clamp(max(compressionMask, fragFolding * 1.15), 0.0, 1.0);
    float crestMask = clamp(max(foldingMask, slopeMask * curvatureMask), 0.0, 1.0);
    float crestCore = pow(crestMask, 1.65);

    float foamBreakup = breakupNoise(fragWorldPos.xz);
    float foamCells = breakupNoise(fragWorldPos.xz * 1.73 + vec2(17.0, -9.0));
    float foamPatch = smoothstep(0.58, 0.92, foamBreakup + crestCore * 0.22);
    float foamHoles = smoothstep(0.22, 0.70, foamCells);
    float foamThread = smoothstep(0.62, 0.95, crestCore + foamBreakup * 0.18);
    float foamDistanceFade = 1.0 - smoothstep(180.0, 520.0, length(cameraPosition - fragWorldPos));
    float foam = clamp(crestCore * foamThread * foamPatch * foamHoles * (0.62 + 0.28 * foamBreakup) * uFoamAmount * foamDistanceFade, 0.0, 1.0);

    if (debugMode > 1.5 && debugMode < 2.5) {
        float h = clamp(fragHeight * 0.28 + 0.5, 0.0, 1.0);
        finalColor = vec4(vec3(h), 1.0);
        return;
    }

    if (debugMode > 2.5 && debugMode < 3.5) {
        finalColor = vec4(vec3(clamp(macroSlope * 1.25, 0.0, 1.0)), 1.0);
        return;
    }

    if (debugMode > 3.5 && debugMode < 4.5) {
        finalColor = vec4(N * 0.5 + 0.5, 1.0);
        return;
    }

    if (debugMode > 4.5 && debugMode < 5.5) {
        finalColor = vec4(vec3(foam), 1.0);
        return;
    }

    float sunset = step(0.5, environmentMode) * (1.0 - step(1.5, environmentMode));
    float night = step(1.5, environmentMode);
    float day = 1.0 - sunset - night;

    vec3 envWaterTint = vec3(1.0) * day + vec3(1.08, 0.82, 0.62) * sunset + vec3(0.34, 0.42, 0.66) * night;
    vec3 deepColor = uDeepColor * envWaterTint;
    vec3 midColor = uMidColor * envWaterTint;
    vec3 crestColor = uCrestColor * (vec3(1.0) * day + vec3(1.14, 0.90, 0.72) * sunset + vec3(0.45, 0.52, 0.74) * night);
    vec3 foamColor = uFoamColor * (vec3(1.0) * day + vec3(1.08, 0.92, 0.78) * sunset + vec3(0.42, 0.48, 0.62) * night);

    float heightBlend = smoothstep(-1.45, 1.65, fragHeight);
    float trough = 1.0 - smoothstep(-1.80, -0.10, fragHeight);
    vec3 bodyColor = mix(deepColor, midColor, heightBlend);
    bodyColor = mix(bodyColor, deepColor * 0.78, trough * 0.25);
    bodyColor = mix(bodyColor, crestColor, clamp(crestMask * 0.30 + slopeMask * 0.045 + heightBlend * curvatureMask * 0.08, 0.0, 0.42));

    vec3 R = reflect(-V, N);
    vec3 reflectedSky = skyGradient(R);

    vec3 f0 = vec3(clamp(uF0, 0.0, 0.12));
    vec3 fresnel = fresnelSchlick(ndv, f0);
    float reflectionWeight = clamp((fresnel.r + foam * 0.04) * (0.62 * day + 0.72 * sunset + 0.84 * night), 0.0, 0.92);

    float agitation = clamp(crestMask * 0.65 + macroSlope * 0.22 + length(micro) * 0.45, 0.0, 1.0);
    float roughness = clamp(mix(uRoughnessBase, uRoughnessCrest, agitation), 0.025, 0.45);
    vec3 H = normalize(V + L);
    float ndh = clamp(dot(N, H), 0.0, 1.0);
    float vdh = clamp(dot(V, H), 0.0, 1.0);
    float D = distributionGGX(ndh, roughness);
    float G = geometrySmith(max(ndv, 0.001), max(ndl, 0.001), roughness);
    vec3 F = fresnelSchlick(vdh, f0);
    vec3 specularBRDF = (D * G * F) / max(4.0 * max(ndv, 0.001) * max(ndl, 0.001), 0.001);

    vec3 envSunColor = uSunColor * (vec3(1.00, 0.96, 0.84) * day + vec3(1.20, 0.62, 0.28) * sunset + vec3(0.46, 0.56, 0.86) * night);
    float glintBreakup = mix(0.72, 1.22, foamBreakup) * mix(1.0, 0.72, crestMask);
    vec3 sunGlint = specularBRDF * envSunColor * ndl * uSunStrength * glintBreakup;

    float faceLight = pow(clamp(dot(-L, N) * 0.5 + 0.5, 0.0, 1.0), 1.8);
    float viewPath = pow(1.0 - ndv, 1.35);
    vec3 transmission = uTransmissionColor * envWaterTint * uTransmissionStrength * faceLight * viewPath * (1.0 - foam);

    float ambient = 0.52 * day + 0.34 * sunset + 0.13 * night;
    float sunBody = (0.34 * day + 0.32 * sunset + 0.08 * night) * ndl;
    vec3 litWater = bodyColor * (ambient + sunBody) + transmission;
    vec3 color = mix(litWater, reflectedSky, reflectionWeight);
    color += sunGlint;
    vec3 aeratedWater = mix(color, foamColor, foam * 0.68);
    color = mix(color, aeratedWater, clamp(foam * 0.82, 0.0, 1.0));

    vec3 viewDir = normalize(fragWorldPos - cameraPosition);
    float viewDistance = length(fragWorldPos - cameraPosition);
    float distanceFog = smoothstep(1900.0, 5200.0, viewDistance);
    float horizonFog = exp(-max(viewDir.y, 0.0) * 4.2);
    float fog = clamp(distanceFog * mix(0.35, 0.82, horizonFog), 0.0, 0.82);
    float edgeDistance = oceanRenderHalfSize - max(abs(fragWorldPos.x - oceanRenderCenter.x), abs(fragWorldPos.z - oceanRenderCenter.y));
    float edgeFadeWidth = min(1400.0, oceanRenderHalfSize * 0.35);
    float edgeFog = 1.0 - smoothstep(0.0, edgeFadeWidth, edgeDistance);
    fog = max(fog, edgeFog);
    color = mix(color, horizonFogColor(viewDir), fog);

    finalColor = vec4(tonemap(color), 1.0);
}
