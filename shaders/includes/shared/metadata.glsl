// PascalCase
#ifdef INCLUDE_METADATA

#ifndef metadata_glsl
#define metadata_glsl

layout(std430, binding = 0) buffer metadata {
    uint CameraBlockId;

    float AverageLuminance;

    vec4 AmbientColor;
    vec4 LightColor;
    vec4 SunraysColor;
};

#endif

#endif