// Required Uniforms: solidShadowMapFiltered

#ifdef ShadowsEnabled
#include "/includes/shared/settings.glsl"

float sampleShadowMap(vec3 coord) {
    return texture(solidShadowMapFiltered, coord);
}
#endif

#include "/includes/lib/shadow/_shadow.glsl"
// need one line to include