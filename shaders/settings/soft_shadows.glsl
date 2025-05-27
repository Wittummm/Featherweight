#include "/settings/shadows.glsl"

#ifndef SHADOW_SOFTNESS
#if SHADOW_FILTER > Linear


#define SHADOW_SAMPLES 3 // [2 3 5 9 10 12 16 20 24 28 34 40 48 56 64]
#define SHADOW_SOFTNESS 1 // [0.25 0.5 0.75 1 1.25 1.5 2 2.5 3 3.5 4 4.5 5 6 7 8 9 10]

#define SHADOW_SOFTNESS_FADE_OUT_STRENGTH 4 // [0 0.05 0.15 0.3 1.5 3 4 5]
#define SHADOW_SOFTNESS_FADE_OUT_START_DISPLAY 0.13 // [0.08 0.13 0.17 0.2 0.25 0.3 0.4 0.5 0.6 0.7 0.8]

#if SHADOW_FADE_OUT == Circle
    const float SHADOW_SOFTNESS_FADE_OUT_START = SHADOW_SOFTNESS_FADE_OUT_START_DISPLAY * CircleCompensation;
#else
    const float SHADOW_SOFTNESS_FADE_OUT_START = SHADOW_SOFTNESS_FADE_OUT_START_DISPLAY;
#endif

#if SHADOW_FILTER == FixedSamplePCSS || SHADOW_FILTER == VariableSamplePCSS
    #define MAX_SOFTNESS_DISPLAY 26 // [10 11 13 15 17 20 26 32 38 46 55 64 70]
    #define MIN_SOFTNESS_DISPLAY 1 // [0 1 2 3 4 5 6 7 8 9 10]
    #define PCSS_SEARCH_SAMPLES 4 // [2 3 4 5 6 7 8 10 12 15 17 20 23 26 30 35 40] // {Sample more to get better transition between near-far blockers}
    #define PCSS_SEARCH_OFFSET_BIAS 1 // [0.5 0.6 0.7 0.8 0.9 1 1.1 1.25 1.5]
    const float LIGHT_SIZE = SHADOW_SOFTNESS/20.0;
    const float MAX_SOFTNESS = MAX_SOFTNESS_DISPLAY/1000.0; // {Being too soft can cause artifacts/quality degradation}
    const float MIN_SOFTNESS = MIN_SOFTNESS_DISPLAY/1000.0;

    #if SHADOW_FILTER == VariableSamplePCSS
        #undef SHADOW_SAMPLES
        
        #define PCSS_SAMPLES_MULT 1 // [0.2 0.4 0.6 0.8 1 1.25 1.5 1.75 2 2.33 2.66 3]
        #define PCSS_MIN_SAMPLES 2 // [1 2 3 4 5 6 7 8 9 10 11 12]
        #define PCSS_MAX_SAMPLES 40 // [6 8 10 12 14 16 18 20 25 30 35 40 45 50 55 60]
    #endif
#endif

#define PRESET_PCF_PATTERNS // {Reduces code amount, harcoded patterns is recommended for low sample counts}
// DEBUG
#define DEBUG_SHOW_SHADOW_SOFTNESS_FADE Off // [Off On]

#endif
#endif