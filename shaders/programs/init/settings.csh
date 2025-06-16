#version 460 core
layout (local_size_x = 1) in;

#include "/includes/shared/settings.glsl"

void main() {
    AmbientColor = vec3(0.35, 0.35, 0.4);
    LightColor = vec4(0.98, 0.95, 0.95, 1); // TODONOW: lerp based on time
}