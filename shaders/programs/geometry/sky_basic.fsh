#version 460 core

#include "/includes/shared/shared.glsl"
#include "/includes/func/color/srgb.glsl"

in vec4 vertColor;
in float vertexDistance;

layout(location = 0) out vec4 Color;

// Vanilla sky
// CODE: isaoh8, seems like mc does srgb to linear by squaring;
vec3 skyColor = ap.world.skyColor*ap.world.skyColor; // srgb to linear, CODE: isaoh8
vec4 fogColor = ap.world.fogColor*ap.world.fogColor; // srgb to linear, CODE: isaoh8
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
            Color.rgb = linearFog(skyColor, vertexDistance*5); // No clue why but *5 makes it look same to vanilla
        } else if (isSunset) {
            Color = vertColor;
            Color.rgb *= Color.rgb; // srgb to linear, CODE: isaoh8
        } 
    }
    if (Stars == 0 && !isSunset && !isSky) { // Vanilla Stars
        Color.rgb = starColor*vertAlpha;
    } 

    Color = writeScene(Color);
}
