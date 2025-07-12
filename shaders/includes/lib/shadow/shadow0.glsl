// Required Uniforms: shadowMapFiltered/shadowMap
#ifdef ShadowsEnabled
#include "/includes/shared/settings.glsl"

ivec2 shadowMapSize = textureSize(shadowMap, 0).xy;

float sampleShadowMapNearest(vec3 coord, int cascade) {
    return texture(shadowMap, vec3(coord.xy, cascade)).r;
}
float sampleShadowMap(vec3 coord, int cascade) {
    float t = texture(shadowMapFiltered, vec4(coord.xy, cascade, coord.z)).r;
    return t*t; // t*t looks better than t
}

#endif
#include "/includes/lib/shadow/_shadow.glsl"
// need one line to include