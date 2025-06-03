#ifndef LIGHT_BRIGHTNESS
////////////////////////////
#include "/common/shader.glsl"

#define AMBIENT_R 90 // [0 16 32 48 64 80 96 112 128 144 160 176 192 208 224 240 255]
#define AMBIENT_G 90 // [0 16 32 48 64 80 96 112 128 144 160 176 192 208 224 240 255]
#define AMBIENT_B 100 // [0 16 32 48 64 80 96 112 128 144 160 176 192 208 224 240 255]

#define SHADING On // [Off On] {EXPERIMENTAL! NOT RECOMMENDED TO TURN OFF}
const float sunPathRotation = 20; // [-55 -50 -45 -40 -35 -30 -25 -20 -15 -10 0 10 15 20 25 30 35 40 45 50 55]

#define LIGHT_BRIGHTNESS 0.7 // [0.5 0.6 0.7 0.8 0.9 1 1.1 1.2 1.3 1.4 1.5 1.75 2]

// Handle Values
const vec3 AMBIENT = vec3(AMBIENT_R, AMBIENT_G, AMBIENT_B)/255.0;
#undef AMBIENT_R
#undef AMBIENT_G
#undef AMBIENT_B
////////////////////////////
#endif