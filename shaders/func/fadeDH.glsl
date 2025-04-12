#ifdef DISTANT_HORIZONS
#include "/settings/dh_main.glsl"
#include "/func/dither/dither8.glsl"

#if DH_FADE_QUALITY == 10
    #define dither dither2
#elif DH_FADE_QUALITY == 11
    #define dither dither4
#elif DH_FADE_QUALITY == 11
    #define dither dither8
#endif

bool fadeDH(float distToPlayer, float far) {
    #if defined DISTANT_HORIZONS && DH_FADE_QUALITY != Off

        #ifdef DISTANT_HORIZONS_SHADER 
            // TODOMAYBE: Things like foliage may flicker or have firefly-like behavior from the dithering
            // we could utilize `dhMaterialId` to exclude foliage but currently it doesnt work on 1.21.4
            const float fadeOut = smoothstep(far, DH_FADE_START*far, distToPlayer + far*(1-DH_FADE_START)*1.15);
        #else
            const float fadeOut = smoothstep(DH_FADE_START*far, far, distToPlayer);
        #endif
        
        // Creates a TON of branching, not ideal for performance
        if (fadeOut >= 0.99 || dither(gl_FragCoord.xy) + 0.0001 <= fadeOut) {
            return true;
        } 
    #endif
    return false;
}

#endif