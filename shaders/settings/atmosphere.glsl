#include "/common/shader.glsl"

#define FOG_DETAIL PerVertex // [PerVertex PerPixel]
vec3 ATMOSPHERE_COLOR = vec3(176, 204, 255)*0.00392156862745098;

#define FOG_DENSITY 1 // [0.75 1 1.25 1.5 1.75 2 2.25 2.5 3]
#define FOG_START 0.3 // [0 0.05 0.1 0.15 0.2 0.25 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1]
#define FOG_END 0.95 // [0 0.1 0.2 0.3 0.4 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1]

#define AMBIENT_REFLECTION_QUALITY 2 // [Off 1 2 3 4 6 8 10 12 15 20 25 30]

//////////////////

// NOTE: we could optimize this by computing it once, then passing it but that would need a metadata framebuffer to be ideal
// uniform vec3 fogCoefficient;
const vec3 fogCoefficient = vec3(5.5e-6, 13.0e-6, 22.4e-6); // TODONOW: add fog density
#define getFogFactor(dist, renderDist) min( ( 1.0-exp(-fogCoefficient*dist) ) / (1.0-exp(-fogCoefficient*renderDist)), 1)