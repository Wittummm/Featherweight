#ifndef AMBIENT_STRENGTH
////////////////////////////
#include "/common/shader.glsl"

#define AMBIENT_R 50 // [0 16 32 48 64 80 96 112 128 144 160 176 192 208 224 240 255]
#define AMBIENT_G 50 // [0 16 32 48 64 80 96 112 128 144 160 176 192 208 224 240 255]
#define AMBIENT_B 56 // [0 16 32 48 64 80 96 112 128 144 160 176 192 208 224 240 255]
#define AMBIENT_STRENGTH 1 // [0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1]

#define SHADING On // [Off On] {EXPERIMENTAL! NOT RECOMMENDED TO TURN OFF}
const float sunPathRotation = 20; // [-55 -50 -45 -40 -35 -30 -25 -20 -15 -10 0 10 15 20 25 30 35 40 45 50 55]

// #define LIGHT_BRIGHTNESS 1 // TODOIMPLEMENTLATER
// Day Cycle, EXTRA_SETTINGS
#define SUNRISE0 0
#define SUNRISE1 1
#define MORNING 0.125
#define NOON 0.25
#define AFTERNOON 0.375
#define SUNSET 0.5
#define NIGHT_START 0.55
#define MIDNIGHT 0.75
#define NIGHT_END 0.95

// Handle Values
const vec3 AMBIENT = vec3(AMBIENT_R, AMBIENT_G, AMBIENT_B)/255.0;
#undef AMBIENT_R
#undef AMBIENT_G
#undef AMBIENT_B
////////////////////////////
#endif