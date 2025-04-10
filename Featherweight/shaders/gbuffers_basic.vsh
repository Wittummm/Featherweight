#version 460 core

uniform mat4 gbufferModelViewInverse;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform vec3 chunkOffset;

in vec2 vaUV0;
in vec3 vaNormal;
in vec3 vaPosition;

out vec2 texCoord;
out vec3 vertNormal;


void main() {
	const vec4 viewPos = modelViewMatrix * vec4(vaPosition + chunkOffset, 1);
	const vec4 clipPos = projectionMatrix * viewPos;

	vertNormal = vaNormal * mat3(gbufferModelViewInverse);
	texCoord = vaUV0;
	gl_Position = clipPos;
}