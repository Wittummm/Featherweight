#include "/settings/water.glsl"
#include "/func/depthToViewPos.glsl"

vec3 calcWater(in vec3 color, vec4 scatterColor, float waterDepth, float LdotV) {
    // Henyey-Greenstein Phase function
    float phase = (1.0 - waterScattering2) / pow(1.0 + waterScattering2 - 2.0*waterScattering*LdotV, 1.5);
    float scatterAmount = 1.0 - exp2(-waterDepth * scatterColor.a);

    // Applying the shadow like this isnt not accurate, it would look better raymarched
    vec3 inScattering = phase * scatterAmount * scatterColor.rgb; // TODOEVENTUALLY: probably dont directly use `lightColor.rgb`
    vec3 transmittance = pow(vec3(10), -waterDepth*waterConcentration*waterAbsorption);

    color = color*transmittance + transmittance*inScattering;
    return color;
}