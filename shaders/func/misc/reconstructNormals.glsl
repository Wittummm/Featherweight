#include "/func/depthToViewPos.glsl"

vec3 reconstructNormals(vec2 coord, float depth) {
    vec3 P = depthToViewPos(coord, depth);
    vec3 dX = dFdx(P);
    vec3 dY = dFdy(P);

    return normalize(cross(dX, dY));
}

vec3 reconstructNormals(vec2 coord, sampler2D depthtex) {
    vec2 resolution = vec2(textureSize(depthtex, 0));
    vec2 oneOverRes = 1.0/resolution;

    vec4 depths = textureGather(depthtex, floor(coord*resolution)*oneOverRes);
    vec3 normal0 = reconstructNormals(coord + vec2(0, oneOverRes.y), depths.x);
    vec3 normal1 = reconstructNormals(coord + oneOverRes, depths.y);
    vec3 normal2 = reconstructNormals(coord + vec2(oneOverRes.x, 0), depths.z);
    vec3 normal3 = reconstructNormals(coord, depths.w);

    return (normal0 + normal1 + normal2 + normal3)*0.25;
}