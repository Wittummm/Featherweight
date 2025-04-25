#include "/settings/water.glsl"
#include "/func/misc/linearizeDepth.glsl"

vec3 calcWater(vec4 scatterColor, float terrainDepth, float LdotV) {
    float waterDepth = linearizeDepth(terrainDepth) - linearizeDepth(gl_FragCoord.z);

    // Henyey-Greenstein Phase function
    float phase = (1.0 - waterScattering2) / pow(1.0 + waterScattering2 - 2.0*waterScattering * LdotV, 1.5);
    float scatterAmount = 1.0 - exp(-waterDepth * scatterColor.a);

    // Applying the shadow like this isnt not accurate, it would look better raymarched
    vec3 inScattering = phase * scatterAmount * scatterColor.rgb; // TODOEVENTUALLY: probably dont directly use `lightColor.rgb`
    vec3 transmittance = pow(vec3(10), -waterDepth*waterConcentration*waterAbsorption);
    return transmittance * inScattering;
}