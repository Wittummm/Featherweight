/* 
Sources:
 [1] https://schuttejoe.github.io/post/disneybsdf/#clearcoat

Clearcoat is a clear thin layer on top of the material,
it uses a simple shading model as it is not foundational to the material itself
*/

#include "/includes/shared/math_const.glsl"

float fresnelSchlick(float cosTheta, float f0) {
    return f0 + (1.0 - f0) * pow(1.0 - cosTheta, 5.0);
}

float distributionGTR1(float alpha2, float NdotH) {
    float alpha2MinusOne = alpha2 - 1;
    // not sure if log or log2
    return alpha2MinusOne / (PI * log2(alpha2) * (1 + alpha2MinusOne*NdotH*NdotH));
}

float geometricSmithGGX(float alpha2, float NdotM) {
    return 1.0 / (NdotM + sqrt(alpha2 + NdotM - alpha2*NdotM*NdotM));
}

// Defaults: roughness = 0.25, f0 = 0.04
vec3 clearcoat(vec3 coatColor, vec3 inDir, vec3 outDir, vec3 normal, float roughness, float f0) {
    float alpha2 = roughness*roughness*roughness*roughness;

    vec3 halfway = normalize(inDir+outDir);
    float NdotL = max(dot(normal, inDir), 0);
    float NdotV = max(dot(normal, outDir), 0);
    float NdotH = max(dot(normal, halfway), 0);
    float cosTheta = max(dot(inDir, halfway), 0); // questionable if correct

    return coatColor * (distributionGTR1(alpha2, NdotH)-0.04) * fresnelSchlick(cosTheta,f0) * geometricSmithGGX(alpha2, NdotL) * geometricSmithGGX(alpha2, NdotV) * 0.25;
}