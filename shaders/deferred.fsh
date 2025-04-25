#version 460 core

uniform vec3 upPosition;
uniform vec3 shadowLightPosition;
uniform vec3 cameraPosition;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform mat3 normalMatrix;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferModelView;
uniform sampler2D colortex0;
uniform float sunAngle;
uniform vec4 lightColor;

#include "/common/const.glsl"
#include "/lib/pbr.glsl"
#include "/lib/math_lighting.glsl"
#include "/func/packLightLevel.glsl"
#include "/settings/lighting.glsl"
#include "/func/depthToViewPos.glsl"
#include "/func/atmosphere/calcSky.glsl"

uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D depthtex0;
uniform vec3 skyColor;
uniform float near;
uniform float far;
#ifdef DISTANT_HORIZONS
	uniform sampler2D dhDepthTex0;
	uniform mat4 dhProjectionInverse;
#endif

in vec2 texCoord;

/* RENDERTARGETS: 0,1,2 */
layout(location = 0) out vec4 Color;
layout(location = 1) out vec4 GBuffer0;
layout(location = 2) out vec4 GBuffer1;

void main() {
	GBuffer0 = texture(colortex1, texCoord);
	GBuffer1 = texture(colortex2, texCoord);
	Color = texture(colortex0, texCoord);

	bool isSky = false;
	float depth = texture(depthtex0, texCoord).r;
	// DUPLICATE CODE: SDKH213
	#ifdef DISTANT_HORIZONS
		const float dhDepth = texture(dhDepthTex0, texCoord).r;
		isSky = depth >= 1 && dhDepth >= 1;
		vec3 viewPos = depth < 1 ? depthToViewPos(texCoord, depth) : depthToViewPos(texCoord, dhDepth, dhProjectionInverse);
	#else
		vec3 viewPos = depthToViewPos(texCoord, depth);
		isSky = depth >= 1;
	#endif

	// NOTE: Both these branches should **not** get out of hand/too big, if it does move to snippets or make into a function
	if (isSky) {
		// Render Sky
		Color.rgb = Color.rgb*0.8 + calcSky(normalize(viewPos));
	} else {
		// Render Object
		const vec2 lightLevel = unpackLightLevel(Color.a);
		Material material = Mat(Color.rgb, GBuffer0, GBuffer1);

		const bool shouldUpdate = shade(Color, material, lightLevel, viewPos);
		if (shouldUpdate) {
			GBuffer0.r = roughnessWrite(material.roughness);
			GBuffer1.rg = normalsWrite(viewToPlayerSpace(material.normals));
			GBuffer0.g = reflectanceWriteFromF0(material.f0.x);
		}
	}
}