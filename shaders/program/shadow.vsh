#include "/snippets/version.glsl"

uniform vec3 upPosition;
uniform vec3 shadowLightPosition;

#include "/settings/shadows.glsl"
#include "/func/distortShadow.glsl"

uniform vec3 chunkOffset;
#ifndef DISTANT_HORIZONS_SHADER
	uniform mat4 modelViewMatrix;
	uniform mat4 projectionMatrix;

	in vec3 vaPosition;
	in vec2 vaUV0;

	out vec2 texCoord;
#endif

// TODO: dh_shadow seems to not be supported on 1.21.4 (yet)
void main() {
	#include "/snippets/core_to_compat.vsh"
	
	vec4 viewPos = modelViewMatrix * vec4(vaPosition + chunkOffset, 1);
	vec4 clipPos = projectionMatrix * viewPos;

	gl_Position.xyz = distortShadow(clipPos.xyz);
	gl_Position.w = clipPos.w;
#ifndef DISTANT_HORIZONS_SHADER
	texCoord = vaUV0;
#endif
}