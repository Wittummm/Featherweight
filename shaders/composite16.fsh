#version 460 core

uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferModelView;
uniform mat3 normalMatrix;

#include "/common/const.glsl"
#include "/settings/screen_space_reflections.glsl"
#include "/func/buffers/colortex3.glsl"
#include "/func/shading/specular.glsl"
#include "/lib/material.glsl"
#include "/func/depthToViewPos.glsl"

uniform sampler2D depthtex0;
uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform float viewWidth;
uniform float viewHeight;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 Color;

in vec2 fragCoord;

const bool colortex0MipmapEnabled = true;

void main() {
    // TODO: fade out effect on edge of screen
    // TODO: Learn blurring, then apply actually good blurring here
    // TODONOW: finalize config
    // THEN do bloom -> blurring
    
    // blend ssr here
    Color = texture(colortex0, fragCoord); 

    vec3 reflectedCoord = readSSRLinear(fragCoord); // I thought doing deferred resolve would slightly improve the quality BUT DAMN its sooo much better especially with linear filtering

    if (reflectedCoord.x > 0 || reflectedCoord.y > 0) {

        float blur = reflectedCoord.z*20;
        vec3 c0 = textureLod(colortex0, reflectedCoord.xy, floor(blur)).rgb;
        vec3 c1 = textureLod(colortex0, reflectedCoord.xy, ceil(blur)).rgb;

  
        vec3 color = mix(c0, c1, fract(blur));

        float depth = textureLod(depthtex0, fragCoord, 0).r;
        vec4 gbuffer0 = textureLod(colortex1, fragCoord, 0);
        vec4 gbuffer1 = textureLod(colortex2, fragCoord, 0);
        Material material = Mat(Color.rgb, gbuffer0, gbuffer1);

        float NdotV = max(dot(-normalize(depthToViewPos(fragCoord, depth)), material.normals), 0);
        vec3 fresnel = clamp(fresnelSchlick(NdotV, material.f0), 0, 1);
        
        Color.rgb = mix(Color.rgb, color, fresnel);
    }
}