#include "/settings/sky.glsl"

#if STARS == 1
#include "/func/atmosphere/calcStars/calcStarsLow.glsl"
#elif STARS == 2
#include "/func/atmosphere/calcStars/calcStarsMedium.glsl"
#endif
