#include "/includes/shared/settings.glsl"

// General Pixelize function. Each feature can have their own Override
#define _pixelize(pos, size, rcpSize) floor(pos*size + 0.001)*rcpSize

#define pixelize(pos) _pixelize(pos, Pixelization, 1.0/Pixelization)