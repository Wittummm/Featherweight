#ifndef WATER_WAVES

#include "/common/shader.glsl"

#define WATER_FOG_END 0.6

#define WATER_WAVES Off // [Off On]

const float waterConcentration = 0.5;
const vec3 waterAbsorption = vec3(0.025, 0.03, 0.03)*0.3;

const float waterScattering = 0.7;
const float waterScattering2 = waterScattering*waterScattering;

#endif