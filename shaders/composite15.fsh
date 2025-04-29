/*
    Sources:
    [x] https://lettier.github.io/3d-game-shaders-for-beginners/screen-space-reflection.html
*/

#version 460 core

uniform float near;
uniform float far;
#include "/func/misc/linearizeDepth.glsl"
// above is temp

#include "/func/misc/reconstructNormals.glsl"
#include "/func/depthToViewPos.glsl"

uniform mat4 gbufferProjection;
uniform sampler2D depthtex1;
uniform sampler2D colortex0;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 Color;

in vec2 fragCoord;

vec3 viewToScreenSpace(vec3 viewPos) {
    vec4 clipPos = gbufferProjection * vec4(viewPos, 1);
    vec3 screenPos = (clipPos.xyz / clipPos.w)*0.5 + 0.5;
    return screenPos;
}

void main() {
	// Should do Screen Space Reflections here :)
    /*
    - Reflect view pos -> also with roughness parameter
    - March in steps in the reflected vector
        -> If in front; then continue marching
        -> If intersect(some defined thickness); reflect that color
        -> If behind; reflect nothing
    */
    // TODO: SSR, should be made into a function

    const int steps = 24;
    const float maxDist = 50;
    const float maxThickness = 0.5;

    float depth;
    vec3 normals = reconstructNormals(fragCoord, depthtex1, depth);

    vec3 startPos = depthToViewPos(fragCoord, depth);
    vec3 reflected = reflect(normalize(startPos), normals);
    vec3 endPos = startPos + reflected*maxDist;

    vec2 startFrag = viewToScreenSpace(startPos).xy;
    vec2 endFrag = viewToScreenSpace(endPos).xy;

    Color.rgb = vec3(0);

    for (float i = 0; i < steps; i++) {
        vec2 currentFrag = mix(startFrag, endFrag, (i+2)/(steps+2)); // plus 2 is temp

        float currentDepth = texture(depthtex1, currentFrag).r;
        vec3 currentPos = depthToViewPos(currentFrag, currentDepth);
        
        if (currentPos.z < startPos.z && startPos.z - currentPos.z < maxThickness) {
            Color.rgb = texture(colortex0, currentFrag).rgb;
            break;
        }
    }
}