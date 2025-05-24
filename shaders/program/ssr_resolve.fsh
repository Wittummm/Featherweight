#version 460 core

uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferModelView;
uniform mat3 normalMatrix;

#include "/common/const.glsl"
#include "/settings/screen_space_reflections.glsl"
#include "/func/buffers/colortex3.glsl"
#include "/func/shading/specular.glsl"
#include "/lib/material.glsl"
#include "/func/misc/reconstructNormals.glsl"
#include "/settings/atmosphere.glsl"
#include "/snippets/common_ssr.glsl"

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform float viewWidth;
uniform float viewHeight;
uniform float aspectRatio;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 Color;

in vec2 fragCoord;

const bool colortex0MipmapEnabled = true;

// NOTE: SSR Pixelization likely costs more than no pixelization
void main() {
    Color = texture(colortex0, fragCoord); 

    #if SSR_PIXELIZATION == 0
        vec2 fragUV = fragCoord;
    #else
        vec3 fragView = sampleViewPos(fragCoord);
        vec3 fragPlayer = (gbufferModelViewInverse * vec4(fragView, 1)).xyz;
        fragPlayer = pixelize(fragPlayer);
        fragView = (gbufferModelView * vec4(fragPlayer, 1)).xyz;

        vec2 fragUV = viewToScreenSpace(fragView).xy;
    #endif

    #if SSR_RESOUTION >= SSR_LINEAR_TURNOFF_THRESHOLD
        vec3 hitCoord = readSSR(fragUV);
    #else
        vec3 hitCoord = readSSRLinear(fragUV); // I thought doing deferred resolve would slightly improve the quality BUT DAMN its sooo much better especially with linear filtering
    #endif

    if (hitCoord.z > 0) {
        #if SSR_PIXELIZATION == 0
            vec3 fragView = sampleViewPos(fragUV);
        #endif
        vec3 viewDir = normalize(fragView);

        vec4 gbuffer0 = textureLod(colortex1, fragCoord, 0); // Using `fragCoord` cuz pixelized `fragUV` seems to jitter, not sure if using `fragCoord` is correct tho
        vec4 gbuffer1 = textureLod(colortex2, fragCoord, 0); // Using `fragCoord` cuz pixelized `fragUV` seems to jitter, not sure if using `fragCoord` is correct tho
        Material material = Mat(Color.rgb, gbuffer0, gbuffer1);
        //////////////
        float blur = min(5, SSR_BLUR_STRENGTH * hitCoord.z*SSR_MAX_DISTANCE*material.roughness);
        vec3 c0 = textureLod(colortex0, hitCoord.xy, floor(blur)).rgb; // TODOEVENTUALLY: Use a better but simple blur, rather than mipmap levels
        vec3 c1 = textureLod(colortex0, hitCoord.xy, ceil(blur)).rgb;

        vec3 color = mix(c0, c1, fract(blur));
        ////// Fade /////
        vec2 f1 = smoothstep(vec2(SSR_EDGE_FADE_START_MAX, SSR_EDGE_FADE_START_MAX*aspectRatio), vec2(SSR_EDGE_FADE_END_MAX, SSR_EDGE_FADE_END_MAX*aspectRatio), 
            mix(vec2(1)-fragUV.xy, fragUV.xy, step(fragUV.xy, vec2(0.5))));
        float screenFade = f1.x*f1.y;

        float fadeStart = mix(SSR_EDGE_FADE_START_MIN, SSR_EDGE_FADE_START_MAX, screenFade);
        float fadeEnd = mix(SSR_EDGE_FADE_END_MIN, SSR_EDGE_FADE_END_MAX, screenFade);
        vec2 f0 = smoothstep(vec2(fadeStart, fadeStart*aspectRatio), vec2(fadeEnd, fadeEnd*aspectRatio), 
            mix(vec2(1)-hitCoord.xy, hitCoord.xy, step(hitCoord.xy, vec2(0.5))));

        float reflectionFade = min(f0.x*f0.y, 1);
        //// Fresnel ////
        float NdotV = max(dot(-viewDir, material.normals), 0);
        vec3 fresnel = clamp(fresnelSchlick(NdotV, material.f0), 0, 1);
        /////////////////

        reflectionFade *= (1-getFogFactor(length(fragView), far));
        Color.rgb = mix(Color.rgb, color, fresnel*reflectionFade);
    }
}