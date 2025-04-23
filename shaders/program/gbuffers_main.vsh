#include "/snippets/version.glsl"

uniform vec3 chunkOffset;
uniform sampler2D lightmap;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferModelView;

#ifndef DISTANT_HORIZONS_SHADER
	uniform int renderStage;
	uniform mat4 modelViewMatrix;
	uniform mat4 projectionMatrix;
	uniform sampler2D noisetex; // temp, actually use runtime noise
	uniform float frameTimeCounter;
	uniform vec3 cameraPosition;

	in vec2 vaUV0;
	in ivec2 vaUV2;
	in vec3 vaNormal;
	in vec3 vaPosition;
	in vec4 vaColor;
	in vec4 at_tangent;

	out vec2 texCoord;
	out vec4 tangent;
	#ifdef PROGRAM_TRANSLUCENT
		uniform sampler2D depthtex1;
		uniform int biome;
		uniform float waveHeightMin;
		uniform float waveHeightMax;
		uniform float waveSpeedMin;
		uniform float waveSpeedMax;
		uniform float waveScaleMin;
		uniform float waveScaleMax;
		uniform float waveScaleMagic;
		uniform float waveSpeedMagic;
		uniform float far;
		uniform int isEyeInWater;
		in vec2 mc_Entity;
		out vec2 blockType;
		#include "/func/noise/noiseSimplex.glsl"
		#include "/func/depthToViewPos.glsl"
		#include "/settings/water.glsl"
		#include "/lib/metadata.glsl"
	#endif
#endif

out vec2 lightmapCoord;
out vec3 vertNormal;
out vec4 vertColor;
out vec3 vertPosition;

// NOTE: wrapTime must be low 10-30 we could go higher if we used a random direction to scroll in using a `noise(time)`
const float wrapTime = 20; // Scroll direction back and forth time

void main() {
	#include "/snippets/core_to_compat.vsh"

	vec3 viewPos = (modelViewMatrix * vec4(vaPosition + chunkOffset, 1)).xyz;
	vec4 clipPos = projectionMatrix * vec4(viewPos, 1);
	vec3 screenPos = (clipPos.xyz / clipPos.w)*0.5 + 0.5;
	#ifdef PROGRAM_TRANSLUCENT 
		blockType = mc_Entity;
		if (mc_Entity.x == 1) { // Water
			vec3 playerPos = (gbufferModelViewInverse * vec4(viewPos, 1)).xyz;

			// CODE: 12jk3h
			// Might rework this idk
			if (isEyeInWater == 1 && all(lessThan(abs(playerPos), vec3(5, 30, 5)))) { 
				waterColor += vaColor.rgb; 
				waterCount++;
			}
		#if WATER_WAVES == On
			vec3 worldPos = playerPos + cameraPosition;
			vec2 fragCoord = screenPos.xy;
			vec3 offset = vec3(0);
			// ISSUE: When occluded by entites it will act weird or things that arent solid will still influence shallowness like boats, kelp, players
			// Above issue could be mitigated by writing to custom low resolution depth buffer(1/4) that only stores terrain depth but is not implemented rn for performance and lazy :)
			vec4 depths0 = textureGather(depthtex1, fragCoord); // ISSUE NOTE: This should use depthtex2, but it doesnt exist for some reason even though at `gbuffers_water` depthtex1&2 should be perfectly fine. (Iris 1.8.8 MC 1.21.4)
			float terrainDepth = min(depths0.x, min(depths0.y, min(depths0.z, depths0.w)));

			// NOTE: The water wave displacement is still mediocre
			float deepness = terrainDepth < screenPos.z+0.00015 ? 0.8 : clamp(distance(viewPos, depthToViewPos(fragCoord, terrainDepth))*0.05, 0, 1);

			float waveHeight = mix(waveHeightMin, waveHeightMax, deepness); 
			float waveSpeed = mix(waveSpeedMin, waveSpeedMax, deepness); 
			float waveScale = mix(waveScaleMin, waveScaleMax, deepness); 

			vec3 noisePos = playerPos*waveScale + cameraPosition*waveScaleMagic;
			float time = ((sin(frameTimeCounter/wrapTime)+1)*wrapTime*0.5)+0.5;
			float noiseSpeed = time*waveSpeed*0.5 + time*waveSpeedMagic*0.5;
			float wave = (noiseSimplex(noisePos*vec3(1,0.1,1) + noiseSpeed*vec3(1,0.5,1))*0.5 + 0.5);
			offset.y -= wave*waveHeight;

			viewPos = (gbufferModelView * vec4(worldPos - cameraPosition + offset, 1)).xyz;
			clipPos = projectionMatrix * vec4(viewPos, 1);
			screenPos = (clipPos.xyz / clipPos.w)*0.5 + 0.5;
		#endif
		}
	#endif

	vec2 lightLevel = (textureMatrix2 * vec4(vaUV2, 0.0, 1.0)).xy;
	vec3 light = texture(lightmap, lightLevel).rgb;

#ifndef DISTANT_HORIZONS_SHADER
	texCoord = vaUV0;
	tangent = at_tangent;
#endif
	lightmapCoord = lightLevel;
	vertPosition = viewPos.xyz;
	vertNormal = vaNormal;
	gl_Position = clipPos;

	vertColor = vec4(vaColor.rgb * vaColor.a * light, 1);
}