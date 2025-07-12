#version 460 core

#extension GL_ARB_shader_viewport_layer_array: disable
#extension GL_AMD_vertex_shader_layer : enable // TEMP: AP_ISSUE: some vendors dont support the ARB version, instead use amd

#include "/includes/func/shadows/distortShadow.glsl"

out vec2 texCoord;

void iris_emitVertex(inout VertexData data) {
	vec3 posView = (iris_modelViewMatrix * vec4(data.modelPos.xyz, 1)).xyz;
	data.clipPos = iris_projectionMatrix * vec4(posView, 1);
	data.clipPos.xyz = distortShadow(data.clipPos.xyz);
}

void iris_sendParameters(VertexData data) {
	texCoord = data.uv;
}