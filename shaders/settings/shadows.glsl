#ifndef SHADOW_NEAR_DISTORT
////////////////////
#include "/common/shader.glsl"

#define Circle -200
#define Box -201
const float CircleCompensation = 1.4;

// Settings
const int shadowMapResolution = 512; // [128 192 256 420 512 640 768 896 1024 1280 1536 1792 2048 2560 3072 4096]
const float shadowDistance = 90;  // [10 25 45 60 70 80 90 110 130 150 180 200 230 260 300 350 400 450 500 550 600]

#define SHADOWS 1 // [0 1]

#define SHADOW_NEAR_DISTORT 0.8 // [0 0.05 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.85 0.9 0.95 0.99]
const float SHADOW_NEAR_DISTORT_INVERTED = 1 - SHADOW_NEAR_DISTORT;

#define SHADOW_FADE_OUT Box // [Off Circle Box]
#define SHADOW_FADE_OUT_STRENGTH 7 // [0 1 2 3 4 5 6 7 8 9 10]
#define SHADOW_FADE_OUT_START_DISPLAY 0.9 // [0.5 0.6 0.7 0.75 0.8 0.85 0.9 0.95]

#if SHADOW_FADE_OUT == Circle
    const float SHADOW_FADE_OUT_START = SHADOW_FADE_OUT_START_DISPLAY * CircleCompensation;
#else
    const float SHADOW_FADE_OUT_START = SHADOW_FADE_OUT_START_DISPLAY;
#endif

#define Nearest Lowest
#define Linear Low
#define ESM Normal
#define PCF Medium
#define FixedSamplePCSS High
#define VariableSamplePCSS Ultra
#define SHADOW_FILTER Linear // [Nearest Linear ESM PCF VariableSamplePCSS FixedSamplePCSS]

// Advanced Settings
const float shadowIntervalSize = 3; // [0.1 0.5 1 2 3 4 6 8 10] // Shadow Snap Grid Size
#define Z_BIAS_DISPLAY 5 // [0 1 2 3 4 5 6 7 8 9 10 11 12 14 15 17 20]
const float Z_BIAS = Z_BIAS_DISPLAY/50000.0;
#define DISTORT_USING_LIGHT_ANGLE // (Small Performance Impact)
#define SHADOW_MIP_MAP_BIAS -1.25 // [0 -0.25 -0.5 -1 -1.25 -1.5 -1.75 -2 -3] (No Performance Impact) {How sharp cutout shadows are, extreme values may cause shadow flickering}

// Constants
uniform sampler2D shadowtex0;

uniform sampler2DShadow shadowtex0HW;
const bool shadowHardwareFiltering = true;

#if SHADOW_FILTER==Nearest
const bool shadowtex0Nearest = true;
#endif
// DEBUG

////////////////////
//////////////////
#endif