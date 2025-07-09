#version 460 core

#include "/includes/shared/settings.glsl"
#include "/includes/func/color/srgb.glsl"

in vec4 vertColor;
in float vertexDistance;

layout(location = 0) out vec4 Color;

// Vanilla sky
vec3 skyColor = ap.world.skyColor;
vec4 fogColor = ap.world.fogColor;
float fogStart = ap.world.fogStart;
float fogEnd = ap.world.fogEnd;

vec3 linearFog(vec3 inColor, float vertexDistance) {
    if (vertexDistance <= fogStart) {
        return inColor;
    }

    float fogValue = vertexDistance < fogEnd ? smoothstep(fogStart, fogEnd, vertexDistance) : 1.0;
    return mix(inColor.rgb, fogColor.rgb, fogValue);
}

void iris_emitFragment() {
    // ISSUE: TODOEVENTUALLY: APERTURE: currently doesnt support differentiating between stars, sky, and sunrise/set
    float vertAlpha = vertColor.a;
    bool isSky = vertAlpha >= 1.0;
    bool isSunset = vertAlpha < 1.0 && any(greaterThan(vertColor.rgb, vec3(0.0))); 
    
    Color = vec4(0);
    if (Sky == 0) { // Vanilla Sky
        if (isSky) {
            Color.rgb = linearFog(skyColor, vertexDistance);
        } else if (isSunset) {
            Color = vertColor;
        } 
    }
    if (Stars == 0 && !isSunset && !isSky) { // Vanilla Stars
        Color.rgb = starColor*vertAlpha;
    } 
}
