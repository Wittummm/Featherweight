#include "/includes/func/depthToViewPos.glsl"

vec3 calcWater(in vec3 color, vec4 scatterColor, float waterDepth, float LdotV) {
    // Henyey-Greenstein Phase function
    float phase = (1.0 - waterScattering2) / pow(1.0 + waterScattering2 - 2.0*waterScattering*LdotV, 1.5);
    float scatterAmount = 1.0 - exp2(-waterDepth * scatterColor.a);

    vec3 inScattering = phase * scatterAmount * scatterColor.rgb; 
    vec3 transmittance = exp2(-waterDepth*waterConcentration*waterAbsorption);

    color = color*transmittance + transmittance*inScattering;
    return color;
}