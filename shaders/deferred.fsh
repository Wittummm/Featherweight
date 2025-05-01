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
uniform sampler2D depthtex1;

#include "/common/const.glsl"
#include "/lib/pbr.glsl"
#include "/lib/math_lighting.glsl"
#include "/func/packing/packLightLevel.glsl"
#include "/settings/lighting.glsl"
#include "/func/depthToViewPos.glsl"
#include "/func/atmosphere/calcSky.glsl"
#include "/func/coloring/srgb.glsl"
#include "/func/shading/calcWater.glsl"
#include "/lib/metadata.glsl"

uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform vec3 skyColor;
uniform float near;
uniform float far;
#ifdef DISTANT_HORIZONS
	uniform sampler2D dhDepthTex1;
	uniform mat4 dhProjectionInverse;
#endif

in vec2 fragCoord;

/* RENDERTARGETS: 0,1,2 */
layout(location = 0) out vec4 Color;
layout(location = 1) out vec4 GBuffer0;
layout(location = 2) out vec4 GBuffer1;

void main() {
	Color = srgbToLinear(texture(colortex0, fragCoord));
	GBuffer0 = texture(colortex1, fragCoord);
	GBuffer1 = texture(colortex2, fragCoord);

	bool isSky = false;
	float depth = texture(depthtex1, fragCoord).r;
	// DUPLICATE CODE: SDKH213
	#ifdef DISTANT_HORIZONS
		float dhDepth = texture(dhDepthTex1, fragCoord).r;
		isSky = depth >= 1 && dhDepth >= 1;
		vec3 viewPos = depth < 1 ? depthToViewPos(fragCoord, depth) : depthToViewPos(fragCoord, dhDepth, dhProjectionInverse);
	#else
		vec3 viewPos = depthToViewPos(fragCoord, depth);
		isSky = depth >= 1;
	#endif

	// NOTE: Both these branches should **not** get out of hand/too big, if it does move to snippets or make into a function
	if (isSky) {
		// Render Sky
		Color.rgb = Color.rgb*0.8 + calcSky(normalize(viewPos));
	} else {
		// Render Object
		vec2 lightLevel = unpackLightLevel(Color.a);
		Material material = Mat(Color.rgb, GBuffer0, GBuffer1);

		float shadow;
		bool shouldUpdate = shade(Color, material, lightLevel, viewPos, shadow);
		if (shouldUpdate) {
			GBuffer0.r = roughnessWrite(material.roughness);
			GBuffer1.rg = normalsWrite(viewToPlayerSpace(material.normals));
			GBuffer0.g = reflectanceWriteFromF0(material.f0.x);
		}
	}

	Color = linearToSRGB(Color);
}