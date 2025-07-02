// PascalCase
#ifndef settings_glsl
#define settings_glsl

layout(std430, binding = 0) buffer settings {
    vec3 AmbientColor;
    vec4 LightColor;
    float Rain;
    float Wetness;

    // uniforms
    vec4 LightSunrise;
    vec4 LightMorning;
    vec4 LightNoon;
    vec4 LightAfternoon;
    vec4 LightSunset;
    vec4 LightNightStart;
    vec4 LightMidnight;
    vec4 LightNightEnd;
    vec4 LightRain;

    int ShadowCascadesCount;
    int ShadowSamples;
    int ShadowFilter;
    float ShadowDistort;
    float ShadowSoftness;
    float ShadowBias;

    int ShadingPixelization;
    int ShadowPixelization;

    int Specular;
    float NormalStrength;
};
#endif