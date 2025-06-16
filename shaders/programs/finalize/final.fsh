#version 460 core

#include "/includes/func/color/srgb.glsl"

uniform sampler2D sceneTex;

in vec2 uv;

layout(location = 0) out vec4 Color;

void main() {
    Color = linearToSRGB(texture(sceneTex, uv));
}
