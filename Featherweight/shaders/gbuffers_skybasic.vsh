#version 460 core

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform vec3 chunkOffset;

in vec4 vaColor;

out vec4 vertColor;

void main() {
	const vec4 viewPos = modelViewMatrix * vec4(vaPosition, 1);
	const vec4 clipPos = projectionMatrix * viewPos;

	gl_Position = clipPos;
	vertColor = vaColor;
}