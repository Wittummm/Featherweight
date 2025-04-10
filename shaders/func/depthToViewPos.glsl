#ifndef depthToViewPos_glsl

#define depthToViewPos_glsl

uniform mat4 gbufferProjectionInverse;

vec3 depthToViewPos(vec2 texCoord, float depth) {
    const vec4 ndc = vec4(texCoord, depth, 1) * 2.0 - 1.0;
    const vec4 viewPos = gbufferProjectionInverse * ndc;
    return viewPos.xyz / viewPos.w;
}

#endif