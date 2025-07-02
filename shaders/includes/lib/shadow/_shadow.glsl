// WARNING: This should not be included/used directly, instead it should use shadow0.glsl or shadow1.glsl

#include "/includes/func/fade.glsl"
#include "/includes/func/shadows/distortShadow.glsl"
#include "/includes/func/goldenDiskSample.glsl"
#include "/includes/func/shadows/getCascade.glsl"

////////////////////////////////
float pcfSampleShadow(vec3 coord, float sampleCount, float offset, int cascade) {
    float totalDepth = 0;

    for (int i = 0; i < sampleCount; ++i) {
        vec2 sampleOffset = goldenDiskSample(i, sampleCount) * offset;

        totalDepth += sampleShadowMap(coord + vec3(sampleOffset.xy,0), cascade);
    }
    return 1 - (totalDepth/sampleCount);
}

const float baseSoftness = 0.002;
float sampleShadowPCF(vec3 shadowScreenPos, int cascade) {
    return pcfSampleShadow(shadowScreenPos, ShadowSamples, baseSoftness*ShadowSoftness, cascade); 
}

float sampleShadowNormal(vec3 shadowScreenPos, int cascade) {
    if (ShadowFilter == 0) {
        return step(sampleShadowMapNearest(shadowScreenPos, cascade), shadowScreenPos.z);
    } else {
        return 1.0 - sampleShadowMap(shadowScreenPos, cascade); 
    }
}

// NOTE: We dont just make the algorithm specific functions this base name; to potentially allow other code to use algorithm-specific function and not only the user-set one
float sampleShadow(vec3 shadowScreenPos, int cascade) {
    if (ShadowFilter <= 1) {
        return sampleShadowNormal(shadowScreenPos, cascade);
    } else if (ShadowFilter == 2) {
        return sampleShadowPCF(shadowScreenPos, cascade);
    }
}

float calcShadow(vec3 posPlayer, vec3 normalsView) {
    #ifndef ShadowsEnabled
        return 0;
    #else
    float shadowStrength = 1;
    fadeShadows(posPlayer, shadowStrength);
    if (shadowStrength > 0) {

        vec3 shadowView = (ap.celestial.view * vec4(posPlayer, 1)).xyz;
        int cascade = getCascade(shadowView);
        if (cascade == -1) return 0;

        vec4 shadowClip = ap.celestial.projection[cascade] * vec4(shadowView, 1.0);
        float distortFac;
        shadowClip.xyz = distortShadow(shadowClip.xyz, distortFac);

        /// Z Biasing
        float zBias = ShadowBias;
        zBias *= distortFac*(cascade+1.0); // CREDIT: @builderb0y https://discord.com/channels/237199950235041794/1100010778133794827/1114276461856174121

        vec3 lightDir = normalize(ap.celestial.pos);
        vec2 lightDirWorld = abs(normalize((mat3(ap.camera.viewInv) * lightDir).xz));
       
        float d = abs(dot(normalsView, lightDir));
        zBias *= pow(15, d); // NOTE: Biasing along normals, instead of depending on normals is probably better as it require less sharp pushing, but we dont have access to geometry normals so this isnst possible currently
        zBias *= 1+pow((1.0-max(lightDirWorld.x, lightDirWorld.y))*2.0, 1.5)*18; // If light is diagonal, then bias more as it aliases

        shadowClip.z -= zBias;
        ////////////////
        vec3 shadowNdc = shadowClip.xyz / shadowClip.w;
        vec3 shadowScreen = shadowNdc * 0.5 + 0.5;

        float shadow = sampleShadow(shadowScreen, cascade);
        return shadow*shadowStrength;
    }
    return 0;
    #endif
}