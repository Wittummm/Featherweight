#version 460 core

#include "/includes/func/color/srgb.glsl"
#include "/includes/shared/shared.glsl"

in vec2 texCoord;

layout(location = 0) out vec4 Color;

void iris_emitFragment() {
    /*immut*/ vec4 texColor = srgbToLinear(iris_sampleBaseTex(texCoord));

    Color.rgb = writeScene(texColor.rgb*(LightColor.a/AmbientColor.a));
}
