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
uniform sampler2D shadowtex1;
uniform sampler2DShadow shadowtex1HW;

#include "/common/const.glsl"
#include "/settings/lighting.glsl"
#include "/func/depthToViewPos.glsl"
#include "/func/atmosphere/calcSky.glsl"
#include "/settings/atmosphere.glsl"
#include "/func/coloring/srgb.glsl"
#include "/func/shading/calcWater.glsl"
#include "/lib/metadata.glsl"
#include "/lib/shadow/shadow1.glsl"

uniform sampler2D depthtex0;
uniform sampler2D depthtex2;
uniform float near;
uniform float far;
uniform bool isEyeUnderwater;
uniform vec4 lightColor;
#ifdef DISTANT_HORIZONS
	uniform sampler2D dhDepthTex0;
	uniform int dhRenderDistance;
	uniform mat4 dhProjectionInverse;
#endif

in vec2 texCoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 Color;

void main() {
	Color = srgbToLinear(texture(colortex0, texCoord));

	bool isSky = false;
	float depth = texture(depthtex0, texCoord).r;
	// DUPLICATE CODE: SDKH213
	#ifdef DISTANT_HORIZONS
		float dhDepth = texture(dhDepthTex0, texCoord).r;
		isSky = depth >= 1 && dhDepth >= 1;
		vec3 viewPos = depth < 1 ? depthToViewPos(texCoord, depth) : depthToViewPos(texCoord, dhDepth, dhProjectionInverse);
	#else
		vec3 viewPos = depthToViewPos(texCoord, depth);
		isSky = depth >= 1;
	#endif

	if (isEyeUnderwater) {
		float LdotV = dot(normalize(shadowLightPosition), normalize(viewPos));
		float waterDepth = length(viewPos);
		
		// IDEA: we can possibly integrate the screen space radial sunrays here, which means combining the sunrays stage into here
		vec3 posPlayer = (gbufferModelViewInverse * vec4(viewPos, 1)).xyz;
		float shadow = calcShadow(posPlayer, vec3(0));
		float fogFactor = min(smoothstep(0, 0.5 - log(waterConcentration), waterDepth/far), 1);
		Color.rgb = mix(Color.rgb, calcWater(waterColor.rgb/waterCount, (1-shadow) * lightColor, waterDepth, LdotV), fogFactor);
	}

	if (!isSky && !isEyeUnderwater) {
		#ifdef DISTANT_HORIZONS
			float renderDist = dhRenderDistance;
		#else
			float renderDist = far;
		#endif
		float fogFactor = min(smoothstep(FOG_START*renderDist, FOG_END*renderDist, length(viewPos)) * FOG_DENSITY, 1);
		if (fogFactor > 0) {
			vec3 fogCoord = (mat3(gbufferModelView) * 
				normalize((mat3(gbufferModelViewInverse)*viewPos*vec3(1,0,1))) 
			);
			Color.rgb = mix(Color.rgb, calcSky(fogCoord), fogFactor);
		}
	}

	Color = linearToSRGB(Color);
}