#if defined DISTANT_HORIZONS && !defined DH_FADE_START
#include "/common/shader.glsl"

#define DH_FADE_START 0.85 // [0.5 0.6 0.7 0.8 0.85 0.9]
#define DH_FADE_END 1 // [0.5 0.6 0.7 0.7 0.8 0.9 1]
#define DH_FADE_DITHER 4 // [Off 2 4 8] {Off Dither2 Dither4 Dither8}

#ifdef IRIS_FEATURE_CUSTOM_IMAGES
    // Blending requires images
    #define DH_FADE_BLENDING 2 // [Off 1 2] {Off Dither Blend}
#else
    #define DH_FADE_BLENDING 1 // [Off 1] {Off Dither}
#endif

#endif