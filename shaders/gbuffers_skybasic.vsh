#version 460 core

uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform int fogShape;

in vec4 vaColor;

out vec4 vertColor;

// Vanilla sky
#if SKY == 0
out vec3 vertPos;
out float vertexDistance;

float fogDistance(vec3 pos) {
    #if fogShape == 0
        return length(pos);
    #else
        float distXZ = length(pos.xz);
        float distY = abs(pos.y);
        return max(distXZ, distY);
   	#endif
}
#endif

void main() {
	const vec4 viewPos = modelViewMatrix * vec4(vaPosition, 1);
	const vec4 clipPos = projectionMatrix * viewPos;

	vertColor = vaColor;
	gl_Position = clipPos;

	vertPos = viewPos.xyz;
	#if SKY == 0
		vertexDistance = fogDistance(vaPosition);
	#endif
}