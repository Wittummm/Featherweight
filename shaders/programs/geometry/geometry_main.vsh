#version 460 core

out vec2 texCoord;
out vec2 lightmapCoord;
out vec3 vertColor;
out mat3 tbn;

mat3 tbnNormalTangent(vec3 normal, vec4 tangent) {
    mat3 tbnMatrix;
	/*immut*/ mat3 t = mat3(ap.camera.viewInv) * iris_normalMatrix;
    tbnMatrix[0] = normalize(t * tangent.xyz);
    tbnMatrix[2] = normalize(t * normal);
    tbnMatrix[1] = normalize(cross(tbnMatrix[0], tbnMatrix[2]) * tangent.w);
    return tbnMatrix;
}

void iris_emitVertex(inout VertexData data) {
	data.clipPos = iris_projectionMatrix * iris_modelViewMatrix * data.modelPos;
}

void iris_sendParameters(VertexData data) {
	/*immut*/ vec2 lightLevel = data.light;
	/*immut*/ vec3 light = iris_sampleLightmap(lightLevel).rgb;

	texCoord = data.uv;
	lightmapCoord = lightLevel;
	vertColor = data.ao*light * data.color.rgb;
	tbn = tbnNormalTangent(data.normal, data.tangent);
}