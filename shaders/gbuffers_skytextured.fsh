#version 460 core

uniform sampler2D gtexture;
uniform int renderStage;

uniform float alphaTestRef = 0.1;

in vec2 texCoord;
in vec4 vertColor;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 Color;

void main() {
	Color = texture(gtexture, texCoord) * vertColor;
}