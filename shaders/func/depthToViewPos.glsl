#ifndef depthToViewPos_glsl

#define depthToViewPos_glsl

uniform mat4 gbufferProjectionInverse;

vec3 depthToViewPos(vec2 fragCoord, float depth, mat4 projInverse) {
    const vec4 ndc = vec4(fragCoord, depth, 1) * 2.0 - 1.0;
    const vec4 viewPos = projInverse * ndc;
    return viewPos.xyz / viewPos.w;
}

vec3 depthToViewPos(vec2 fragCoord, float depth) {
    return depthToViewPos(fragCoord, depth, gbufferProjectionInverse);
}


#endif