#include "/includes/func/color/luminance.glsl"

const mat3 agxTransform = mat3(
    0.842479062253094, 0.0423282422610123, 0.0423756549057051,
    0.0784335999999992, 0.878468636469772, 0.0784336,
    0.0792237451477643, 0.0791661274605434, 0.879142973793104);

const mat3 agxTransformInverse = mat3(
    1.19687900512017, -0.0528968517574562, -0.0529716355144438,
    -0.0980208811401368, 1.15190312990417, -0.0980434501171241,
    -0.0990297440797205, -0.0989611768448433, 1.15107367264116);

vec3 agxDefaultContrastApproximation(vec3 x) {
    vec3 x2 = x * x;
    vec3 x4 = x2 * x2;
    return 15.5 * x4 * x2 - 40.14 * x4 * x + 31.96 * x4 - 6.868 * x2 * x + 0.4298 * x2 + 0.1191 * x - 0.00232;
}

void _agx(inout vec3 color) {
    const float minEv = -12.47393;
    const float maxEv = 4.026069;
    color = agxTransform * color;
    color = clamp(log2(color), minEv, maxEv);
    color = (color - minEv) / (maxEv - minEv);
    color = agxDefaultContrastApproximation(color);
}

void agxEotf(inout vec3 color) {
    color = agxTransformInverse * color;
}

void agxLook(inout vec3 color) {
    // Punchy
    const vec3 slope = vec3(1.1);
    const vec3 power = vec3(1.2);
    const float saturation = 1.3;
    float luma = luminance(color);
    color = pow(color * slope, power);
    color = max(luma + saturation * (color - luma), vec3(0.0));
}

vec3 agx(vec3 color) {
    _agx(color);
    agxLook(color);
    agxEotf(color);
    return color;
}