#ifndef linearizeDepth_glsl
#define linearizeDepth_glsl

float linearizeDepth(float depth) {
    return (near * far) / (depth * (near - far) + far);
}

#endif