/* Sources:
 [x] https://ubm-twvideo01.s3.amazonaws.com/o1/vault/gdc2017/Presentations/Hammon_Earl_PBR_Diffuse_Lighting.pdf #113 #135
 [1] https://cs418.cs.illinois.edu/website/text/disney-brdf.html
 [2] https://media.disneyanimation.com/uploads/production/publication_asset/48/asset/s2012_pbs_disney_brdf_notes_v3.pdf
*/

// Disney/Burley Diffuse [1] [2/5.3]
float diffuseBurley(const float NdotL, const float NdotV, const float LdotH, const float roughness) {
    // ISSUE: This sometimes will have flickering/aliasing-like artifacts possibly due to mipmaps as roughness is acting weirdly
    const float f90MinusOne = 0.5 + 2.0*roughness*LdotH*LdotH - 1.0;
    return ONE_OVER_PI*(1.0 + f90MinusOne*pow(1-NdotL, 5))*(1.0 + f90MinusOne*pow(1-NdotV, 5));
}

float calcDiffuseFactor(vec3 color, const vec3 inDir, const vec3 outDir, const vec3 normal, const float roughness) {
    const vec3 halfway = normalize(inDir + outDir);
    const float NdotL = max(dot(normal, inDir), 0.0);
    const float NdotV = max(dot(normal, outDir), 0.0);
    const float LdotH = max(dot(inDir, halfway), 0.0);

    // Lambert + Burley Diffuse
    const float diffuseFac = PI * NdotL * diffuseBurley(NdotL, NdotV, LdotH, roughness);

    return diffuseFac;
}