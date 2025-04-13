#ifndef RAIN_INTENSITY

#define RAIN_INTENSITY 0.75 // [0.25 0.5 0.75 1 1.25 1.5 1.75 2]

// Puddles
#define PUDDLES On // [Off On]
#define PUDDLE_THICKNESS 2 // [1.5 1.7 1.8 1.9 2 2.1 2.25 2.5 3] {Arbitrary, not physically based at all}
#define PUDDLE_SIZE 1 // [0 0.4 0.75 1 1.25 1.5 2 2.5 3] {Size of each individual puddle}

// Extra Customization
#define PUDDLE_HORIZONTAL_SCALE 0.2 // [0.1 0.15 0.2 0.25 0.3 0.35 0.4]
#define PUDDLE_GLOSS 0.9 // [0.8 0.82 0.84 0.86 0.88 0.9 0.92 0.94 0.96]
#define PUDDLE_ROUGHNESS 1.0 - PUDDLE_GLOSS
#define PUDDLE_R 200 // [0 16 32 48 64 80 96 112 128 144 160 176 192 208 224 240 255]
#define PUDDLE_G 205 // [0 16 32 48 64 80 96 112 128 144 160 176 192 208 224 240 255]
#define PUDDLE_B 213 // [0 16 32 48 64 80 96 112 128 144 160 176 192 208 224 240 255]
const vec3 PUDDLE_COLOR = vec3(PUDDLE_R, PUDDLE_G, PUDDLE_B)*0.00392156862745098;
#undef PUDDLE_R
#undef PUDDLE_G
#undef PUDDLE_B

// Advanced
#define PUDDLE_VERTICAL_SCALE 0.14 // [0.1 0.12 0.14 0.16 0.18]
#define PUDDLE_DISTORT_STRENGTH 0.3 // [0.1 0.2 0.3 0.4]
#define PUDDLE_DISTORT_SCALE 3 // [2 3 4 5 6 7]
#define PUDDLE_EXPOSURE_MIN 0.7 // [0.4 0.5 0.6 0.7 0.75 0.8 0.85] // Bottom edge of fading
#define PUDDLE_EXPOSURE_MAX 0.91 // [0.75 0.8 0.85 0.88 0.91 0.93] // Top Edge of fading
#define PUDDLE_WATER_F0 0.2 // [0.02 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9] // {0.02 is the realistic value}

#endif