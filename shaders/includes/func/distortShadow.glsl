#ifndef distortShadow_glsl
#define distortShadow_glsl
#include "/includes/func/misc/getShade.glsl"

#include "/includes/shared/settings.glsl"

const float minDistort = 0.05;
vec3 distortShadow(vec3 shadowClipPos){
    vec2 distortion = max(ShadowDistort*abs(shadowClipPos.xy), minDistort) + (1-ShadowDistort);
    shadowClipPos.xy /= distortion; 

    return shadowClipPos;
}

#endif