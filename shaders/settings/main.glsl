#include "/common/shader.glsl"
#ifndef PIXELIZATION

#define MIP_MAP_BIAS -0.25 // [0 -0.25 -0.4 -0.5 -0.6 -0.7 -0.8 -0.9 -1.0 -1.25 -1.5 -1.75 -2]
#define PIXELIZATION 16 // [Off 8 16 32 64 128 256]
const float pixelizationTexelSize = 1.0/PIXELIZATION;

// General Pixelize function. Each feature can have their on Override
#define _pixelize(pos, size, rcpSize) floor(pos*size + 0.001)*rcpSize

#define pixelize(pos) _pixelize(pos, PIXELIZATION, pixelizationTexelSize)

#endif