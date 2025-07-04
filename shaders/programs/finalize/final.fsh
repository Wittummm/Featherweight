#version 460 core

#include "/includes/func/color/srgb.glsl"
#include "/includes/shared/settings.glsl"
#include "/includes/func/tonemaps/all_tonemaps.glsl"

uniform sampler2D sceneTex;

in vec2 uv;

layout(location = 0) out vec4 Color;

bool tonemap(inout vec3 color, int tonemapper) {
    switch (tonemapper) {
        case 1: color = reinhardModified(color); break;
        case 2: color = unreal(color); return false; break;
        case 3: color = lottes(color); break;
        case 4: color = hejl(color); break;
    }
    return true;
}

void main() {
    Color = texture(sceneTex, uv);
    Color.rgb *= Exposure;

    bool gammaCorrect = tonemap(Color.rgb, Tonemap);

    if (CompareTonemaps) {
        const float slope = 17;
        vec2 maskCoord = uv;
        maskCoord.x -= 0.22;
        float mask0 = step(maskCoord.x*slope, maskCoord.y); maskCoord.x -= 0.25;
        float mask1 = step(maskCoord.x*slope, maskCoord.y); maskCoord.x -= 0.25;
        float mask2 = step(maskCoord.x*slope, maskCoord.y); maskCoord.x -= 0.25;
        float mask3 = 1-mask2;
        mask2 *= (1-mask1);
        mask1 *= (1-mask0);

        if (mask0 >= 1) {
            gammaCorrect = tonemap(Color.rgb, TonemapIndices.x);
        } else if (mask1 >= 1) {
            gammaCorrect = tonemap(Color.rgb, TonemapIndices.y);
        } else if (mask2 >= 1) {
            gammaCorrect = tonemap(Color.rgb, TonemapIndices.z);
        } else if (mask3 >= 1) {
            gammaCorrect = tonemap(Color.rgb, TonemapIndices.w);
        }
    }

    if (gammaCorrect) Color = linearToSRGB(Color);
}
