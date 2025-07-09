// PascalCase
#ifdef INCLUDE_SETTINGS

#ifndef settings_glsl
#define settings_glsl
#include "/includes/shared/metadata.glsl"

layout(std140, binding = 0) uniform settings {
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
    float ShadowThreshold;

    int ShadingPixelization;
    int ShadowPixelization;

    int Specular;
    float NormalStrength;

    /// Camera related
    int AutoExposure;
    float ExposureMult;
    float ExposureSpeed;
    int Tonemap;
    bool CompareTonemaps;
    ivec4 TonemapIndices;

    /// Atmospheric
    int Sky;
    int Stars;
    float StarAmount;
    bool DisableMoonHalo;
    bool IsolateCelestials;
};

#define STAR_INTENSITY_MIN 0.08
#define STAR_INTENSITY_MAX 0.98
const vec3 starColor = vec3(0.9412, 0.9333, 0.898);
const uint cellSize = 10; 
const float starRadius = 1;
const float padding = 0.5;
#define STAR_EXPOSURE_THING 50 // CONFIGTODO: extra settings

#endif

#endif