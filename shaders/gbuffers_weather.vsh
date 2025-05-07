#version 460 core

uniform vec3 chunkOffset;
uniform sampler2D lightmap;
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;

in vec2 vaUV0;
in ivec2 vaUV2;
in vec3 vaPosition;
in vec4 vaColor;

out vec2 texCoord;
out vec4 vertColor;

const mat4 textureMatrix2 = mat4(vec4(0.00390625, 0.0, 0.0, 0.0), vec4(0.0, 0.00390625, 0.0, 0.0), vec4(0.0, 0.0, 0.00390625, 0.0), vec4(0.03125, 0.03125, 0.03125, 1.0));

void main() {
	vec3 viewPos = (modelViewMatrix * vec4(vaPosition + chunkOffset, 1)).xyz;
	vec4 clipPos = projectionMatrix * vec4(viewPos, 1);

	vec2 lightLevel = (textureMatrix2 * vec4(vaUV2, 0.0, 1.0)).xy;
	vec3 light = texture(lightmap, lightLevel).rgb;

	texCoord = vaUV0;
	gl_Position = clipPos;

	vertColor = vec4(vaColor.rgb * light, 1);
}