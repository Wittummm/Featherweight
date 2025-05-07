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
#include "/settings/screen_space_reflections.glsl"
#include "/func/buffers/colortex3.glsl"
#include "/lib/material.glsl"
#include "/snippets/common_ssr.glsl"

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform float viewWidth;
uniform float viewHeight;
uniform float farPlane;
uniform float nearPlane;

/* RENDERTARGETS: 3 */
layout(location = 0) out uint SSR;

// in vec2 fragCoord; // NOTE: Cannot use fragCoord from vertex stage as it is imprecise

const vec2 viewRes = vec2(viewWidth, viewHeight);

vec3 ssr(vec3 startPos, vec3 endPos) {
    vec3 startFrag = viewToScreenSpace(startPos);
    vec3 endFrag = viewToScreenSpace(endPos); 

    vec3 lastFrag;
    if (endPos.z <= 0) {
        for (float i = 0; i < SSR_STEPS; i++) {
            vec3 currentFrag = mix(startFrag, endFrag, i/(SSR_STEPS-1)); 

            if (clamp(currentFrag, 0, 1) != currentFrag) break;
            float currentDepth = sampleLinearDepth(currentFrag.xy) + bias;
            #if DISTANT_HORIZONS
                currentFrag.z = currentDepth < farPlane ? linearizeDepth(currentFrag.z, nearPlane, farPlane) : linearizeDepth(currentFrag.z, dhNearPlane, dhFarPlane);
            #else
                currentFrag.z = linearizeDepth(currentFrag.z, nearPlane, farPlane);
            #endif

            if (currentFrag.z > currentDepth && currentFrag.z - currentDepth < maxThickness) {
                vec3 startFrag = lastFrag;
                vec3 endFrag = currentFrag;
                for (float j = 0; j < SSR_REFINE_STEPS; j++) {
                    vec3 BcurrentFrag = j == 0 ? endFrag : (startFrag + endFrag)*0.5;
                    float BcurrentDepth = sampleLinearDepth(BcurrentFrag.xy) + bias;

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
                }
                break;
            }
            lastFrag = currentFrag;
        }
    }

    return vec3(10);
}

void main() {
    vec2 fragCoord = gl_FragCoord.xy*colortex3TexelSize;
    ivec2 pixelCoord = ivec2(fragCoord*vec2(viewWidth, viewHeight));

    vec3 startPos = sampleViewPos(fragCoord);
    #if SSR_NORMAL_STRENGTH <= 100
        // vanilla chunks, dh chunks has no normal maps so we dont need to reconstruct
        vec3 normalsImplied = -startPos.z < far ? normalize(reconstructNormals(pixelCoord/vec2(viewWidth, viewHeight), depthtex0)) : vec3(-1);
    #endif
    
    SSR = 0;
    #ifdef DISTANT_HORIZONS
        if (-startPos.z >= dhFarPlane) return;
    #else
        if (-startPos.z >= farPlane) return;
    #endif
    /////  PBR  /////
    vec4 color = texelFetch(colortex0, pixelCoord, 0);
    vec4 gbuffer0 = texelFetch(colortex1, pixelCoord, 0);
	vec4 gbuffer1 = texelFetch(colortex2, pixelCoord, 0);
    Material material = Mat(color.rgb, gbuffer0, gbuffer1);

    vec3 viewDir = normalize(startPos);
    #if SSR_NORMAL_STRENGTH > 100
        vec3 normals = material.normals;
    #elif SSR_NORMAL_STRENGTH <= 0
        vec3 normals = normalsImplied.x == -1 ? material.normals;
    #elif SSR_NORMAL_STRENGTH <= 100
        vec3 normals = normalsImplied.x == -1 ? material.normals : 
        mix(normalsImplied, material.normals, 
            max(mix(ssrNormalStrengthMin, ssrNormalStrengthMax, min( -dot(viewDir, normalsImplied)*2 , 1)), // At grazing angles normal maps cause noise so we soften them
            step(dot(normalsImplied, material.normals), 0.9))
        );
    #endif
    ////////////////////////// 
    startPos += normals*0.05;
    vec3 reflected = reflect(viewDir, normals);
    vec3 endPos = startPos + reflected*SSR_MAX_DISTANCE;

    vec3 hitCoord = ssr(startPos, endPos);
    float dist = hitCoord.x == 10 ? 0.0 : max(distance(screenToViewSpace(hitCoord), startPos)/SSR_MAX_DISTANCE, 0.004); // Need to clamp since `0` is used as invalid and valid ones should never be invalid
    
    SSR = writeSSR(min(hitCoord.xy, 1), min(dist, 1));
}
