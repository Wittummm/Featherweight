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
#include "/func/misc/reconstructNormals.glsl"
#include "/lib/metadata.glsl"
#include "/lib/shadow/shadow1.glsl"
#include "/lib/pbr.glsl"

uniform sampler2D depthtex0;
uniform sampler2D colortex2;
uniform float near;
uniform float far;
uniform bool isEyeUnderwater;
uniform vec4 lightColor;
#ifdef DISTANT_HORIZONS
	uniform sampler2D dhDepthTex0;
	uniform int dhRenderDistance;
	uniform mat4 dhProjectionInverse;
#endif

in vec2 fragCoord;

const vec3 lightDir = normalize(shadowLightPosition);

/* RENDERTARGETS: 0,2 */
layout(location = 0) out vec4 Color;

void main() {
	Color = srgbToLinear(texture(colortex0, fragCoord));

	bool isSky = false;
	float depth = texture(depthtex0, fragCoord).r;
	// DUPLICATE, CODE: SDKH213
	#ifdef DISTANT_HORIZONS
		float dhDepth = texture(dhDepthTex0, fragCoord).r;
		isSky = depth >= 1 && dhDepth >= 1;
		vec3 viewPos = depth < 1 ? depthToViewPos(fragCoord, depth) : depthToViewPos(fragCoord, dhDepth, dhProjectionInverse);
	#else
		vec3 viewPos = depthToViewPos(fragCoord, depth);
		isSky = depth >= 1;
	#endif
	float fragDist = length(viewPos);

	if (isEyeUnderwater) {
		float LdotV = dot(lightDir, normalize(viewPos));

		vec4 GBuffer1 = texture(colortex2, fragCoord);
		vec3 normals = vec3(0,1,0); // TODO: Actually fetch the normals
		
		vec3 posPlayer = (gbufferModelViewInverse * vec4(viewPos, 1)).xyz;
		float shadow = calcShadow(posPlayer, vec3(0)); // * dot(normals, lightDir)
		Color.rgb *= calcWater(srgbToLinear(waterColor.rgb/waterCount /*CODE: 12jk3h*/), (1-shadow) * lightColor, fragDist, LdotV);
	}

	if (!isSky && !isEyeUnderwater) {
		#ifdef DISTANT_HORIZONS
			float renderDist = dhRenderDistance;
		#else
			float renderDist = far;
		#endif
		float fogFactor = min(smoothstep(FOG_START*renderDist, FOG_END*renderDist, fragDist) * FOG_DENSITY, 1);
		if (fogFactor > 0) {
			vec3 fogCoord = (mat3(gbufferModelView) * 
				normalize((mat3(gbufferModelViewInverse)*viewPos*vec3(1,0,1))) 
			);
			Color.rgb = mix(Color.rgb, calcSky(fogCoord), fogFactor);
		}
	}

	Color = linearToSRGB(Color);
}