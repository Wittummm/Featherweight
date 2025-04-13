#include "/snippets/version.glsl"

#include "/settings/shadows.glsl"

#ifndef DISTANT_HORIZONS_SHADER
	uniform sampler2D gtexture;

	in vec2 texCoord;
#endif

void main() {
#ifndef DISTANT_HORIZONS_SHADER
	vec4 color = texture(gtexture, texCoord, SHADOW_MIP_MAP_BIAS);
	if (color.a < 0.1) {
		discard;
	}
#endif
}