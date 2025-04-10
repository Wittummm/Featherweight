#version 460 core

uniform int renderStage;
uniform float viewHeight;
uniform float viewWidth;
uniform mat4 gbufferModelView;
uniform mat4 gbufferProjectionInverse;
uniform vec3 fogColor;
uniform vec3 skyColor;

in vec4 vertColor;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	color = vertColor;
}