#version 460 core

#include "/settings/lighting.glsl"
#include "/settings/sky.glsl"
#include "/lib/metadata.glsl"

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;

#ifdef STELLAR_VIEW
	uniform mat4 gbufferModelView;
	uniform mat4 gbufferModelViewInverse;
	uniform int renderStage;
	uniform float sunAngle;
#endif

in vec4 vaColor;
in vec2 vaUV0;

out vec4 vertColor;
out vec2 texCoord;

#ifdef STELLAR_VIEW
vec3 rotateAroundX(vec3 v, float angle) {
    float s = sin(angle);
    float c = cos(angle);
    return vec3(
        v.x,
        c * v.y - s * v.z,
        s * v.y + c * v.z
    );
}
#endif

void main() {
	vertColor = vaColor;

	vec3 viewPos = (modelViewMatrix * vec4(vaPosition, 1)).xyz;
	#ifdef STELLAR_VIEW
	// Stellar View forces the sun/moon to have 0 angle, so this counters that
	if (renderStage == MC_RENDER_STAGE_CUSTOM_SKY /*&& vertColor.a >= 1*/) { // Moon doesnt seemlessly get detected, so we just rotate the whole sky :P
		vec3 playerPos = (gbufferModelViewInverse * vec4(viewPos, 1)).xyz;
		playerPos = rotateAroundX(playerPos, radians(-sunPathRotation));
		viewPos = (gbufferModelView * vec4(playerPos, 1)).xyz;

		if (sunAngle > 0.52 && playerPos.y > -2 && vertColor.a >= 1 && sunAngle < 0.98) { // Is moon
			if (gl_VertexID == 0) {stellarViewMoonDir = normalize(viewPos); }
			if (gl_VertexID == 2) {_stellarViewMoonDirMax = normalize(viewPos); }
		} 
	}
	#endif
	vec4 clipPos = projectionMatrix * vec4(viewPos, 1);

	gl_Position = clipPos;
	texCoord = vaUV0;
}