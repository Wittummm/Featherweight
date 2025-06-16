// Required Uniforms: shadowMapFiltered
float sampleShadowMap(vec3 coord, int cascade) {
    return texture(shadowMapFiltered, vec4(coord.xy, cascade, coord.z));
}

#include "/includes/lib/shadow/_shadow.glsl"
float e = 1;