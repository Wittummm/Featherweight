// Required Uniforms: shadowMapFiltered/shadowMap
#include "/includes/shared/settings.glsl"

ivec2 shadowMapSize = textureSize(shadowMap, 0).xy;

float sampleShadowMapNearest(vec3 coord, int cascade) {
    return texture(shadowMap, vec3(coord.xy, cascade)).r;
}
float sampleShadowMap(vec3 coord, int cascade) {
    return texture(shadowMapFiltered, vec4(coord.xy, cascade, coord.z)).r;
}

#include "/includes/lib/shadow/_shadow.glsl"
float e = 1;