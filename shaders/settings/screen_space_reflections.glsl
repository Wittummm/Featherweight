#include "/settings/main.glsl"

#define SSR_ENABLED 1 // [0 1]
#define SSR_RESOUTION 5 // [1 2 3 4 5 6 7 8 9 10] {4}
#define SSR_MAX_DISTANCE 90 // [20 30 40 50 60 75 90 120 150 180 220 260 300]
#define SSR_STEPS_PER_BLOCK 0.25 // [0.25 0.5 1 1.5 2 2.5 3] {0.25}
#define SSR_STEPS ceil(SSR_MAX_DISTANCE*SSR_STEPS_PER_BLOCK)
#define SSR_REFINE_STEPS 5 // [3 5 7 8 10 14 18 24] {5}
#define SSR_NORMAL_STRENGTH 60 // [0 10 20 30 40 50 60 70 80 90 100 150] {Sporadic normals can cause more artifacts especially at lower SSR resolutions}
const float ssrNormalStrengthMax = SSR_NORMAL_STRENGTH/100.0;

// Extras
#define SSR_PIXELIZATION -200 // [-400 -300 -200 -100 -50 0 8 16 32 64 128 256] // CODE: sahj1283
const float ssrPixelization = (SSR_PIXELIZATION < 0) ? PIXELIZATION * abs(SSR_PIXELIZATION) * 0.01 : SSR_PIXELIZATION;
const float ssrPixelizationTexelSize = 1.0/ssrPixelization; 
#undef pixelize 
#define pixelize(pos) _pixelize(pos, ssrPixelization, ssrPixelizationTexelSize); 

// Advanced Settings
#define SSR_LINEAR_TURNOFF_THRESHOLD 8 // [1 2 3 4 5 6 7 8 9 10] {Linear sampling improves clarity by "faking" resolution but may result in artifacts. Recommended to disable for near native resolution SSR.}
#define SSR_NORMAL_STRENGTH_MIN 0 // [0 5 10 20 30 40 50 60 70 80 90 100] 
const float ssrNormalStrengthMin = SSR_NORMAL_STRENGTH_MIN/100.0;

// EXTRA_SETTINGS | You can edit values below, but they are finicky and somewhat technical
const float margin = 0.15;
const float maxThickness = (SSR_MAX_DISTANCE/SSR_STEPS_PER_BLOCK)*margin;
const float refineMaxThickness = (maxThickness/SSR_REFINE_STEPS)*margin; 
const float bias = 0.5; // TODOMAYBE: Ideally shouldnt have a constant bias, perhaps weigh based on normals
// Below: 0 - 100%
#define SSR_EDGE_FADE_START_MAX 0.02
#define SSR_EDGE_FADE_END_MAX 0.1
#define SSR_EDGE_FADE_START_MIN 0.0
#define SSR_EDGE_FADE_END_MIN 0.013
#define SSR_BLUR_STRENGTH 0.5
// Technical
#define SHARPNESS 10 // Sharpness of the naive edge retaining algo of linear filtering
// EXTRA-SETTINGS-END
