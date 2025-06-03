#version 460 core
#include "/settings/lighting.glsl"

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform mat4 gbufferProjection;
uniform vec3 shadowLightPosition;
uniform float sunAngle;

in vec2 vaUV0;
in vec3 vaPosition;

out vec2 texCoord;
out vec3 vertPosition;
out vec2 lightPos;

void main() {
	vec4 viewPos = modelViewMatrix * vec4(vaPosition, 1);
	vec4 clipPos = projectionMatrix * viewPos;

	vec4 lightClip = gbufferProjection * vec4(shadowLightPosition, 1);
    vec3 lightNdc = lightClip.xyz / lightClip.w;
    lightPos = ((lightNdc + 1.0)*0.5).xy; // Screen-Space

	texCoord = vaUV0;
	gl_Position = clipPos;
	vertPosition = vaPosition;
}