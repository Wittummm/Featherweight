#version 460 core

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;

void main() {
	const vec4 viewPos = modelViewMatrix * vec4(vaPosition, 1);
	const vec4 clipPos = projectionMatrix * viewPos;

	gl_Position = clipPos;
}