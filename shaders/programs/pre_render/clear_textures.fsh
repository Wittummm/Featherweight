#version 460 core

#include "/includes/shared/settings.glsl"

// uniform sampler2D sceneTex;
// in vec2 fragCoord;

layout(location = 0) out vec4 Color;

void main() {
    Color = Sky == 0 ? ap.world.fogColor : vec4(0);
}