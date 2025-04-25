#ifndef WATER_WAVES

#include "/common/shader.glsl"

#define WATER_WAVES Off // [Off On]

const float waterConcentration = 1;
const vec3 waterAbsorption = vec3(0.025, 0.03, 0.03);

const float waterScattering = 0.9;
const float waterScattering2 = waterScattering*waterScattering;

#endif