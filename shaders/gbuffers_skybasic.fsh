#version 460 core

#include "/settings/sky.glsl"

uniform int renderStage;

in vec4 vertColor;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 Color;

// Vanilla sky
#if SKY == 0
uniform vec3 upPosition;
uniform vec3 fogColor;
uniform float fogStart;
uniform float fogEnd;
in vec3 vertPos;
in float vertexDistance;

vec4 linearFog(vec4 inColor, float vertexDistance) {
    if (vertexDistance <= fogStart) {
        return inColor;
    }

    float fogValue = vertexDistance < fogEnd ? smoothstep(fogStart, fogEnd, vertexDistance) : 1.0;
    return vec4(mix(inColor.rgb, fogColor.rgb, fogValue), inColor.a);
}
#endif

void main() {
    // Below is a mess bc of supporting Stellar View
    vec3 skyColor = vertColor.rgb;

    #if SKY == 0 // Vanilla Sky
        if (renderStage == MC_RENDER_STAGE_SKY || renderStage == MC_RENDER_STAGE_CUSTOM_SKY) {
            //      IfNotSkyTop ? star/sunset : skyTopColor
            
            Color = vertColor.a < 1.0 ? vertColor : linearFog(vertColor, vertexDistance);
        } else {
            Color.a = vertColor.a;
    #else // Shader Sky
        if (renderStage != MC_RENDER_STAGE_CUSTOM_SKY) { // If is vanilla sky
            skyColor = vec3(0);
            Color.a = renderStage == MC_RENDER_STAGE_STARS ? vertColor.a : 1.0; // Clear sky to black instead vanilla sky color
        } else { // If is star OR stell view sky/stars
            #ifdef REMOVE_STELLAR_VIEW_UNTEXTURED_STARS
                // If stars are textured then there should be nothing non-sky in skybasic
                discard; // This removes the vanilla Sunset + Untextured Stellar View stars
            #else
                Color.a = vertColor.a;
                if (vertColor.a >= 1.0) { // Is Sky Top
                    discard;
                }
            #endif
        }
    #endif
        Color.rgb = mix(skyColor, starColor * vertColor.a, float(renderStage == MC_RENDER_STAGE_STARS));
    #if SKY == 0
    }
    #endif
}