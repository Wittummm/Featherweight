#ifndef metadata_glsl
#define metadata_glsl

layout(std430, binding = 0) buffer _metadata {
    vec3 waterColor;
    uint waterCount;

    vec3 stellarViewMoonDir;
    vec3 _stellarViewMoonDirMax;
};

#endif