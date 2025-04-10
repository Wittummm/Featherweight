#version 460 core
#include "/settings/debug.glsl"

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;

in vec2 vaUV0;
in vec3 vaPosition;

out vec2 texCoord;
void main() {
	const vec4 viewPos = modelViewMatrix * vec4(vaPosition, 1);
	const vec4 clipPos = projectionMatrix * viewPos;

	texCoord = vaUV0;
	gl_Position = clipPos;
}