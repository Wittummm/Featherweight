#version 460 core

uniform mat4 gbufferModelViewInverse;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform vec3 chunkOffset;
uniform sampler2D lightmap;
uniform int renderStage;

in vec2 vaUV0;
in ivec2 vaUV2;
in vec3 vaNormal;
in vec3 vaPosition;
in vec4 vaColor;
in vec4 at_tangent;

out vec2 texCoord;
out vec3 vertNormal;
out vec4 vertColor;
out vec4 tangent;
out vec2 lightmapCoord;

#include "/snippets/core_to_compat.vsh"
void main() {

	const vec4 viewPos = modelViewMatrix * vec4(vaPosition + chunkOffset, 1);
	const vec4 clipPos = projectionMatrix * viewPos;
	lightmapCoord = (TEXTURE_MATRIX_2 * vec4(vaUV2, 0.0, 1.0)).xy;
	const vec3 light = texture(lightmap, lightmapCoord).rgb;

	vertNormal = vaNormal;
	texCoord = vaUV0;
	gl_Position = clipPos;
	vertColor = vec4(vaColor.rgb * vaColor.a * light, 1);
	tangent = at_tangent;
}