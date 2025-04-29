#ifndef encodeNormals_glsl
#define encodeNormals_glsl

vec3 reconstructZ(vec2 normals) {
    return vec3(normals, sqrt(1.0 - clamp(dot(normals, normals), 0.001, 1.0)));
}

#ifdef YES_NORMALS_WRITE

#ifndef DISTANT_HORIZONS_SHADER // DH has no normal matrix
mat3 tbnNormalTangentPlayerSpace(vec3 vertNormal, vec4 tangent) {
    mat3 tbnMatrix;
    tbnMatrix[0] = normalize(mat3(gbufferModelViewInverse) * normalMatrix * tangent.xyz);
    tbnMatrix[2] = normalize(mat3(gbufferModelViewInverse) * normalMatrix * vertNormal);
    tbnMatrix[1] = normalize(cross(tbnMatrix[0], tbnMatrix[2]) * tangent.w);
    return tbnMatrix;
}
#endif


// Normals
// https://knarkowicz.wordpress.com/2014/04/16/octahedron-normal-vector-encoding/
vec2 octWrap( vec2 v ) {
    vec2 w = 1.0 - abs( v.yx );
    if (v.x < 0.0) w.x = -w.x;
    if (v.y < 0.0) w.y = -w.y;
    return w;
}
vec2 normalsWrite(vec3 n) {
    n = normalize(n + 1e-6);
    n /= ( abs( n.x ) + abs( n.y ) + abs( n.z ) );
    n.xy = n.z > 0.0 ? n.xy : octWrap( n.xy );
    return n.xy * 0.5 + 0.5;
}
#ifndef DISTANT_HORIZONS_SHADER
vec2 normalsWrite(vec3 normal, vec4 tangent, vec3 texNormal) { 
    vec3 newNormal = normalize(tbnNormalTangentPlayerSpace(normal, tangent) * texNormal);
    return normalsWrite(newNormal);
}
#endif

#endif

vec3 normalsRead(vec2 f) {
    f = f * 2.0 - 1.0;
    // https://twitter.com/Stubbesaurus/status/937994790553227264
    vec3 n = vec3( f.x, f.y, 1.0 - abs( f.x ) - abs( f.y ) );
    float t = max( -n.z, 0.0 );
    n.x += n.x >= 0.0 ? -t : t;
    n.y += n.y >= 0.0 ? -t : t;
    return normalize(n);
}

#endif