/*
    Sources:
    [x] https://lettier.github.io/3d-game-shaders-for-beginners/screen-space-reflection.html
    [x] https://zznewclear13.github.io/posts/screen-space-reflection-en/
*/

#version 460 core

#include "/func/misc/reconstructNormals.glsl"
#include "/func/depthToViewPos.glsl"
#include "/settings/screen_space_reflections.glsl"

uniform mat4 gbufferProjection;
uniform sampler2D depthtex0;
uniform sampler2D colortex0;
uniform float viewWidth;
uniform float viewHeight;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 Color;
layout (rgba8) uniform image2D colorimg0;

in vec2 fragCoord;

vec3 viewToScreenSpace(vec3 viewPos) {
    vec4 clipPos = gbufferProjection * vec4(viewPos, 1);
    vec3 screenPos = (clipPos.xyz / clipPos.w)*0.5 + 0.5;
    return screenPos;
}

void main() {
	
    // TODONOW: make resolution editable
    // TODONOW: polish and make look good
    // TODONOW: make into ssr + binary search function

    float depth;
    vec3 normals = reconstructNormals(fragCoord, depthtex0, depth); // temp
    
    Color.rgb = vec3(0);
    if (depth >= 1) return;

    vec3 startPos = depthToViewPos(fragCoord, depth) + normals*0.1;
    vec3 reflected = normalize(reflect(normalize(startPos), normalize(normals)));
    vec3 endPos = startPos + reflected*maxDist;

    vec3 reflectedColor = vec3(-1);
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
                vec3 _currentFrag = (startFrag + endFrag)*0.5;
                float _currentDepth = texture(depthtex0, _currentFrag.xy).r;

                if (_currentFrag.z > _currentDepth) {
                    if (_currentFrag.z - _currentDepth < refineMaxThickness) {
                        reflectedColor = texture(colortex0, _currentFrag.xy).rgb;
                        break; // precise enough so just break
                    } else {
                        endFrag = _currentFrag;
                    }
                } else {
                    startFrag = _currentFrag;
                }
                if (j == refineSteps-1 && reflectedColor.x == -1) {
                    reflectedColor = texture(colortex0, endFrag.xy).rgb;
                }
            }
            break;
        }
        lastFrag = currentFrag;
    }

    Color.rgb += reflectedColor;
}