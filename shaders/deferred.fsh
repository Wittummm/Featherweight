#version 460 core

#include "/common/const.glsl"
#include "/lib/math.glsl"
#include "/lib/pbr.glsl"
#include "/lib/math_lighting.glsl"
#include "/func/depthToViewPos.glsl"
#include "/settings/lighting.glsl"
#include "/func/specular.glsl"
#include "/func/depthToNormals.glsl"
#include "/lib/light_level.glsl"

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D depthtex0;

in vec2 texCoord;

/* RENDERTARGETS: 0,1,2 */
layout(location = 0) out vec4 Color;
layout(location = 1) out vec4 GBuffer0;
layout(location = 2) out vec4 GBuffer1;


void main() {
	GBuffer0 = texture(colortex1, texCoord);
	GBuffer1 = texture(colortex2, texCoord);
	Color = texture(colortex0, texCoord);
	const vec2 lightLevel = unpackLightLevel(Color.a);

	Color.a = 1;

	const float depth = texture(depthtex0, texCoord).r;
	    
	if (depth < 1) {
		const vec3 viewPos = depthToViewPos(texCoord, depth);
		const vec3 viewDir = normalize(viewPos);
		Material material = Mat(GBuffer0, GBuffer1);

		shade(Color, material, viewPos, texCoord, lightLevel);
        GBuffer0.r = roughnessWrite(material.roughness);
		GBuffer1.rg = normalsWrite(material.normals); 
		GBuffer0.g = reflectanceWriteFromF0(material.f0.x);
	}
}