#version 460 core

#include "/settings/screen_space_reflections.glsl"
#include "/func/buffers/colortex3.glsl"

uniform sampler2D colortex0;
uniform float viewWidth;
uniform float viewHeight;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 Color;

in vec2 fragCoord;

void main() {
    // blend ssr here
    // Color = texture(colortex0, fragCoord);
    Color.rgb = vec3(0);

    vec2 reflectedCoord = readSSRLinear(fragCoord); //I thought doing deferred resolve would slightly improve the quality BUT DAMN its sooo much better especially with linear filtering

    if (reflectedCoord.x > 0 || reflectedCoord.y > 0) {
        // Color.rgb = vec3(reflectedCoord, 0);
        Color.rgb = texture(colortex0, reflectedCoord).rgb;
    }

}