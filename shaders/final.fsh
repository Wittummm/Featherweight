#version 460 core

#include "/func/coloring/srgb.glsl"

uniform sampler2D colortex0;

layout(location = 0) out vec4 screen;

void main() {
    screen = linearToSRGB(texelFetch(colortex0, ivec2(gl_FragCoord.xy), 0));
}