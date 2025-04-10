vec3 reconstructNormal(vec2 coord, float depth) {
    vec3 P = depthToViewPos(coord, depth);
    vec3 dX = dFdx(P);
    vec3 dY = dFdy(P);

    return normalize(cross(dX, dY));
}

vec3 reconstructNormal(vec2 coord) {
	const vec2 res = vec2(viewWidth, viewHeight);
	const vec2 oneOverRes = 1.0/res;

	const vec4 depths = textureGather(depthtex0, floor(coord*res)*oneOverRes);
    const vec3 normal0 = reconstructNormal(coord + vec2(0, 1.0/viewHeight), depths.x);
	const vec3 normal1 = reconstructNormal(coord + vec2(1.0/viewWidth, 1.0/viewHeight), depths.y);
	const vec3 normal2 = reconstructNormal(coord + vec2(1.0/viewWidth, 0), depths.z);
	const vec3 normal3 = reconstructNormal(coord, depths.w);

    return (normal0 + normal1 + normal2 + normal3)*0.25;
}