#version 460 core

#include "/includes/shared/settings.glsl"

out vec4 vertColor;
out float vertexDistance;

const int fogShape = 0; // PIN: Aperture currently doesnt give us fog shape, assume its 1
float fogDistance(vec3 pos) {
   if (fogShape == 0) {
      return length(pos);
   } else {
      float distXZ = length(pos.xz);
      float distY = abs(pos.y);
      return max(distXZ, distY);
   }
}

void iris_emitVertex(inout VertexData data) {
	data.clipPos = iris_projectionMatrix * iris_modelViewMatrix * data.modelPos;
}

void iris_sendParameters(VertexData data) {
   vertColor = data.color;
   vertexDistance = -1;
   if (Sky == 0 && vertColor.a >= 1) {vertexDistance = fogDistance(data.modelPos.xyz);}
}