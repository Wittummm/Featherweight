#version 460 core

#include "/includes/func/color/srgb.glsl"

out vec2 texCoord;
out vec2 lightmapCoord;
out vec3 vertColor;

#ifdef PBREnabled
out mat3 tbn;
#else
out vec3 vertNormal;
#endif

#ifdef FORWARD
out vec3 posView;
flat out uint blockId;
#endif

mat3 tbnNormalTangent(vec3 normal, vec4 tangent) {
    mat3 tbnMatrix;
	/*immut*/ mat3 t = mat3(ap.camera.viewInv) * iris_normalMatrix;
    tbnMatrix[0] = normalize(t * tangent.xyz);
    tbnMatrix[2] = normalize(t * normal);
    tbnMatrix[1] = normalize(cross(tbnMatrix[0], tbnMatrix[2]) * tangent.w);
    return tbnMatrix;
}

void iris_emitVertex(inout VertexData data) {
	#ifndef FORWARD
	vec3 posView;
	#endif
	posView = (iris_modelViewMatrix * data.modelPos).xyz;
	data.clipPos = iris_projectionMatrix * vec4(posView, 1);
}

void iris_sendParameters(VertexData data) {
	/*immut*/ vec2 lightLevel = data.light;
	/*immut*/ vec3 light = iris_sampleLightmap(lightLevel).rgb;

	texCoord = data.uv;
	lightmapCoord = lightLevel;
	// vertColor = srgbToLinear(data.ao*light * data.color.rgb);
	vertColor = srgbToLinear(data.ao * data.color.rgb);
	#ifdef PBREnabled
	tbn = tbnNormalTangent(data.normal, data.tangent);
	#else
	vertNormal = data.normal;
	#endif
	#ifdef FORWARD
	blockId = data.blockId;
	#endif
}