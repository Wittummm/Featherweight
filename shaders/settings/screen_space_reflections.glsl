// below should be in config
uniform float near;
uniform float far;
#include "/func/misc/linearizeDepth.glsl"
uniform float centerDepthSmooth;

const int steps = 12;
const float maxDist = 40;//mix(5, 50, clamp(linearizeDepth(centerDepthSmooth)/far, 0, 1));
const float maxThickness = 0.009;
const int refineSteps = 5;
const float refineMaxThickness = 0.0001; 
// TODONOW: make above defines(if possible)

// #define SSR_RESOUTION 5 // [5 10 15] // TODONOW: make this actually work