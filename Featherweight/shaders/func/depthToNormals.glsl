uniform float viewWidth;
uniform float viewHeight;
const vec2 res = vec2(viewWidth, viewHeight);
const vec2 texel = 1.0/res;


#include "/func/depthToViewPos.glsl"

vec3 depthToNormals(vec2 coord, float depth) {
    const vec3 P = depthToViewPos(coord, depth);
    const vec3 dX = dFdx(P);
    const vec3 dY = dFdy(P);

    return normalize(cross(dX, dY));
}

vec3 depthToNormals(vec2 coord, sampler2D depthTex) {
	const vec4 depths = textureGather(depthTex, floor(coord*res)/res);
    const vec3 normal0 = depthToNormals(coord, depths.x);
	const vec3 normal1 = depthToNormals(coord, depths.y);
	const vec3 normal2 = depthToNormals(coord, depths.z);
	const vec3 normal3 = depthToNormals(coord, depths.w);

    return (normal0 + normal1 + normal2 + normal3)*0.25;
}