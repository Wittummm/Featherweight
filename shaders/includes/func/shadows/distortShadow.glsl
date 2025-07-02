#ifndef distortShadow_glsl
#define distortShadow_glsl

#include "/includes/shared/settings.glsl"

// CREDIT: @geforcelegend https://discord.com/channels/237199950235041794/525510804494221312/1379718853872848896, https://www.desmos.com/calculator/nvofvyom4h
float c = exp2(ShadowDistort) - 1.0;
float d0 = log2(c+1.0);

vec3 distortShadow(vec3 shadowClipPos){
    if (ShadowDistort <= 0) return shadowClipPos;

    return (sign(shadowClipPos)*log2(c*abs(shadowClipPos) + 1.0))/d0;
}

vec3 distortShadow(vec3 shadowClipPos, out float distortFactor){
    if (ShadowDistort <= 0) return shadowClipPos;

    vec3 absShadowClipPos = abs(shadowClipPos);
    float d = absShadowClipPos.x + absShadowClipPos.y + absShadowClipPos.z;
    distortFactor = (d0*(c*d + 1.0))/c;
    
    return (sign(shadowClipPos)*log2(c*absShadowClipPos + 1.0))/d0;
}

#endif