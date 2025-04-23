// Required Uniforms: shadowtex0(HW)
float sampleShadowMap(vec2 coord) {
    return texture(shadowtex0, coord).r;
}

float sampleShadowMap(vec3 coord) {
    return texture(shadowtex0HW, coord);
}
#include "/lib/shadow/_shadow.glsl"