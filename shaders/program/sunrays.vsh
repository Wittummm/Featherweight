#version 460 core
#include "/settings/lighting.glsl"

// EXTRA_SETTINGS
#define SUNRAYS_SUNRISE vec4(0.984, 0.702, 0.275, 0.85)
#define SUNRAYS_MORNING vec4(0.941, 0.855, 0.588, 1)
#define SUNRAYS_NOON vec4(0.941, 0.898, 0.765, 1.1)
#define SUNRAYS_AFTERNOON vec4(0.9625, 0.807, 0.4157, 1)
#define SUNRAYS_SUNSET vec4(0.984, 0.6235, 0.2627, 0.85)
#define SUNRAYS_NIGHT_START vec4(0.1451, 0.14513, 0.23137, 0.8)
#define SUNRAYS_MIDNIGHT vec4(0.0588, 0.04706, 0.1412, 0.75)
#define SUNRAYS_NIGHT_END vec4(0, 0, 0.035, 0.8)
#define SUNRAYS_RAIN vec4(0.306, 0.408, 0.506, 0.8)
// EXTRA-SETTINGS-END
const float MAP_NIGHT_END = 1.0 / (SUNRISE1 - NIGHT_END);
const float MAP_MIDNIGHT = 1.0 / (NIGHT_END - MIDNIGHT);
const float MAP_NIGHT_START = 1.0 / (MIDNIGHT - NIGHT_START);
const float MAP_SUNSET = 1.0 / (NIGHT_START - SUNSET);
const float MAP_AFTERNOON = 1.0 / (SUNSET - AFTERNOON);
const float MAP_NOON = 1.0 / (AFTERNOON - NOON);
const float MAP_MORNING = 1.0 / (NOON - MORNING);
const float MAP_SUNRISE = 1.0 / (MORNING - SUNRISE0);
//

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform mat4 gbufferProjection;
uniform vec3 shadowLightPosition;
uniform float sunAngle;

in vec2 vaUV0;
in vec3 vaPosition;

out vec2 texCoord;
out vec3 vertPosition;
out vec2 lightPos;
out vec4 sunraysColor;

void main() {
	const vec4 viewPos = modelViewMatrix * vec4(vaPosition, 1);
	const vec4 clipPos = projectionMatrix * viewPos;

	const vec4 lightClip = gbufferProjection * vec4(shadowLightPosition, 1);
    const vec3 lightNdc = lightClip.xyz / lightClip.w;
    lightPos = ((lightNdc + 1.0)*0.5).xy; // Screen-Space

	texCoord = vaUV0;
	gl_Position = clipPos;
	vertPosition = vaPosition;

	if (sunAngle >= NIGHT_END) {
        sunraysColor =  mix(SUNRAYS_NIGHT_END, SUNRAYS_SUNRISE, (sunAngle - NIGHT_END) * MAP_NIGHT_END);
    } else if (sunAngle >= MIDNIGHT) {
        sunraysColor =  mix(SUNRAYS_MIDNIGHT, SUNRAYS_NIGHT_END, (sunAngle - MIDNIGHT) * MAP_MIDNIGHT);
    } else if (sunAngle >= NIGHT_START) {
        sunraysColor =  mix(SUNRAYS_NIGHT_START, SUNRAYS_MIDNIGHT, (sunAngle - NIGHT_START) * MAP_NIGHT_START);
    } else if (sunAngle >= SUNSET) {
        sunraysColor =  mix(SUNRAYS_SUNSET, SUNRAYS_NIGHT_START, (sunAngle - SUNSET) * MAP_SUNSET);
    } else if (sunAngle >= AFTERNOON) {
        sunraysColor =  mix(SUNRAYS_AFTERNOON, SUNRAYS_SUNSET, (sunAngle - AFTERNOON) * MAP_AFTERNOON);
    } else if (sunAngle >= NOON) {
        sunraysColor =  mix(SUNRAYS_NOON, SUNRAYS_AFTERNOON, (sunAngle - NOON) * MAP_NOON);
    } else if (sunAngle >= MORNING) {
        sunraysColor =  mix(SUNRAYS_MORNING, SUNRAYS_NOON, (sunAngle - MORNING) * MAP_MORNING);
    } else if (sunAngle >= SUNRISE0) {
        sunraysColor =  mix(SUNRAYS_SUNRISE, SUNRAYS_MORNING, (sunAngle - SUNRISE0) * MAP_SUNRISE);
    }
}