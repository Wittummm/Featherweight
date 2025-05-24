#include "/snippets/version.glsl"

#include "/settings/shadows.glsl"

#ifndef DISTANT_HORIZONS_SHADER
uniform sampler2D gtexture;
uniform float alphaTestRef;

in vec2 texCoord;
#endif

void main() {
#ifndef DISTANT_HORIZONS_SHADER
	vec4 color = texture(gtexture, texCoord, SHADOW_MIP_MAP_BIAS);
	#ifdef CUTOUT
	if (color.a < alphaTestRef) {
		discard;
	}
	#endif
#endif
}