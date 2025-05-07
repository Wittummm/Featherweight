#version 460 core

uniform sampler2D gtexture;

in vec2 texCoord;
in vec4 vertColor;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 Color;

void main() {
	Color = vertColor * texture(gtexture, texCoord);
	Color.a *= 0.5; // TODOEVENTUALLY: The transparency of rain is hardcoded for now but probably should be configurable
}