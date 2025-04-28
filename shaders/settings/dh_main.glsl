#ifdef DISTANT_HORIZONS
#ifndef DH_FADE_START
#include "/common/shader.glsl"

#define DH_FADE_START 0.8 // [0.5 0.6 0.7 0.7 0.8 0.9]
#define DH_FADE_END 1 // [0.5 0.6 0.7 0.7 0.8 0.9 1]
#define DH_FADE_QUALITY 1 // [Off 10 11 12 1] {Off Dither2 Dither4 Dither8 Blend}

#endif
#endif