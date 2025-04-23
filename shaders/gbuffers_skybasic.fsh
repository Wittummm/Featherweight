#version 460 core

uniform int renderStage;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 Color;

void main() {
    if (renderStage != MC_RENDER_STAGE_STARS) {
        Color.rgb = vec3(0);
        Color.a = 1; // Set skylight to Max
    }
}