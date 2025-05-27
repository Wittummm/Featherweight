#version 460 core

#include "/lib/metadata.glsl"

layout (local_size_x = 1) in;
const ivec3 workGroups = ivec3(1, 1, 1);

void main() {
    waterColor = vec3(0);
    waterCount = 0;
    stellarViewMoonDir = vec3(0);
    _stellarViewMoonDirMax = vec3(0);
}