#ifndef depthToViewPos_glsl

#define depthToViewPos_glsl

vec3 depthToViewPos(vec2 fragCoord, float depth, mat4 projInverse) {
    vec4 ndc = vec4(fragCoord, depth, 1) * 2.0 - 1.0;
    vec4 viewPos = projInverse * ndc;
    return viewPos.xyz / viewPos.w;
}

vec3 depthToViewPos(vec2 fragCoord, float depth) {
    return depthToViewPos(fragCoord, depth, ap.camera.projectionInv);
}

vec3 calcViewDir(vec2 fragCoord) {
    return normalize(depthToViewPos(fragCoord, -1, ap.camera.projectionInv));
}

#endif