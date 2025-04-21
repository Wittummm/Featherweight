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

#include "/common/const.glsl"
#include "/settings/lighting.glsl"
#include "/func/depthToViewPos.glsl"
#include "/func/atmosphere/calcSky.glsl"
#include "/settings/atmosphere.glsl"

uniform sampler2D depthtex0;
uniform float near;
uniform float far;
#ifdef DISTANT_HORIZONS
	uniform sampler2D dhDepthTex0;
	uniform mat4 dhProjectionInverse;
#endif

in vec2 texCoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 Color;

void main() {
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

	if (!isSky) {
		const float fogFactor = min(smoothstep(FOG_START*far, FOG_END*far, length(viewPos)) * FOG_DENSITY, 1);
		const vec3 fogCoord = (mat3(gbufferModelView) * 
			normalize((mat3(gbufferModelViewInverse)*viewPos*vec3(1,0,1))) 
		);
		Color.rgb = mix(Color.rgb, calcSky(fogCoord), fogFactor);
	}
}