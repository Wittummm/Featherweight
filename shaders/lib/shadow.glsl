#include "/settings/shadows.glsl"
#include "/settings/lighting.glsl"
#include "/func/fade.glsl"
#include "/func/distortShadow.glsl"
uniform sampler2D noisetex;
const float minShadow = 0.005;

vec2 goldenDiskSample(float index, float count) {
    const float theta = index * 2.4;
    const float r = sqrt((index + 0.5) / count);

    return vec2(r * cos(theta), r* sin(theta));
}

////////////////////////////////
float sampleShadowMap(vec2 coord) {
    return texture(shadowtex0, coord).r;
}

float sampleShadowMap(vec3 coord) {
    return texture(shadowtex0HW, coord);
}

float pcfSampleShadow(vec3 coord, float sampleCount, float offset) {
    float totalDepth = 0;

#if PRESET_PCF_PATTERNS == On
    switch (int(sampleCount)) {
        case 2:
            totalDepth += sampleShadowMap(coord - vec3(offset, offset, 0));
            totalDepth += sampleShadowMap(coord + vec3(offset, offset, 0));
            break;
        case 3:
            totalDepth += sampleShadowMap(coord + vec3(0, offset*1.155, 0));
            totalDepth += sampleShadowMap(coord + vec3(-offset, -offset*0.577, 0));
            totalDepth += sampleShadowMap(coord + vec3(offset, -offset*0.577, 0));
            break;
        case 5:
            totalDepth += sampleShadowMap(coord)*1.5;
            totalDepth += sampleShadowMap(coord + vec3(-offset, 0, 0))*0.875;
            totalDepth += sampleShadowMap(coord + vec3(offset, 0, 0))*0.875;
            totalDepth += sampleShadowMap(coord + vec3(0, -offset, 0))*0.875;
            totalDepth += sampleShadowMap(coord + vec3(0, offset, 0))*0.875;
            break;
        case 9:
            offset *= 0.5; // No clue why need to halve to match up
            totalDepth += sampleShadowMap(coord);
            totalDepth += sampleShadowMap(coord - offset*0.5);
            totalDepth += sampleShadowMap(coord + vec3(-offset*0.5, offset*0.5, 0));
            totalDepth += sampleShadowMap(coord + vec3(offset*0.5, -offset*0.5, 0));
            totalDepth += sampleShadowMap(coord + offset*0.5);

            totalDepth += sampleShadowMap(coord + vec3(-offset*0.8, 0, 0));
            totalDepth += sampleShadowMap(coord + vec3(offset*0.8, 0, 0));
            totalDepth += sampleShadowMap(coord + vec3(0, -offset*0.8, 0));
            totalDepth += sampleShadowMap(coord + vec3(0, offset*0.8, 0));
            break;
        default:
#endif
    for (int i = 0; i < sampleCount; ++i) {
        const vec2 sampleOffset = goldenDiskSample(i, sampleCount) * offset;

        totalDepth += sampleShadowMap(coord + vec3(sampleOffset.xy,0));
    }
#if PRESET_PCF_PATTERNS == On
            break;
        }
#endif
    return 1 - (totalDepth/sampleCount);
}

// ISSUE: Should counter distort the space
#if SHADOW_FILTER == FixedSamplePCSS || SHADOW_FILTER == VariableSamplePCSS
float sampleShadowPCSS(vec3 shadowScreenPos, vec3 playerPos, float zBias) {
    shadowScreenPos.z -= zBias;
    const float depth = shadowScreenPos.z;
    
    float shadowedBy = 0; float shadowStrength = 1; float softnessStrength = 1;
    fadeShadows(playerPos, shadowStrength, softnessStrength);
    if (shadowStrength > 0) {
        #include "/snippets/PCSS.glsl"
    }
	if (shadowedBy >= minShadow) { return shadowedBy*shadowStrength; }
}
#endif

#if SHADOW_FILTER == PCF
const float baseSoftness = 0.002;

float sampleShadowPCF(vec3 shadowScreenPos, vec3 playerPos, float zBias) {
    shadowScreenPos.z -= zBias;
    
    float shadowedBy = 0; float shadowStrength = 1; float softnessStrength = 1;
    fadeShadows(playerPos, shadowStrength, softnessStrength);
    if (shadowStrength > 0) {
        shadowedBy = pcfSampleShadow(shadowScreenPos, SHADOW_SAMPLES, baseSoftness*SHADOW_SOFTNESS*softnessStrength); 
    }
	if (shadowedBy >= minShadow) { return shadowedBy*shadowStrength; }
}
#endif

#if SHADOW_FILTER == Linear || SHADOW_FILTER == Nearest
float sampleShadow(vec3 shadowScreenPos, vec3 playerPos, float zBias) {
    shadowScreenPos.z -= zBias;
    
    float shadowedBy = 0; float shadowStrength = 1;
    fadeShadows(playerPos, shadowStrength);
    if (shadowStrength > 0) {
        shadowedBy = 1 - sampleShadowMap(shadowScreenPos); 
    }
	if (shadowedBy >= minShadow) { return shadowedBy*shadowStrength; }
}
#endif