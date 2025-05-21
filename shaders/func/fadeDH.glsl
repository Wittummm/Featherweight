#ifdef DISTANT_HORIZONS
#include "/settings/dh_main.glsl"
#include "/func/dither/dither8.glsl"

#if DH_FADE_DITHER == 2
    #define dither dither2
#elif DH_FADE_DITHER == 4
    #define dither dither4
#elif DH_FADE_DITHER == 8
    #define dither dither8
#endif

bool fadeDH(float fadeOut) {
    #if defined DISTANT_HORIZONS && DH_FADE_DITHER != Off
        // Creates a TON of branching, not ideal for performance
        if (fadeOut >= 0.999 || dither(gl_FragCoord.xy) + 0.001 <= fadeOut) {
            return true;
        } 
    #endif
    return false;
}

#endif