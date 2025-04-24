#include "/common/shader.glsl"

#define WATER_WAVES Off // [Off On]

const float waterConcentration = 1;
const vec3 waterAbsorption = vec3(0.025, 0.03, 0.03);

const float waterScattering = 0.7;
// const float waterScatterStrength = 1; // Should just be Light Brightness
// const vec3 waterScatterColor = vec3(0.83, 0.8, 0.8); // Should just be lightColor
const float waterScattering2 = waterScattering*waterScattering;