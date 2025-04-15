#version 460 core

uniform sampler2D gtexture;

uniform float alphaTestRef = 0.1;

in vec2 texCoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 Color;

void main() {
	Color = texture(gtexture, texCoord);
	if (Color.a < alphaTestRef) {
		discard;
	}
}