#version 460 core
layout (local_size_x = 16, local_size_y = 16) in;

#include "/includes/shared/shared.glsl"
#include "/includes/shared/shadowmap_uniforms.glsl"

uniform usampler2D gbufferTex;
#define INCLUDE_READ_GBUFFER
#include "/includes/func/buffers/gbuffer.glsl"
#include "/includes/func/buffers/data0.glsl"
#include "/includes/lib/material.glsl"
#include "/includes/func/misc/linearizeDepth.glsl"
#include "/includes/lib/shadow/shadow0.glsl"
#include "/includes/func/depthToViewPos.glsl"
#include "/includes/func/shadows/distortShadow.glsl"
#include "/includes/lib/text_renderer.glsl"
#include "/includes/func/shadows/getCascade.glsl"
#include "/includes/func/color/srgb.glsl"

layout(binding = 1) uniform debugConfig {
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
	int _ShowGeometryNormals;
	int _ShowLightLevel;
	
	bool _ShowShadows;
	bool _ShowShadowCascades;
	int _ShadowCascadeIndex;

	float _DebugUIScale;
	bool _DisplayAtmospheric;
	bool _DisplaySunlightColors;
	bool _DisplayCameraData;
};
layout(std430, binding = 1) buffer _histogram {
    uint histogram[];
};

float calcExposure() {
    // CREDIT: SOURCE: https://bruop.github.io/exposure/
    const float sensorSensitivity = 100;
    const float lightMeterCalibration = 12.5;
    const float vignetteAttenuation = 0.65;
    float ev100 = log2((sensorSensitivity/lightMeterCalibration)*AverageLuminance);
    float maxLuminance = (78.0/(vignetteAttenuation*sensorSensitivity)) * exp2(ev100);

    return 1.0/maxLuminance;
}

uniform sampler2D sceneTex;
uniform sampler2D mainDepthTex;
uniform usampler2D dataTex0;

layout(SCENE_FORMAT) uniform image2D sceneImg;

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

vec2 scale(vec2 coord) {
	return coord/max(_DebugUIScale, 0.001);
}

void newStat(vec4 uiCoord, inout int lineCounter) {
	beginText(ivec2(uiCoord.xy), ivec2(uiCoord.zw));
	printLine(lineCounter*2);
	lineCounter++;
}

void endColorStat(vec3 displayCol, inout vec4 color) {
	printString((_colon,_block,_space));
	color.rgb = mix(color.rgb, mix(text.result.rgb, displayCol.rgb, round(text.result.a)), text.result.a);
}

void endColorStat(vec4 displayCol, inout vec4 color) {
	printString((_colon,_block,_space));
	printFloat(displayCol.a); printString((_x));
	color.rgb = mix(color.rgb, mix(text.result.rgb, displayCol.rgb, round(text.result.a)), text.result.a);
}

void main() {
	if (any(greaterThanEqual(gl_GlobalInvocationID.xy, ap.game.screenSize))) return;
	ivec2 coord = ivec2(gl_GlobalInvocationID.xy);
	ivec2 squareCoord = ivec2(coord * vec2(ap.game.screenSize.x/ap.game.screenSize.y, 1)); // scale to square grid based on height

	vec4 color = vec4(-1);
	float depth = texelFetch(mainDepthTex, coord, 0).r;
	vec3 posView = depthToViewPos(vec2(coord)/vec2(ap.game.screenSize), depth);
	vec3 posPlayer = (ap.camera.viewInv * vec4(posView,1)).xyz;

	if (!_DebugEnabled) {
		color = readScene(texelFetch(sceneTex, coord, 0));
		imageStore(sceneImg, coord, writeScene(color));
		return;
	}
	ivec2 t;

	vec3 shadowView = (ap.celestial.view * vec4(posPlayer, 1)).xyz;
	if (_ShowShadows) { 
		// vec4 shadowClip = ap.celestial.projection[0] * vec4(shadowView, 1.0);
		// float distortFac;
		// shadowClip.xyz = distortShadow(shadowClip.xyz, distortFac);
		// vec3 shadowNdc = shadowClip.xyz / shadowClip.w;
		// vec3 shadowScreen = shadowNdc*0.5 + 0.5;

		// float shadow = sampleShadow(shadowScreen, 0);
		float shadow = calcShadow(posPlayer, normalize(ap.celestial.upPos));
		
		// color.rgb = shadowView*0.01;
		color.rgb = shadow.rrr;
		// color.rgb = vec3(distance(oldShadowNdc, shadowNdc));
		// color.rgb = vec3(log(distortFac+2)*0.1);
		// color.rgb = log(length(shadowClip.xyz)).rrr*0.1;
	}

	if (_ShowShadowCascades) { 
		int currentCascade = getCascade(shadowView);
		if (currentCascade != -1) {
			float display = float(currentCascade)/ShadowCascadeCount;

			color.rgb = mix(color.rgb, vec3(1-display), 0.1);
		}
	}

	vec3 baseNorm = vec3(0,1,0);
	t = moveTo(_ShowDepth, coord);
    if (clip(t, _ShowDepth)) { color.rgb = linearizeDepthFull(texelFetch(mainDepthTex, t, 0).r, 0.0005, ap.camera.far).rrr; }

	#ifdef PBREnabled
    t = moveTo(_ShowRoughness, coord);
    if (clip(t, _ShowRoughness)) { color.rgb = vec3(Mat(color.rgb, baseNorm, texelFetch(gbufferTex, t, 0)).roughness); }

	t = moveTo(_ShowReflectance, coord);
    if (clip(t, _ShowReflectance)) { color.rgb = Mat(color.rgb, baseNorm, texelFetch(gbufferTex, t, 0)).f0; color.a = 1; }

	t = moveTo(_ShowPorosity, coord);
    if (clip(t, _ShowPorosity)) { color.rgb = vec3(Mat(color.rgb, baseNorm, texelFetch(gbufferTex, t, 0)).porosity);  color.a = 1;}

	t = moveTo(_ShowEmission, coord);
    if (clip(t, _ShowEmission)) { color.rgb = vec3(Mat(color.rgb, baseNorm, texelFetch(gbufferTex, t, 0)).emission); }

	t = moveTo(_ShowNormals, coord);
    if (clip(t, _ShowNormals)) { color.rgb = Mat(color.rgb, baseNorm, texelFetch(gbufferTex, t, 0)).normals; }

	t = moveTo(_ShowAmbientOcclusion, coord);
    if (clip(t, _ShowAmbientOcclusion)) { color.rgb = vec3(Mat(color.rgb, baseNorm, texelFetch(gbufferTex, t, 0)).ao); }

	t = moveTo(_ShowHeight, coord);
    if (clip(t, _ShowHeight)) { color.rgb = vec3(Mat(color.rgb, baseNorm, texelFetch(gbufferTex, t, 0)).height); }
	#endif
	
	t = moveTo(_ShowGeometryNormals, coord);
    if (clip(t, _ShowGeometryNormals)) { 
		vec3 normals; vec2 lightLevel;
		readData0(texelFetch(dataTex0, t, 0), normals, lightLevel);
		color.rgb = vec3(normals); 
	}

	t = moveTo(_ShowLightLevel, coord);
    if (clip(t, _ShowLightLevel)) { 
		vec3 normals; vec2 lightLevel;
		readData0(texelFetch(dataTex0, t, 0), normals, lightLevel);
		color.rgb = vec3(lightLevel, 0); 
	}

	#ifdef ShadowsEnabled
	t = moveTo(_ShowShadowMap, coord);
	ivec2 shadowmapRes = textureSize(shadowMap, 0).xy;
    if (clip(t, _ShowShadowMap) && all(lessThan(t, shadowmapRes))) { 
		// vec3 pos = distortShadow(vec3(vec2(t)/vec2(shadowmapRes), 0));
		vec3 pos = vec3(vec2(t)/vec2(shadowmapRes), 0);
		pos.z = _ShadowCascadeIndex;

		float shadowDepth = texture(shadowMap, pos).r;
		color.rgb = shadowDepth.rrr * (shadowDepth < 1 ? 1 : 0.5); 
	}
	#endif

	// Visualize Settings //
	vec4 uiCoord = vec4(scale(coord), scale(ivec2(10, ap.game.screenSize.y - 10)));
	int line = 0;

	if (_DebugStats) {
		newStat(uiCoord, line);
		printFloat(ap.time.delta*1000); printString((_space, _m, _s));
		endText(color.rgb);

		newStat(uiCoord, line);
		printString((_N,_e,_a,_r,_minus,_F,_a,_r,_colon)); 
		printString((_opsqr)); 
		printFloat(ap.camera.near); 
		printString((_comma)); 
		printFloat(ap.camera.far);
		printString((_clsqr)); 
		endText(color.rgb);

		#ifdef ShadowsEnabled
		newStat(uiCoord, line);
		printString((_S,_h,_a,_d,_o,_w,_space,_r,_e,_s,_colon,_opsqr));
		printIvec2(textureSize(shadowMap, 0).xy);
		printString((_clsqr,_x));
		printInt(ShadowCascadeCount);
		endText(color.rgb);
		#else
		newStat(uiCoord, line);
		printString((_S,_h,_a,_d,_o,_w,_s,_colon,_O,_f,_f));
		endText(color.rgb);
		#endif
	}
	if (_DisplayAtmospheric) {
		// Light Color
		newStat(uiCoord, line);
		printString((_L,_i,_g,_h,_t,_space,_C,_o,_l,_o,_r));
		endColorStat(LightColor, color);
		// Ambient Color
		newStat(uiCoord, line);
		printString((_A,_m,_b,_i,_e,_n,_t,_space,_C,_o,_l,_o,_r))
		endColorStat(AmbientColor, color);

		newStat(uiCoord, line);
		printString((_R,_a,_i,_n,_colon,_space)); printFloat(ap.world.rain);
		endText(color.rgb);
	}
	if (_DisplayCameraData) {
		newStat(uiCoord, line);
		printString((_A,_v,_g,_space,_L,_u,_m,_colon)); 
		printFloat(AverageLuminance);
		endText(color.rgb);

		newStat(uiCoord, line);
		printString((_C,_e,_n,_t,_e,_r,_space,_R,_G,_B,_colon)); 
		printVec3(readScene(texture(sceneTex, vec2(0.5)).rgb));
		endText(color.rgb);
	}
	if (_DisplaySunlightColors) {
		uiCoord *= 1.75; line = int(line*1.75);
		newStat(uiCoord, line); // Spacing

		newStat(uiCoord, line);
		printString((_S,_u,_n,_r,_i,_s,_e)); 
		endColorStat(LightSunrise, color); newStat(uiCoord, line);
		printString((_M,_o,_r,_n,_i,_n,_g)); 
		endColorStat(LightMorning, color); newStat(uiCoord, line);
		printString((_N,_o,_o,_n)); 
		endColorStat(LightNoon, color); newStat(uiCoord, line);
		printString((_A,_f,_t,_e,_r,_n,_o,_o,_n)); 
		endColorStat(LightAfternoon, color); newStat(uiCoord, line);
		printString((_S,_u,_n,_s,_e,_t)); 
		endColorStat(LightSunset, color); newStat(uiCoord, line);
		printString((_N,_i,_g,_h,_t,_S,_t,_a,_r,_t)); 
		endColorStat(LightNightStart, color); newStat(uiCoord, line);
		printString((_M,_i,_d,_n,_i,_g,_h,_t)); 
		endColorStat(LightMidnight, color); newStat(uiCoord, line);
		printString((_N,_i,_g,_h,_t,_E,_n,_d)); 
		endColorStat(LightNightEnd, color); newStat(uiCoord, line);
		printString((_R,_a,_i,_n)); 
		endColorStat(LightRain, color);
		
		uiCoord /= 1.75; line = int(ceil(line/1.75));
	}

	if (all(lessThanEqual(color, vec4(-1)))) {
		color = readScene(texelFetch(sceneTex, coord, 0));
	} else {
		color *= 25000;
		color.a = 1;
	}

	if (color.a > 0) imageStore(sceneImg, coord, writeScene(color));
}