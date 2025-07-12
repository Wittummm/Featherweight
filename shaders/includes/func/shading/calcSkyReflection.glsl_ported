#include "/includes/func/goldenDiskSample.glsl"
#include "/includes/func/atmosphere/calcSky.glsl"

const float defaultSampleMult = 2;

vec3 calcSkyReflection(float sampleMult, vec3 viewDir, vec3 normals, float roughness, float skylight) {
    // NOTE: This is not physically based at all and is very arbitrary
    if (sampleMult < 0) return vec3(0);

    float sampleCount = floor(1+(roughness*sampleMult));
    vec3 ambientSpecular;
    if (skylight*skylight > 0.0625) {
        for (int i = 0; i < int(sampleCount); i++) {
            vec3 currentNormals = normalize(normals + roughness*vec3(goldenDiskSample(i, sampleCount), 0).xzy );
            ambientSpecular += calcSkyNoStars(mix(reflect(viewDir, currentNormals), currentNormals, min(roughness+0.2, 0.1)))*skylight*skylight*(1-roughness);
        }
        ambientSpecular /= sampleCount; 
    }

    return ambientSpecular;
}

vec3 calcSkyReflection(vec3 normals, vec3 viewDir, float roughness, float skylight) {
   return calcSkyReflection(defaultSampleMult, viewDir, normals, roughness, skylight);
}