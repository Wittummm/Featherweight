#version 460 core
layout (local_size_x = 16, local_size_y = 16) in;

uniform sampler2DArrayShadow shadowMapFiltered;

#include "/includes/func/buffers/gbuffer.glsl"
#include "/includes/lib/material.glsl"
#include "/includes/func/misc/linearizeDepth.glsl"
#include "/includes/shared/settings.glsl"
#include "/includes/lib/shadow/shadow0.glsl"
#include "/includes/func/depthToViewPos.glsl"
#include "/includes/func/distortShadow.glsl"
#include "/includes/lib/text_renderer.glsl"

layout(binding = 0) uniform debugConfig {
	bool _DebugEnabled;
	bool _DebugStats;
	bool _SliceScreen;
	int _ShowDepth;
    int _ShowRoughness;
	int _ShowReflectance;
	int _ShowPorosity;
	int _ShowEmission;
	int _ShowNormals;
	int _ShowAmbientOcclusion;
	int _ShowHeight;
	int _ShowShadowMap;
	bool _ShowShadows;
};

uniform sampler2D sceneTex;
uniform usampler2D gbufferTex;
uniform sampler2D mainDepthTex;
uniform sampler2DArray shadowMap;

layout(rgba16f) uniform image2D sceneImg;

ivec2 moveTo(int position, ivec2 coord) {
	if (_SliceScreen && position >= 0) {
		return coord;
	}

    int x = int(ap.game.screenSize.x);
    int y = int(ap.game.screenSize.y);
	
	if (position == 3) {
        coord = coord * 2;
    } else if (position == 4) {
        coord = ivec2(-x, 0) + coord*2;
    } else if (position == 1) {
        coord = ivec2(0, -y) + coord*2;
    } else if (position == 2) {
        coord = ivec2(-x, -y) + coord*2;
    } else if (position < 0) {
		coord = ivec2(-1);
	}
	
    return coord;
}
bool clip(ivec2 coord, int position) {
	ivec2 minimum = ivec2(0);
	ivec2 maximum = ivec2(ap.game.screenSize);

	if (_SliceScreen) {
		if (position == 3) {
			maximum /= 2;
		} else if (position == 4) {
			minimum.x = maximum.x/2;
			maximum.y /= 2;
		} else if (position == 1) {
			minimum.y = maximum.y/2;
			maximum.x /= 2;
		} else if (position == 2) {
			minimum = maximum/2;
		}
	}

	return all(lessThan(coord, maximum)) && all(greaterThanEqual(coord, minimum));
}

void main() {
	if (any(greaterThanEqual(gl_GlobalInvocationID.xy, ap.game.screenSize))) return;
	ivec2 coord = ivec2(gl_GlobalInvocationID.xy);

	vec4 color = texelFetch(sceneTex, coord, 0);
	float depth = texelFetch(mainDepthTex, coord, 0).r;
	vec3 posView = depthToViewPos(vec2(coord)/vec2(ap.game.screenSize), depth);
	vec3 posPlayer = (ap.camera.viewInv * vec4(posView,1)).xyz;

	if (!_DebugEnabled) {
		imageStore(sceneImg, coord, color);
		return;
	}
	ivec2 t;

	if (_ShowShadows) { 
		// color.rgb = calcShadow(posPlayer, vec3(0,1,0), 0).rrr;
		vec3 shadowView = (ap.celestial.view * vec4(posPlayer, 1)).xyz;
		vec4 shadowClip = ap.celestial.projection[0] * vec4(shadowView, 1.0);
		vec3 shadowNdc = distortShadow(shadowClip.xyz / shadowClip.w);
		vec3 shadowScreen = shadowNdc * 0.5 + 0.5;

		// Distorts z bias(Copied from pre-deferred)
		float zBias = Z_BIAS;
		// TODOEVENTUALLY: i should probably use a more surefire biasing method eventually
		zBias *= 1+(max(dot(vec3(0,1,0), normalize(ap.celestial.pos)), 0)); // Applies more bias on parallel surfaces
		zBias *= 1+(pow(((length(shadowNdc.xyz)+1)*4)-1, 2)*0.25); // Not battle tested

		float shadow = sampleShadow(shadowScreen, posPlayer, zBias, 0);
		
		color.rgb = shadow.rrr;
	}

	t = moveTo(_ShowDepth, coord);
    if (clip(t, _ShowDepth)) { color.rgb = clamp(vec3(depth-0.95)*20.0, 0, 1); }

    t = moveTo(_ShowRoughness, coord);
    if (clip(t, _ShowRoughness)) { color.rgb = vec3(Mat(color.rgb, texelFetch(gbufferTex, t, 0).rg).roughness); }

	t = moveTo(_ShowReflectance, coord);
    if (clip(t, _ShowReflectance)) { color.rgb = Mat(color.rgb, texelFetch(gbufferTex, t, 0).rg).f0; }

	t = moveTo(_ShowPorosity, coord);
    if (clip(t, _ShowPorosity)) { color.rgb = vec3(Mat(color.rgb, texelFetch(gbufferTex, t, 0).rg).porosity); }

	t = moveTo(_ShowEmission, coord);
    if (clip(t, _ShowEmission)) { color.rgb = vec3(Mat(color.rgb, texelFetch(gbufferTex, t, 0).rg).emission); }

	t = moveTo(_ShowNormals, coord);
    if (clip(t, _ShowNormals)) { color.rgb = Mat(color.rgb, texelFetch(gbufferTex, t, 0).rg).normals; }

	t = moveTo(_ShowAmbientOcclusion, coord);
    if (clip(t, _ShowAmbientOcclusion)) { color.rgb = vec3(Mat(color.rgb, texelFetch(gbufferTex, t, 0).rg).ao); }

	t = moveTo(_ShowHeight, coord);
    if (clip(t, _ShowHeight)) { color.rgb = vec3(Mat(color.rgb, texelFetch(gbufferTex, t, 0).rg).height); }

	t = moveTo(_ShowShadowMap, coord);
	ivec2 shadowmapRes = textureSize(shadowMap, 0).xy;
    if (clip(t, _ShowShadowMap) && all(lessThan(t, shadowmapRes))) { 
		float shadowDepth = texture(shadowMap, distortShadow(vec3(vec2(t)/vec2(shadowmapRes), 0)) ).r;
		if (shadowDepth < 1) color.rgb = shadowDepth.rrr; 
	}

	if (_DebugStats) {
		// TODONOWNOWNOWNOW: TJOS RN
		beginText(coord, ivec2(5, ap.game.screenSize.y - 40));
		printFloat(12.3123);
		endText(color.rgb);
	}
	
	if (color.a > 0) imageStore(sceneImg, coord, color);
}