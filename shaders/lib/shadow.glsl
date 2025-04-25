// Required Uniforms: shadowModelView, shadowProjection
#include "/settings/soft_shadows.glsl"
#include "/settings/lighting.glsl"
#include "/func/fade.glsl"
#include "/func/distortShadow.glsl"
#include "/func/goldenDiskSample.glsl"

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
        vec2 sampleOffset = goldenDiskSample(i, sampleCount) * offset;

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
    float depth = shadowScreenPos.z;
    
    float shadowedBy = 0; float shadowStrength = 1; float softnessStrength = 1;
    fadeShadows(playerPos, shadowStrength, softnessStrength);
    if (shadowStrength > 0) {
        #include "/snippets/PCSS.glsl"
    }
	return shadowedBy*shadowStrength;
}
#endif

#if SHADOW_FILTER == PCF
float baseSoftness = 0.002;

float sampleShadowPCF(vec3 shadowScreenPos, vec3 playerPos, float zBias) {
    shadowScreenPos.z -= zBias;
    
    float shadowedBy = 0; float shadowStrength = 1; float softnessStrength = 1;
    fadeShadows(playerPos, shadowStrength, softnessStrength);
    if (shadowStrength > 0) {
        shadowedBy = pcfSampleShadow(shadowScreenPos, SHADOW_SAMPLES, baseSoftness*SHADOW_SOFTNESS*softnessStrength); 
    }
	return shadowedBy*shadowStrength;
}
#endif

#if SHADOW_FILTER == Linear || SHADOW_FILTER == Nearest
float sampleShadowNormal(vec3 shadowScreenPos, vec3 playerPos, float zBias) {
    shadowScreenPos.z -= zBias;
    
    float shadowedBy = 0; float shadowStrength = 1;
    fadeShadows(playerPos, shadowStrength);
    if (shadowStrength > 0) {
        shadowedBy = 1.0 - sampleShadowMap(shadowScreenPos); 
    }

    return shadowedBy*shadowStrength;
}
#endif

// NOTE: We dont just make the algorithm specific functions this base name; to potentially allow other code to use algorithm-specific function and not only the user-set one
float sampleShadow(vec3 shadowScreenPos, vec3 posPlayer, float zBias) {
    #if SHADOW_FILTER <= Linear 
        return sampleShadowNormal(shadowScreenPos, posPlayer, zBias);
    #elif SHADOW_FILTER == PCF
        return sampleShadowPCF(shadowScreenPos, posPlayer, zBias);
    #elif SHADOW_FILTER == FixedSamplePCSS || SHADOW_FILTER == VariableSamplePCSS
        return sampleShadowPCSS(shadowScreenPos, posPlayer, zBias);
    #endif
}

float calcShadow(vec3 posPlayer, vec3 geoNormals) {
    #if SHADOWS == 0
        return 0;
    #else
    vec3 shadowView = (shadowModelView * vec4(posPlayer, 1)).xyz;
    // #ifdef DISTANT_HORIZONS
    vec4 oldShadowClip = shadowProjection * vec4(shadowView, 1);
    // #elif
    // vec4 oldShadowClip = dhProjection * vec4(shadowView, 1);
    // #endif
    vec3 shadowClip = distortShadow(oldShadowClip.xyz);
    vec3 shadowNdc = shadowClip.xyz / oldShadowClip.w;
    vec3 shadowScreen = shadowNdc * 0.5 + 0.5;

    // Distorts z bias(Copied from pre-deferred)
    float zBias = Z_BIAS;
    // TODOEVENTUALLY: i should probably use a more surefire biasing method eventually
    float distortion = (length(oldShadowClip.xyz))/(length(shadowClip));
    zBias *= 1+(max(dot(geoNormals, normalize(shadowLightPosition)), 0)); // Applies more bias on parallel surfaces
    zBias /= distortion; // Counter distorts zbias
    zBias *= 1+(pow(((length(shadowNdc.xyz)+1)*4)-1, 2)*0.25); // Not battle tested

    float shadow = sampleShadow(shadowScreen, posPlayer, zBias);
    
    return shadow;
    #endif
}