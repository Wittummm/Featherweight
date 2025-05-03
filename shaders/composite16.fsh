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
#include "/func/misc/reconstructNormals.glsl"

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
    Color = texture(colortex0, fragCoord); 

    #if SSR_RESOUTION >= SSR_LINEAR_TURNOFF_THRESHOLD
        vec3 hitCoord = readSSR(fragCoord);
    #else
        vec3 hitCoord = readSSRLinear(fragCoord); // I thought doing deferred resolve would slightly improve the quality BUT DAMN its sooo much better especially with linear filtering
    #endif

    if (hitCoord.z > 0) {
        float depth = textureLod(depthtex0, fragCoord, 0).r;
        vec4 gbuffer0 = textureLod(colortex1, fragCoord, 0);
        vec4 gbuffer1 = textureLod(colortex2, fragCoord, 0);
        Material material = Mat(Color.rgb, gbuffer0, gbuffer1);

        float blur = 0.5 * hitCoord.z*ssrDistance*material.roughness;
        vec3 c0 = textureLod(colortex0, hitCoord.xy, floor(blur)).rgb; // TODOEVENTUALLY: Use a better but simple blur, rather than mipmap levels
        vec3 c1 = textureLod(colortex0, hitCoord.xy, ceil(blur)).rgb;

        vec3 color = mix(c0, c1, fract(blur));

        float NdotV = max(dot(-normalize(depthToViewPos(fragCoord, depth)), material.normals), 0);
        vec3 fresnel = clamp(fresnelSchlick(NdotV, material.f0), 0, 1);
        
        Color.rgb = mix(Color.rgb, color, fresnel);
    }
}