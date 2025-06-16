// PascalCase
#ifndef settings_glsl
#define settings_glsl

layout(std430, binding = 0) buffer settings {
    vec3 AmbientColor;
    vec4 LightColor;
    int ShadowSamples;
    int ShadowFilter;
    bool PresetPatternsPCF;
    float ShadowDistort;
    float Pixelization;
    int Specular;
};
#endif