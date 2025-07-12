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
    if (AutoExposure == 0) AverageLuminance = BASE_LUX;
    AmbientColor.rgb = vec3(0.13, 0.13, 0.18);

    // TODOEVENTUALLY: NOTE: As currently WorldState on JS side does not have time, we must this on the gpu. -> If it is possible to do on cpu, then do so.
    float sunAngle = ap.celestial.angle;
    vec4 lightColor = vec4(1,0,1,0);
    if (sunAngle >= NIGHT_END) {
        float alpha = mappedLerp(NIGHT_END, SUNRISE1);
        LightColor = mix(LightNightEnd, LightSunrise, alpha);
        AmbientColor = mix(AmbientNightEnd, AmbientSunrise, alpha);
    } else if (sunAngle >= MIDNIGHT) {
        float alpha = mappedLerp(MIDNIGHT, NIGHT_END);
        LightColor = mix(LightMidnight, LightNightEnd, alpha);
        AmbientColor = mix(AmbientMidnight, AmbientNightEnd, alpha);        
    } else if (sunAngle >= NIGHT_START) {
        float alpha = mappedLerp(NIGHT_START, MIDNIGHT);
        LightColor = mix(LightNightStart, LightMidnight, alpha);
        AmbientColor = mix(AmbientNightStart, AmbientMidnight, alpha);        
    } else if (sunAngle >= SUNSET) {
        float alpha = mappedLerp(SUNSET, NIGHT_START);
        LightColor = mix(LightSunset, LightNightStart, alpha);
        AmbientColor = mix(AmbientSunset, AmbientNightStart, alpha);        
    } else if (sunAngle >= AFTERNOON) {
        float alpha = mappedLerp(AFTERNOON, SUNSET);
        LightColor = mix(LightAfternoon, LightSunset, alpha);
        AmbientColor = mix(AmbientAfternoon, AmbientSunset, alpha);        
    } else if (sunAngle >= NOON) {
        float alpha = mappedLerp(NOON, AFTERNOON);
        LightColor = mix(LightNoon, LightAfternoon, alpha);
        AmbientColor = mix(AmbientNoon, AmbientAfternoon, alpha);        
    } else if (sunAngle >= MORNING) {
        float alpha = mappedLerp(MORNING, NOON);
        LightColor = mix(LightMorning, LightNoon, alpha);
        AmbientColor = mix(AmbientMorning, AmbientNoon, alpha);        
    } else if (sunAngle >= SUNRISE0) {
        float alpha = mappedLerp(SUNRISE0, MORNING);
        LightColor = mix(LightSunrise, LightMorning, alpha);
        AmbientColor = mix(AmbientSunrise, AmbientMorning, alpha);        
    }

    LightColor = mix(LightColor, LightRain, ap.world.rain);
    LightColor.rgb *= LightColor.a;
    AmbientColor.rgb *= AmbientColor.a;

    CameraBlockId = iris_getBlockAtPos(ap.camera.blockPos).x;
}