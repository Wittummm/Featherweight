#version 460 core

layout (local_size_x = ExposureSamplesX, local_size_y = ExposureSamplesY) in;

#include "/includes/shared/shared.glsl"
#include "/includes/func/color/srgb.glsl"
#include "/includes/func/color/luminance.glsl"

uniform sampler2D sceneTex;

shared uint data[2]; 

const float s = 100000;
const int sampleCount = ExposureSamplesX*ExposureSamplesY;
vec2 tileSize = vec2(1.0/ExposureSamplesX, 1.0/ExposureSamplesY);

const float minLogLum      = 13;
const float maxLogLum      = 23;
const float logLumRange    = maxLogLum - minLogLum;
const float rcpLogLumRange = 1.0 / logLumRange;

void main() {
	if (gl_GlobalInvocationID.xy == uvec2(0,0)) {
		data[0] = 0;
		data[1] = 0;
	}
	groupMemoryBarrier();

	vec2 center = gl_GlobalInvocationID.xy*tileSize + tileSize*0.5;
	float brightness = luminance(readScene(textureLod(sceneTex, center, 4).rgb)); // TODONOW: why does using mipmap brighten it up :/
	
	float toMiddle = distance(center, vec2(0.5))+1; // Very naive weight
	atomicAdd(data[0], uint(((log2(1e-4 + brightness) - minLogLum)*rcpLogLumRange*s)/toMiddle) );
	if (brightness <= 0) {
		atomicAdd(data[1], 1);
	}

	groupMemoryBarrier();
	if (gl_GlobalInvocationID.xy == uvec2(0,0)) {
		float averageLuminance = exp2(((data[0]/s)/(sampleCount-data[1]))*logLumRange + minLogLum);
		AverageLuminance = mix(averageLuminance, AverageLuminance, exp(-ExposureSpeed * ap.time.delta));
	}
}