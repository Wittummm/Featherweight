// PascalCase
#ifdef INCLUDE_METADATA

#ifndef metadata_glsl
#define metadata_glsl

layout(std430, binding = 0) buffer metadata {
    uint CameraBlockId;
    float AverageLuminance;

    vec3 AmbientColor;
    vec4 LightColor;
};
#endif

#endif