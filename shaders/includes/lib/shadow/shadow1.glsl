// Required Uniforms: solidShadowMapFiltered
float sampleShadowMap(vec3 coord) {
    return texture(solidShadowMapFiltered, coord);
}

#include "/includes/lib/shadow/_shadow.glsl"