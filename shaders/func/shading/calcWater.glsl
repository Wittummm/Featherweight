#include "/settings/water.glsl"
#include "/func/misc/linearizeDepth.glsl"

vec3 calcWater(const vec4 scatterColor, const float terrainDepth, const float LdotV) {
    const float waterDepth = linearizeDepth(terrainDepth) - linearizeDepth(gl_FragCoord.z);

    // Henyey-Greenstein Phase function
    const float phase = (1.0 - waterScattering2) / pow(1.0 + waterScattering2 - 2.0*waterScattering * LdotV, 1.5);
    const float scatterAmount = 1.0 - exp(-waterDepth * scatterColor.a);

    // Applying the shadow like this isnt not accurate, it would look better raymarched
    const vec3 inScattering = phase * scatterAmount * scatterColor.rgb; // TODOEVENTUALLY: probably dont directly use `lightColor.rgb`
    const vec3 transmittance = pow(vec3(10), -waterDepth*waterConcentration*waterAbsorption);
    return transmittance * inScattering;
}