/* Sources:
 [x] https://ubm-twvideo01.s3.amazonaws.com/o1/vault/gdc2017/Presentations/Hammon_Earl_PBR_Diffuse_Lighting.pdf #113 #135
 [1] https://cs418.cs.illinois.edu/website/text/disney-brdf.html
 [2] https://media.disneyanimation.com/uploads/production/publication_asset/48/asset/s2012_pbs_disney_brdf_notes_v3.pdf
*/

#include "/includes/shared/math_const.glsl"

// Disney/Burley Diffuse [1] [2/5.3]
float diffuseBurley(float NdotL, float NdotV, float LdotH, float roughness) {
    // ISSUE: This sometimes will have flickering/aliasing-like artifacts possibly due to mipmaps as roughness is acting weirdly
    float f90MinusOne = 0.5 + 2.0*roughness*LdotH*LdotH - 1.0;
    return ONE_OVER_PI*(1.0 + f90MinusOne*pow(1-NdotL, 5))*(1.0 + f90MinusOne*pow(1-NdotV, 5));
}

float calcDiffuseFactor(vec3 inDir, vec3 outDir, vec3 normal, float roughness) {
    vec3 halfway = normalize(inDir + outDir);
    float NdotL = max(dot(normal, inDir), 0.0);
    float NdotV = max(dot(normal, outDir), 0.0);
    float LdotH = max(dot(inDir, halfway), 0.0);

    // Lambert + Burley Diffuse
    float diffuseFac = PI * NdotL * diffuseBurley(NdotL, NdotV, LdotH, roughness);

    return diffuseFac;
}