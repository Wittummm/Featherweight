#version 460 core

#include "/includes/func/color/srgb.glsl"

in vec2 texCoord;

layout(location = 0) out vec4 Color;

void iris_emitFragment() {
    /*immut*/ vec4 texColor = srgbToLinear(iris_sampleBaseTex(texCoord));

    Color = writeScene(texColor);
}
