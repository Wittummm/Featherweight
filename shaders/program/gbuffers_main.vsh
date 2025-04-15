#include "/snippets/version.glsl"

uniform vec3 chunkOffset;
uniform sampler2D lightmap;

#ifndef DISTANT_HORIZONS_SHADER
	uniform int renderStage;
	uniform mat4 modelViewMatrix;
	uniform mat4 projectionMatrix;

	in vec2 vaUV0;
	in ivec2 vaUV2;
	in vec3 vaNormal;
	in vec3 vaPosition;
	in vec4 vaColor;
	in vec4 at_tangent;

	out vec2 texCoord;
	out vec4 tangent;
#endif

out vec2 lightmapCoord;
out vec3 vertNormal;
out vec4 vertColor;
out vec3 vertPosition;

void main() {
	#include "/snippets/core_to_compat.vsh"

	const vec4 viewPos = modelViewMatrix * vec4(vaPosition + chunkOffset, 1);
	const vec4 clipPos = projectionMatrix * viewPos;
	const vec2 lightLevel = (TEXTURE_MATRIX_2 * vec4(vaUV2, 0.0, 1.0)).xy;
	const vec3 light = texture(lightmap, lightLevel).rgb;

#ifndef DISTANT_HORIZONS_SHADER
	texCoord = vaUV0;
	tangent = at_tangent;
#endif
	lightmapCoord = lightLevel;
	vertPosition = viewPos.xyz;
	vertNormal = vaNormal;
	gl_Position = clipPos;
	vertColor = vec4(vaColor.rgb * vaColor.a * light, 1);
}