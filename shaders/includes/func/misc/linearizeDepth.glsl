#ifndef linearizeDepth_glsl
#define linearizeDepth_glsl

float linearizeDepth(float depth, float n, float f) {
    return (n * f) / (depth * (n - f) + f);
}

float linearizeDepthFull(float depth, float n, float f) {
    depth = depth * 2 - 1;
    return 2 * f * n / (f + n - depth * (f - n));
}

#endif