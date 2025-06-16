#version 460 core

// TEMP NOTE TODOLATER: Extension thing below is currently a workaround until Aperture fixes the issue when `GL_ARB_shader_viewport_layer_array` is not supported 
#extension GL_ARB_shader_viewport_layer_array : disable
#extension GL_AMD_vertex_shader_layer : enable

#include "/includes/func/distortShadow.glsl"

out vec2 texCoord;

void iris_emitVertex(inout VertexData data) {
	data.clipPos = iris_projectionMatrix * iris_modelViewMatrix * data.modelPos;
	data.clipPos.xyz = distortShadow(data.clipPos.xyz);
}

void iris_sendParameters(VertexData data) {
	texCoord = data.uv;
}