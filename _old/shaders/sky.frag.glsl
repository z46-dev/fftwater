#version 330

in vec3 fragDir;

uniform vec3 sunDirection;
uniform vec3 cameraPosition;
uniform float time;
uniform float environmentMode;

out vec4 finalColor;

float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    float a = hash(i + vec2(0, 0));
    float b = hash(i + vec2(1, 0));
    float c = hash(i + vec2(0, 1));
    float d = hash(i + vec2(1, 1));
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

float fbm(vec2 p) {
    float v = 0.0;
    float a = 0.5;
    for (int i = 0; i < 5; i++) {
        v += a * noise(p);
        p *= 2.03;
        a *= 0.5;
    }
    return v;
}

void main() {
    vec3 dir = normalize(fragDir);
    vec3 light = normalize(sunDirection);
    float sunset = step(0.5, environmentMode) * (1.0 - step(1.5, environmentMode));
    float night = step(1.5, environmentMode);
    float day = 1.0 - sunset - night;

    float y = clamp(dir.y * 0.5 + 0.5, 0.0, 1.0);
    float up = clamp(dir.y, 0.0, 1.0);

    vec3 dayHorizon = vec3(0.72, 0.80, 0.84);
    vec3 dayZenith = vec3(0.35, 0.55, 0.72);
    vec3 sunsetHorizon = vec3(1.00, 0.48, 0.25);
    vec3 sunsetZenith = vec3(0.25, 0.23, 0.46);
    vec3 nightHorizon = vec3(0.035, 0.055, 0.095);
    vec3 nightZenith = vec3(0.006, 0.010, 0.030);

    vec3 horizon = dayHorizon * day + sunsetHorizon * sunset + nightHorizon * night;
    vec3 zenith = dayZenith * day + sunsetZenith * sunset + nightZenith * night;
    vec3 sky = mix(horizon, zenith, pow(y, 0.80));

    float lightDot = max(dot(dir, light), 0.0);
    vec3 sunColor = vec3(1.0, 0.84, 0.52) * day + vec3(1.0, 0.43, 0.18) * sunset + vec3(0.58, 0.68, 0.92) * night;
    float diskThreshold = mix(0.9992, 0.9984, sunset);
    diskThreshold = mix(diskThreshold, 0.99945, night);
    float disk = smoothstep(diskThreshold, 1.0, dot(dir, light));
    float glowPower = day * 170.0 + sunset * 36.0 + night * 220.0;
    float glow = pow(lightDot, glowPower) * (day * 0.65 + sunset * 1.75 + night * 0.40);
    sky += sunColor * (disk * (day * 2.4 + sunset * 3.2 + night * 1.4) + glow);

    float twilightBand = sunset * exp(-abs(dir.y) * 7.5);
    sky += vec3(0.85, 0.22, 0.08) * twilightBand * 0.28;

    // Simple stylized high clouds. They are intentionally slow and subtle.
    vec2 cloudUV = dir.xz / max(dir.y + 0.35, 0.08);
    cloudUV *= 0.55;
    cloudUV += vec2(time * 0.003, time * 0.001);
    float c = fbm(cloudUV * 2.0);
    float cloud = smoothstep(0.56, 0.78, c) * smoothstep(0.05, 0.45, dir.y);
    vec3 cloudColor = vec3(0.92, 0.95, 0.96) * day + vec3(1.0, 0.56, 0.36) * sunset + vec3(0.08, 0.10, 0.16) * night;
    sky = mix(sky, cloudColor, cloud * (day * 0.35 + sunset * 0.42 + night * 0.18));

    float starField = pow(hash(floor(dir.xz * 560.0 + dir.y * 83.0)), 42.0);
    float stars = starField * smoothstep(0.05, 0.38, up) * night;
    sky += vec3(0.74, 0.82, 1.0) * stars * 1.25;

    // Horizon haze.
    float haze = exp(-up * 10.0);
    vec3 hazeColor = vec3(0.78, 0.84, 0.86) * day + vec3(0.95, 0.45, 0.25) * sunset + vec3(0.055, 0.070, 0.105) * night;
    sky = mix(sky, hazeColor, haze * (day * 0.32 + sunset * 0.45 + night * 0.30));

    finalColor = vec4(sky, 1.0);
}
