#include "/includes/func/dither/dither4.glsl"
#define dither8(a)   (dither4 (.5 *(a)) * .25 + dither2(a))