// PascalCase

#ifdef INCLUDE_SETTINGS

#ifndef settings_glsl
#define settings_glsl
#include "/includes/shared/shared.glsl"

layout(std140, binding = 0) uniform settings {
    float Rain;
    float Wetness;

    /// Intermediate Uniforms, not used in actual code only calculation for other uniforms ///
    vec4 LightSunrise;
    vec4 LightMorning;
    vec4 LightNoon;
    vec4 LightAfternoon;
    vec4 LightSunset;
    vec4 LightNightStart;
    vec4 LightMidnight;
    vec4 LightNightEnd;
    vec4 LightRain;

    vec4 AmbientSunrise;
    vec4 AmbientMorning;
    vec4 AmbientNoon;
    vec4 AmbientAfternoon;
    vec4 AmbientSunset;
    vec4 AmbientNightStart;
    vec4 AmbientMidnight;
    vec4 AmbientNightEnd;
    vec4 AmbientRain;
    ////////////////////////

    int ShadowCascadeCount;
    int ShadowSamples;
    int ShadowFilter;
    float ShadowDistort;
    float ShadowSoftness;
    float ShadowBias;
    float ShadowThreshold;

    int ShadingPixelization;
    int ShadowPixelization;

    int PBR;
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

    //// Sunrays
    float SunraysStrength;
    float SunraysSpread;
    float SunraysOriginSize;
    int SunraysSamples;
    float SunraysFakeSamples;
};

#define STAR_INTENSITY_MIN 0.08
#define STAR_INTENSITY_MAX 1
const vec3 starColor = vec3(0.9412, 0.9333, 0.898);
const uint cellSize = 10; 
const float starRadius = 1;
const float padding = 0.5;
#define STAR_EXPOSURE_THING 50 

#define BASE_LUX 7000
#define EMISSION_LUX 15000
const vec3 localLightColor = vec3(0.96, 0.85, 0.8)*EMISSION_LUX;

const vec4 gbuffer0Default = vec4(0.2, 0.03, 0.7, 0); // spec
const vec4 gbuffer1Default = vec4(-1, -1, 1, 0.25); // norm

#endif

#endif