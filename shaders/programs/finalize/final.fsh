#version 460 core

#include "/includes/shared/shared.glsl"
#include "/includes/func/color/srgb.glsl"
#include "/includes/func/tonemaps/all_tonemaps.glsl"

uniform sampler2D sceneTex;
in vec2 uv;

layout(location = 0) out vec4 Color;

float calcExposure() {
    // CREDIT: SOURCE: https://bruop.github.io/exposure/
    const float sensorSensitivity = 100;
    const float lightMeterCalibration = 12.5;
    const float vignetteAttenuation = 0.65;
    float ev100 = log2((sensorSensitivity/lightMeterCalibration)*AverageLuminance);
    float maxLuminance = (78.0/(vignetteAttenuation*sensorSensitivity)) * exp2(ev100);

    return 1.0/maxLuminance;
}

void main() {
    Color = readScene(texture(sceneTex, uv));
    Color.rgb *= ExposureMult*calcExposure();

    bool gammaCorrect;
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
    } else {
        gammaCorrect = tonemap(Color.rgb, Tonemap);
    }

    if (gammaCorrect) Color = linearToSRGB(Color);
}
