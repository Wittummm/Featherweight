/*
    Sources:
    [x] https://lettier.github.io/3d-game-shaders-for-beginners/screen-space-reflection.html
    [x] https://zznewclear13.github.io/posts/screen-space-reflection-en/
*/

#version 460 core

uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferModelView;
uniform mat3 normalMatrix;

#include "/common/const.glsl"
#include "/func/misc/reconstructNormals.glsl"
#include "/func/depthToViewPos.glsl"
#include "/settings/screen_space_reflections.glsl"
#include "/func/buffers/colortex3.glsl"
#include "/lib/material.glsl"

uniform mat4 gbufferProjection;
uniform sampler2D depthtex0;
uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform float viewWidth;
uniform float viewHeight;

uniform float frameTimeCounter;

/* RENDERTARGETS: 3 */
layout(location = 0) out uint SSR;

// in vec2 fragCoord; // NOTE: Cannot use fragCoord from vertex stage as it is imprecise

vec3 viewToScreenSpace(vec3 viewPos) {
    vec4 clipPos = gbufferProjection * vec4(viewPos, 1);
    vec3 screenPos = (clipPos.xyz / clipPos.w)*0.5 + 0.5;
    return screenPos;
}

vec3 screenToViewSpace(vec3 screenPos) {
    vec4 clipPos = gbufferProjectionInverse * vec4(screenPos * 2.0 - 1.0, 1);
    return clipPos.xyz/clipPos.w;
}

vec3 ssr(vec3 startPos, vec3 endPos) {
    vec3 lastFrag;

    for (float i = 0; i < SSR_STEPS; i++) {
        vec3 currentFrag = viewToScreenSpace(mix(startPos, endPos, i/(SSR_STEPS-1)));
        if (clamp(currentFrag, 0, 1) != currentFrag) break;

        float currentDepth = texture(depthtex0, currentFrag.xy).r;

        // if (currentDepth >= 1) { // This is wrong
        //     return currentFrag;
        // }

        if (currentFrag.z > currentDepth && currentFrag.z - currentDepth < maxThickness) {
            // Binary Search
            vec3 startFrag = lastFrag;
            vec3 endFrag = currentFrag;
            for (float j = 0; j < SSR_REFINE_STEPS; j++) {
                vec3 BcurrentFrag = (startFrag + endFrag)*0.5;
                float BcurrentDepth = texture(depthtex0, BcurrentFrag.xy).r;

                if (BcurrentFrag.z > BcurrentDepth) {
                    if (BcurrentFrag.z - BcurrentDepth < refineMaxThickness) {
                        return BcurrentFrag;
                        break; // precise enough so just break
                    } else {
                        endFrag = BcurrentFrag;
                    }
                } else {
                    startFrag = BcurrentFrag;
                }
                if (j == SSR_REFINE_STEPS-1) {
                    return endFrag;
                }
            }
            break;
        }
        lastFrag = currentFrag;
    }

    return vec3(-1);
}

void main() {
    vec2 fragCoord = gl_FragCoord.xy*colortex3TexelSize;
    ivec2 pixelCoord = ivec2(fragCoord*vec2(viewWidth, viewHeight));
    
    float depth = texelFetch(depthtex0, pixelCoord, 0).r;
    
    SSR = 0;
    if (depth >= 1) return;
    /////  PBR  /////
    vec4 color = texelFetch(colortex0, pixelCoord, 0);
    vec4 gbuffer0 = texelFetch(colortex1, pixelCoord, 0);
	vec4 gbuffer1 = texelFetch(colortex2, pixelCoord, 0);

    Material material = Mat(color.rgb, gbuffer0, gbuffer1);
    vec3 normals = material.normals;
    ////////////////////////// 
    vec3 startPos = depthToViewPos(fragCoord, depth) + normals*0.05;
    vec3 reflected = reflect(normalize(startPos), normals);
    vec3 endPos = startPos + reflected*ssrDistance;

    vec3 hitCoord = ssr(startPos, endPos);
    vec3 hitPos = screenToViewSpace(hitCoord);
    float softness = material.roughness * distance(hitPos, startPos)/ssrDistance;

    SSR = writeSSR(hitCoord.xy, softness);
}