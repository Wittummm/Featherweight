#define SSR_RESOUTION 4 // [1 2 3 4 5 6 7 8 9 10] {4}
#define SSR_STEPS 24 // [8 12 16 20 24 28 32 40 45 50 55 60 70 80] {16}
#define SSR_REFINE_STEPS 8 // [3 5 7 8 10 14 18 24] {5}
const float ssrDistance = 30; // [20 30 40 50 60 75 90 110]
#define SSR_NORMAL_STRENGTH 40 // [10 20 30 40 50 60 70 80 90 100]
float ssrNormalStrength = SSR_NORMAL_STRENGTH/100.0;

// Advanced Settings
#define SSR_LINEAR_TURNOFF_THRESHOLD 8 // [1 2 3 4 5 6 7 8 9 10] {Linear sampling improves clarity by "faking" resolution but may result in artifacts. Recommended to disable for near native resolution SSR.}

// EXTRA_SETTINGS | You can edit values below, but they are finicky and somewhat technical
const float maxThickness = 0.003;
const float refineMaxThickness = maxThickness/SSR_REFINE_STEPS; 

#define SHARPNESS 10 // Sharpness of the naive edge retaining algo of linear filtering
//
