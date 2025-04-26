// Required Uniforms: shadowtex1(HW)
float sampleShadowMap(vec2 coord) {
    return texture(shadowtex1, coord).r;
}

float sampleShadowMap(vec3 coord) {
    return texture(shadowtex1HW, coord);
}
#include "/lib/shadow/_shadow.glsl"