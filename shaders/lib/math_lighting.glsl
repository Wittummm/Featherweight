// Required Uniforms: shadowModelView, shadowProjection

#include "/settings/lighting.glsl"
#include "/settings/rain.glsl"
#include "/lib/pbr.glsl"
#include "/func/specular.glsl"
#include "/func/diffuse.glsl"
#include "/func/clearcoat.glsl"
#include "/func/noise/noiseSimplex.glsl"
#include "/func/noise/noise.glsl"
#include "/func/depthToViewPos.glsl"
#include "/settings/shadows.glsl"
#include "/lib/shadow.glsl"

uniform float rain;
uniform float wetness;

const vec3 lightDir = normalize(shadowLightPosition);
const vec3 upDir = normalize(upPosition);
const vec3 puddleScale = vec3(PUDDLE_HORIZONTAL_SCALE, PUDDLE_VERTICAL_SCALE,PUDDLE_HORIZONTAL_SCALE);

in vec2 mc_Entity;

vec3 playerToViewSpace(vec3 normals) {
    return mat3(gbufferModelView) * normals;
    // return (gbufferModelView * vec4((normals + gbufferModelViewInverse[3].xyz).xyz, 1)).xyz;
}

vec3 viewToPlayerSpace(vec3 normals) {
    return mat3(gbufferModelViewInverse) * normals;
}

struct Material {
    float roughness;
    vec3 normals;
    float porosity; 
    float sss; // Currently unimplemented
    float emission;
    float ao; // Currently unsupported
    float height; // Currently unsupported
    vec3 f0;
};

// PIN: This parses the gbuffers into actual useable data
Material Mat(vec3 albedo, vec4 gbuffer0, vec4 gbuffer1) {
    const float roughness = roughnessRead(gbuffer0.r);
    const float reflectance = gbuffer0.g;
    bool isPorosity = false;
    const float porosity = porosityRead(gbuffer0.b, isPorosity);
    const float emission = emissionRead(gbuffer0.a);
    // Cannot `eyePlayerSpace -> viewSpace` have to `eyePlayerSpace -> playerSpace -> viewSpace`
    const vec3 normals = playerToViewSpace(normalsRead(gbuffer1.rg));

    return Material(roughness, normals, isPorosity ? porosity : -1, !isPorosity ? porosity : -1, emission,0,0.0, reflectanceRead(reflectance, albedo));
}

//////////////////////////////

// PIN!
void shade(inout vec4 color, inout Material material, vec2 lightLevel, vec3 viewPos) {
    const float skylight = lightLevel.y;

    vec3 worldPos = (mat3(gbufferModelViewInverse) * viewPos) + cameraPosition;
    #if PBR_PIXELATE != Off
    worldPos = (floor((worldPos*PBR_PIXELATE)+0.00001)/PBR_PIXELATE);
    viewPos = (gbufferModelView * vec4(worldPos - cameraPosition, 1)).xyz;
    #endif
    const vec3 viewDir = normalize(viewPos);

    const vec3 albedo = color.rgb;
    const vec3 normals = material.normals;
    const float roughness = material.roughness;
    const float porosity = material.porosity;
    const vec3 f0 = material.f0;
    const float emission = material.emission;
    const vec3 outDir = -viewDir;

    /// Shadow Handling, NOTE: I should probably move this somewhere cuz here is just ugly + bad organization
    // TODONOW: fix the shadow jittering when you move/crouch
    const vec3 playerPos = (gbufferModelViewInverse * vec4(viewPos, 1)).xyz;
    vec3 roundedWorldPos = playerPos + cameraPosition;
	if (SHADOW_PIXELIZATION < 1 && SHADOW_PIXELIZATION > 0) {
		roundedWorldPos += 0.01; // Bias to fix jittering cuz floating point imprecision
		roundedWorldPos = floor(roundedWorldPos/SHADOW_PIXELIZATION)*SHADOW_PIXELIZATION;
	}
    const vec3 shadowView = (shadowModelView * vec4(roundedWorldPos - cameraPosition, 1)).xyz;
    const vec4 shadowClip = shadowProjection * vec4(shadowView, 1);
    const vec3 shadowNdc = distortShadow(shadowClip.xyz / shadowClip.w);
    const vec3 shadowScreen = shadowNdc * 0.5 + 0.5;
    const float shadow = sampleShadow(shadowScreen, playerPos, 0.001); // TODONOWBUTLATER: remember to replace this with ZBIAS
    const vec3 shadowColor = mix(vec3(1), AMBIENT, shadow);
    ///

    // NOTE: color + someStage -> colorSpecular, meaning color in the specular stage, not color of specular
    vec3 kS = vec3(0.0);
    vec3 colorSpecular = calcSpecular(lightDir, outDir, normals, roughness, f0, kS);
    colorSpecular = albedo*(1-kS) + colorSpecular;

    const vec3 colorDiffuse = diffuse(colorSpecular, lightDir, outDir, normals, roughness);
    color.rgb = colorDiffuse*shadowColor + albedo*emission;

    /* Rain Puddles using Clearcoat layer
        Issue: When block is light source the skylight goes dark, is an issue with mc/iris
    */
    if (wetness > 0.001 && mc_Entity.y != 1.0) { // Check if is not fluid, cuz fluids cant get wet + that looks weird
        const float upness = dot(normals, upDir);
        const float skyExposure = clamp(smoothstep(PUDDLE_EXPOSURE_MIN, PUDDLE_EXPOSURE_MAX, skylight), 0, 1);
        
        const vec3 noiseCoord = worldPos*puddleScale;
        const float distortion = noise(noiseCoord*PUDDLE_DISTORT_SCALE);
        const vec3 distort = max(vec3(-distortion, 0, distortion), 0);
        float puddle = (noiseSimplex(noiseCoord * (1-PUDDLE_DISTORT_STRENGTH) + distort*PUDDLE_DISTORT_STRENGTH)*0.5 + 0.5);
        puddle = puddle - mix(1-PUDDLE_SIZE , 0.1, rain) - (1-skyExposure);
        puddle = clamp(puddle * (0.5 + upness*0.5) * rain * RAIN_INTENSITY, 0, 1);

        const vec3 puddleNormal = upness > 0.2 ? mix(normals, upDir, clamp(puddle*PUDDLE_THICKNESS*mix(0.5,1,wetness), PUDDLE_THICKNESS*0.45, 1)) : normals;
        color.rgb *= 0.8 + ((1-puddle)*mix(0.6,0.1,porosity))*PUDDLE_COLOR;
        color.rgb += clearcoat(PUDDLE_COLOR, lightDir, outDir, puddleNormal, PUDDLE_ROUGHNESS, PUDDLE_WATER_F0) * puddle;
    
        // Update the material correspondingly
        material.roughness = mix(roughness, PUDDLE_ROUGHNESS, puddle);
        material.normals = viewToPlayerSpace(mix(normals, puddleNormal, puddle));
        if (f0.x == f0.y && f0.y == f0.z) { // If non-metal, we cannot encode colored F0s :(
            material.f0 = vec3(mix(f0.x, PUDDLE_WATER_F0, puddle)*3);
        }
    }
}

void shade(inout vec4 color, inout Material material, vec2 lightLevel, vec2 fragCoord, float depth) {
    vec3 viewPos = depthToViewPos(fragCoord, depth); 

    shade(color, material, lightLevel, viewPos);
}
