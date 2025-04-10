#ifndef SHADOWS
#include "/settings/shadows.glsl"
#endif
#include "/func/getShade.glsl"

const float minDistort = 0.05;
vec3 distortShadow(vec3 shadowClipPos){
    vec2 distortion = max(SHADOW_NEAR_DISTORT*abs(shadowClipPos.xy), minDistort) + SHADOW_NEAR_DISTORT_INVERTED;
    shadowClipPos.xy /= distortion; // allocate more resolution to near player
    #if DISTORT_USING_LIGHT_ANGLE==On
    shadowClipPos.x /= min(lightAngle()+1, 1); // allocate more resolution to the height so pixels arent too tall
    #endif

    return shadowClipPos;
}

float distort(float num) {
    return num / (SHADOW_NEAR_DISTORT*num + SHADOW_NEAR_DISTORT_INVERTED);
}