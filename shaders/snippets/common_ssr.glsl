uniform float near;
uniform float far;

#include "/func/depthToViewPos.glsl"
#include "/func/misc/linearizeDepth.glsl"

uniform sampler2D depthtex0;
uniform mat4 gbufferProjection;

#ifdef DISTANT_HORIZONS
uniform sampler2D dhDepthTex0;
uniform float dhFarPlane;
uniform float dhNearPlane;
uniform mat4 dhProjectionInverse;
#endif

vec3 viewToScreenSpace(vec3 viewPos) {
    vec4 clipPos = gbufferProjection * vec4(viewPos, 1);
    vec3 screenPos = (clipPos.xyz / clipPos.w)*0.5 + 0.5;
    return screenPos;
}

vec3 screenToViewSpace(vec3 screenPos) {
    return depthToViewPos(screenPos.xy, screenPos.z);
}

vec3 sampleViewPos(vec2 fragCoord) {
    float depth = textureLod(depthtex0, fragCoord, 0).r;
    #ifdef DISTANT_HORIZONS
        if (depth >= 1) return depthToViewPos(fragCoord, textureLod(dhDepthTex0, fragCoord, 0).r, dhProjectionInverse);
    #endif
    return depthToViewPos(fragCoord, depth);
}

float sampleLinearDepth(vec2 fragCoord) {
    float depth = textureLod(depthtex0, fragCoord, 0).r;
    #ifdef DISTANT_HORIZONS
        if (depth >= 1) return linearizeDepthFull(textureLod(dhDepthTex0, fragCoord, 0).r, dhNearPlane, dhFarPlane);
    #endif
    return linearizeDepthFull(depth, near, far*4);
}