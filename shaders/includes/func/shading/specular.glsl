/* Sources: 
 [1] https://graphicrants.blogspot.com/2013/08/specular-brdf-reference.html
 [2] https://naos-be.zcu.cz/server/api/core/bitstreams/c2d8b0a7-9947-4458-98e3-d3f8df920153/content
 [x] http://www.codinglabs.net/article_physically_based_rendering_cook_torrance.aspx
Naming:
    outDir - outgoing direction of light(ie surface to eye)
    inDir - incoming direction of light(ie from light source to surface)
Dev Notes:
 - Precomputed F0 value suffices and cannot be differtentiated with the naked eye, so a fresnel function for conductors is not needed.
*/

#ifndef specular_glsl
#define specular_glsl
#include "/includes/shared/math_const.glsl"

// Trowbridge-Reitz (GGX) [1]
float distributionGGX(float NdotH, float alpha) {
    float alpha2 = alpha*alpha;
    return alpha2 / (PI*pow(NdotH*NdotH*(alpha2 - 1.0) + 1.0, 2));
}

// Schlick-Beckmann-GGX [1]
float geometric(float NdotM, float alpha) {
    float k = alpha*0.5;
    return NdotM / (NdotM*(1-k) + k);
}

// Schlick Fresnel [1]
vec3 fresnelSchlick(float NdotV, vec3 f0) {
    return f0 + (1.0 - f0) * pow(1.0 - NdotV, 5.0);
}
vec3 calcSpecular(vec3 inDir, vec3 outDir, vec3 normal, float roughness, vec3 f0, out vec3 kS) {
    // roughness = max(roughness, 0.005);
    float alpha = roughness*roughness;
    vec3 halfway = normalize(inDir + outDir);

    float NdotL = max(dot(normal, inDir), 0);
    float NdotV = max(dot(normal, outDir), 0.00001);
    float NdotH = max(dot(normal, halfway), 0);

    vec3 fresnel = fresnelSchlick(NdotV, f0);
    vec3 radiance = (distributionGGX(NdotH, alpha) * geometric(NdotV, alpha) * geometric(NdotL, alpha) * fresnel) / (4*NdotL*NdotV);

    kS += fresnel;
    return max(radiance, 0);
}

#endif