#version 460 core
layout (local_size_x = 1) in;

#include "/includes/shared/shared.glsl"

#define SUNRISE0 0
#define SUNRISE1 1
#define MORNING 0.125
#define NOON 0.25
#define AFTERNOON 0.375
#define SUNSET 0.5
#define NIGHT_START 0.55
#define MIDNIGHT 0.75
#define NIGHT_END 0.95

#define mappedLerp(minimum, maximum) ((ap.celestial.angle - minimum) / (maximum - minimum))

void main() {
    if (AutoExposure == 0) AverageLuminance = 0.2;
    AmbientColor = vec3(0.13, 0.13, 0.18);

    // TODOEVENTUALLY: NOTE: As currently WorldState on JS side does not have time, we must this on the gpu. -> If it is possible to do on cpu, then do so.
    float sunAngle = ap.celestial.angle;
    vec4 lightColor = vec4(1,0,1,0);
    if (sunAngle >= NIGHT_END) {
        LightColor = mix(LightNightEnd, LightSunrise, mappedLerp(NIGHT_END, SUNRISE1));
    } else if (sunAngle >= MIDNIGHT) {
        LightColor = mix(LightMidnight, LightNightEnd, mappedLerp(MIDNIGHT, NIGHT_END));
    } else if (sunAngle >= NIGHT_START) {
        LightColor = mix(LightNightStart, LightMidnight, mappedLerp(NIGHT_START, MIDNIGHT));
    } else if (sunAngle >= SUNSET) {
        LightColor = mix(LightSunset, LightNightStart, mappedLerp(SUNSET, NIGHT_START));
    } else if (sunAngle >= AFTERNOON) {
        LightColor = mix(LightAfternoon, LightSunset, mappedLerp(AFTERNOON, SUNSET));
    } else if (sunAngle >= NOON) {
        LightColor = mix(LightNoon, LightAfternoon, mappedLerp(NOON, AFTERNOON));
    } else if (sunAngle >= MORNING) {
        LightColor = mix(LightMorning, LightNoon, mappedLerp(MORNING, NOON));
    } else if (sunAngle >= SUNRISE0) {
        LightColor = mix(LightSunrise, LightMorning, mappedLerp(SUNRISE0, MORNING));
    }

    LightColor = mix(LightColor, LightRain, ap.world.rain);

    iris_getBlockAtPos(ap.camera.blockPos);
}