#version 460 core

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;

// in vec4 vaColor;
in vec2 vaUV0;

// out vec3 vertColor;
out vec2 texCoord;

void main() {
	const vec4 viewPos = modelViewMatrix * vec4(vaPosition, 1);
	const vec4 clipPos = projectionMatrix * viewPos;

	gl_Position = clipPos;
	texCoord = vaUV0;
}