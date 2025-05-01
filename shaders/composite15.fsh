/*
    Sources:
    [x] https://lettier.github.io/3d-game-shaders-for-beginners/screen-space-reflection.html
    [x] https://zznewclear13.github.io/posts/screen-space-reflection-en/
*/

#version 460 core

#include "/func/misc/reconstructNormals.glsl"
#include "/func/depthToViewPos.glsl"
#include "/settings/screen_space_reflections.glsl"
#include "/func/buffers/colortex3.glsl"
#include "/func/packing/encodeNormals.glsl"

uniform mat4 gbufferProjection;
uniform mat4 gbufferModelView;
uniform sampler2D depthtex0;
uniform sampler2D colortex2;
uniform float viewWidth;
uniform float viewHeight;

/* RENDERTARGETS: 3 */
layout(location = 0) out uvec3 SSR;

// in vec2 fragCoord; // NOTE: Cannot use fragCoord from vertex stage as it is imprecise

vec3 viewToScreenSpace(vec3 viewPos) {
    vec4 clipPos = gbufferProjection * vec4(viewPos, 1);
    vec3 screenPos = (clipPos.xyz / clipPos.w)*0.5 + 0.5;
    return screenPos;
}

void main() {
    // TODONOW: polish and make look good
    vec2 fragCoord = gl_FragCoord.xy*colortex3TexelSize;
    
    float depth = texelFetch(depthtex0, ivec2(gl_FragCoord.xy*vec2(viewWidth, viewHeight) * colortex3TexelSize), 0).r; // must multiply screenSize first then divide -> likely cuz floats are imprecise when small
    
	vec4 gbuffer1 = texture(colortex2, fragCoord);
    vec3 normals = mat3(gbufferModelView) * normalsRead(gbuffer1.rg);
    if (normals.z > 0) {
        normals.z *= 0;
        normals = normalize(normals);
    }
    
    SSR.rgb = uvec3(0);
    if (depth >= 1) return;

    vec3 startPos = depthToViewPos(fragCoord, depth) + normals*0.1;
    vec3 reflected = normalize(reflect(normalize(startPos), normalize(normals)));
    vec3 endPos = startPos + reflected*maxDist;

    vec2 reflectedCoord = vec2(-1);
    vec3 lastFrag;

    for (float i = 0; i < steps; i++) {
        vec3 currentFrag = viewToScreenSpace(mix(startPos, endPos, i/(steps-1)));
        if (clamp(currentFrag, 0, 1) != currentFrag) break;

        float currentDepth = texture(depthtex0, currentFrag.xy).r;

        if (currentFrag.z > currentDepth && currentFrag.z - currentDepth < maxThickness) {
            // Binary Search
            
            vec3 startFrag = lastFrag;
            vec3 endFrag = currentFrag;
            for (float j = 0; j < refineSteps; j++) {
                vec3 BcurrentFrag = (startFrag + endFrag)*0.5;
                float BcurrentDepth = texture(depthtex0, BcurrentFrag.xy).r;

                if (BcurrentFrag.z > BcurrentDepth) {
                    if (BcurrentFrag.z - BcurrentDepth < refineMaxThickness) {
                        reflectedCoord = BcurrentFrag.xy;
                        break; // precise enough so just break
                    } else {
                        endFrag = BcurrentFrag;
                    }
                } else {
                    startFrag = BcurrentFrag;
                }
                if (j == refineSteps-1 && reflectedCoord.x == -1) {
                    reflectedCoord = endFrag.xy;
                }
            }
            break;
        }
        lastFrag = currentFrag;
    }
    
    SSR = writeSSR(reflectedCoord);
}