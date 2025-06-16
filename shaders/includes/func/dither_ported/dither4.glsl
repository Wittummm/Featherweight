#include "/includes/func/dither/dither2.glsl"
#define dither4(a)   (dither2 (.5 *(a)) * .25 + dither2(a))