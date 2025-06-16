// WARNING: This should not be included/used directly, instead it should use shadow0.glsl or shadow1.glsl

#include "/includes/func/fade.glsl"
#include "/includes/func/distortShadow.glsl"
#include "/includes/func/goldenDiskSample.glsl"

// CONFIGTODO: implement all below
#define ShadowSamples 5
#define SHADOW_SOFTNESS 1
#define ShadowFilter Linear
#define PresetPatternsPCF
#define SHADOWS 1
#define Z_BIAS 0.00007

////////////////////////////////
float pcfSampleShadow(vec3 coord, float sampleCount, float offset, int cascade) {
    float totalDepth = 0;

#ifdef PresetPatternsPCF
    switch (int(sampleCount)) {
        case 2:
            totalDepth += sampleShadowMap(coord - vec3(offset, offset, 0), cascade);
            totalDepth += sampleShadowMap(coord + vec3(offset, offset, 0), cascade);
            break;
        case 3:
            totalDepth += sampleShadowMap(coord + vec3(0, offset*1.155, 0), cascade);
            totalDepth += sampleShadowMap(coord + vec3(-offset, -offset*0.577, 0), cascade);
            totalDepth += sampleShadowMap(coord + vec3(offset, -offset*0.577, 0), cascade);
            break;
        case 5:
            totalDepth += sampleShadowMap(coord, cascade)*1.5;
            totalDepth += sampleShadowMap(coord + vec3(-offset, 0, 0), cascade)*0.875;
            totalDepth += sampleShadowMap(coord + vec3(offset, 0, 0), cascade)*0.875;
            totalDepth += sampleShadowMap(coord + vec3(0, -offset, 0), cascade)*0.875;
            totalDepth += sampleShadowMap(coord + vec3(0, offset, 0), cascade)*0.875;
            break;
        case 9:
            offset *= 0.5; // No clue why need to halve to match up
            totalDepth += sampleShadowMap(coord, cascade);
            totalDepth += sampleShadowMap(coord - offset*0.5, cascade);
            totalDepth += sampleShadowMap(coord + vec3(-offset*0.5, offset*0.5, 0), cascade);
            totalDepth += sampleShadowMap(coord + vec3(offset*0.5, -offset*0.5, 0), cascade);
            totalDepth += sampleShadowMap(coord + offset*0.5, cascade);

            totalDepth += sampleShadowMap(coord + vec3(-offset*0.8, 0, 0), cascade);
            totalDepth += sampleShadowMap(coord + vec3(offset*0.8, 0, 0), cascade);
            totalDepth += sampleShadowMap(coord + vec3(0, -offset*0.8, 0), cascade);
            totalDepth += sampleShadowMap(coord + vec3(0, offset*0.8, 0), cascade);
            break;
        default:
#endif
    for (int i = 0; i < sampleCount; ++i) {
        vec2 sampleOffset = goldenDiskSample(i, sampleCount) * offset;

        totalDepth += sampleShadowMap(coord + vec3(sampleOffset.xy,0), cascade);
    }
#ifdef PresetPatternsPCF
            break;
        }
#endif
    return 1 - (totalDepth/sampleCount);
}

#if ShadowFilter == PCF
float baseSoftness = 0.002;

float sampleShadowPCF(vec3 shadowScreenPos, vec3 playerPos, float zBias, int cascade) {
    shadowScreenPos.z -= zBias;
    
    float shadowedBy = 0; float shadowStrength = 1; float softnessStrength = 1;
    fadeShadows(playerPos, shadowStrength, softnessStrength);
    if (shadowStrength > 0) {
        shadowedBy = pcfSampleShadow(shadowScreenPos, ShadowSamples, baseSoftness*SHADOW_SOFTNESS*softnessStrength, cascade); 
    }
	return shadowedBy*shadowStrength;
}
#endif

#if ShadowFilter == Linear || ShadowFilter == Nearest
float sampleShadowNormal(vec3 shadowScreenPos, vec3 playerPos, float zBias, int cascade) {
    shadowScreenPos.z -= zBias;
    
    float shadowedBy = 0; float shadowStrength = 1;
    fadeShadows(playerPos, shadowStrength);
    if (shadowStrength > 0) {
        shadowedBy = 1.0 - sampleShadowMap(shadowScreenPos, cascade); 
    }

    return shadowedBy*shadowStrength;
}
#endif

// NOTE: We dont just make the algorithm specific functions this base name; to potentially allow other code to use algorithm-specific function and not only the user-set one
float sampleShadow(vec3 shadowScreenPos, vec3 posPlayer, float zBias, int cascade) {
    #if ShadowFilter <= Linear 
        return sampleShadowNormal(shadowScreenPos, posPlayer, zBias, cascade);
    #elif ShadowFilter == PCF
        return sampleShadowPCF(shadowScreenPos, posPlayer, zBias, cascade);
    #endif
}

float calcShadow(vec3 posPlayer, vec3 geoNormals, int cascade) {
    #if SHADOWS == 0 
        return 0;
    #else
    vec3 shadowView = (ap.celestial.view * vec4(posPlayer, 1)).xyz;
    vec4 shadowClip = ap.celestial.projection[cascade] * vec4(shadowView, 1.0);
    vec3 shadowNdc = distortShadow(shadowClip.xyz / shadowClip.w);
    vec3 shadowScreen = shadowNdc * 0.5 + 0.5;

    // Distorts z bias(Copied from pre-deferred)
    float zBias = Z_BIAS;
    // TODOEVENTUALLY: i should probably use a more surefire biasing method eventually
    zBias *= 1+(max(dot(geoNormals, normalize(ap.celestial.pos)), 0)); // Applies more bias on parallel surfaces
    zBias *= 1+(pow(((length(shadowNdc.xyz)+1)*4)-1, 2)*0.25); // Not battle tested

    float shadow = sampleShadow(shadowScreen, posPlayer, zBias, cascade);
    
    return shadow;
    #endif
}