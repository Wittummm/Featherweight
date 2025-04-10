#version 460 core

#include "/common/const.glsl"
#include "/settings/main.glsl"

uniform sampler2D gtexture;

in vec3 vertNormal;
in vec2 texCoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
    color = texture(gtexture, texCoord, MIP_MAP_BIAS);

	if (color.a < alphaTestRef) {
		discard;
	}
}