#version 460 core

uniform mat4 gbufferModelViewInverse;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
in vec2 vaUV0;
in vec3 vaPosition;

out vec2 texCoord;

void main() {
	vec4 viewPos = modelViewMatrix * vec4(vaPosition, 1);
	vec4 clipPos = projectionMatrix * viewPos;

	texCoord = vaUV0;
	gl_Position = clipPos;
}