// Required Uniforms: shadowModelView, shadowProjection, shadowLightPosition, gbufferModelViewInverse
#include "/settings/main.glsl"
#include "/settings/lighting.glsl"
#include "/settings/atmosphere.glsl"
#include "/settings/rain.glsl"
#include "/lib/pbr.glsl"
#include "/func/shading/specular.glsl"
#include "/func/shading/diffuse.glsl"
#include "/func/shading/clearcoat.glsl"
#include "/func/noise/noiseSimplex.glsl"
#include "/func/noise/noise.glsl"
#include "/func/depthToViewPos.glsl"
#include "/settings/shadows.glsl"
#include "/lib/shadow/shadow0.glsl"
#include "/func/shading/calcSkyReflection.glsl"

uniform float rain;
uniform float wetness;

const vec3 lightDir = normalize(shadowLightPosition);
const vec3 upDir = normalize(upPosition);
const vec3 puddleScale = vec3(PUDDLE_HORIZONTAL_SCALE, PUDDLE_VERTICAL_SCALE,PUDDLE_HORIZONTAL_SCALE);

vec3 playerToViewSpace(vec3 normals) {
    return mat3(gbufferModelView) * normals;
    // return (gbufferModelView * vec4((normals + gbufferModelViewInverse[3].xyz).xyz, 1)).xyz;
}

vec3 viewToPlayerSpace(vec3 normals) {
    return mat3(gbufferModelViewInverse) * normals;
}

struct Material {
    float roughness;
    vec3 normals; // NOTE!: This is in viewSpace where as gbuffers store normals in playerSpace
    float porosity; // Not physically based
    float sss; // Currently unimplemented
    float emission;
    float ao; // Currently unsupported
    float height; // Currently unsupported
    vec3 f0;
    float metallic;
};

// PIN: This parses the gbuffers into actual useable data
Material Mat(vec3 albedo, vec4 gbuffer0, vec4 gbuffer1) {
    float roughness = roughnessRead(gbuffer0.r);
    float reflectance = gbuffer0.g;
    bool isPorosity = false;
    float porosity = porosityRead(gbuffer0.b, isPorosity);
    float emission = emissionRead(gbuffer0.a);
    // Cannot `eyePlayerSpace -> viewSpace` have to `eyePlayerSpace -> playerSpace -> viewSpace`
    vec3 normals = playerToViewSpace(normalsRead(gbuffer1.rg));

    return Material(roughness, normals, isPorosity ? porosity : -1, !isPorosity ? porosity : -1, emission,0,0.0, reflectanceRead(reflectance, albedo), getMetallic(reflectance));
}

//////////////////////////////

// PIN!
bool shade(inout vec4 color, inout Material material, vec2 lightLevel, vec3 posView, out float shadow) {
    bool editGBuffers = false;
    float skylight = lightLevel.y;

    vec3 posWorld = (mat3(gbufferModelViewInverse) * posView) + cameraPosition;
    #if PIXELIZATION != Off
    posWorld = (floor((posWorld*PIXELIZATION)+0.002)/PIXELIZATION);
    posView = (gbufferModelView * vec4(posWorld - cameraPosition, 1)).xyz;
    #endif
    vec3 viewDir = normalize(posView);

    vec3 albedo = color.rgb;
    vec3 normals = material.normals;
    float roughness = material.roughness;
    float porosity = material.porosity;
    vec3 f0 = material.f0;
    float emission = material.emission;
    float metallic = material.metallic;
    vec3 outDir = -viewDir;
    /////////////////////////////////////////
    shadow = calcShadow(posWorld - cameraPosition, viewToPlayerSpace(normals));
    // NOTE: color + someStage -> colorSpecular, meaning color in the specular stage, not color of specular

    float diffuseFactor = calcDiffuseFactor(color.rgb, lightDir, outDir, normals, roughness);
    float lit = min(diffuseFactor,1-shadow)*lightColor.a; //*lightColor.rgb;

    vec3 kS = vec3(0.0);
    #if SPECULAR == On
    vec3 colorSpecular = calcSpecular(lightDir, outDir, normals, roughness, f0, kS);
    #else
    vec3 colorSpecular = vec3(0);
    #endif

    vec3 ambientSpecular = calcSkyReflection(AMBIENT_REFLECTION_QUALITY, viewDir, normals, roughness, skylight);

    color.rgb = (color.rgb*AMBIENT) + (color.rgb*lit); // NOTE: This darkens everything including lightmap as lightmap isnt included in `lit`
    color.rgb = color.rgb*(1-kS)*(1-metallic) + ambientSpecular*kS*(0.5+lit*0.5) + colorSpecular*lit + albedo*emission;

    #if PUDDLES == On
    /* Rain Puddles using Clearcoat layer
        Issue: When block is light source the skylight goes dark, is an issue with mc/iris
    */
    if (wetness > 0.001) { // TODO: Check if is not fluid, cuz fluids cant get wet + that looks weird
        float upness = dot(normals, upDir);
        float skyExposure = clamp(smoothstep(PUDDLE_EXPOSURE_MIN, PUDDLE_EXPOSURE_MAX, skylight), 0, 1);
        
        vec3 noiseCoord = posWorld*puddleScale;
        float distortion = noise(noiseCoord*PUDDLE_DISTORT_SCALE);
        vec3 distort = max(vec3(-distortion, 0, distortion), 0);
        float puddle = (noiseSimplex(noiseCoord * (1-PUDDLE_DISTORT_STRENGTH) + distort*PUDDLE_DISTORT_STRENGTH)*0.5 + 0.5);
        puddle = puddle - mix(1-PUDDLE_SIZE , 0.1, rain) - (1-skyExposure);
        puddle = clamp(puddle * (0.5 + upness*0.5) * rain * RAIN_INTENSITY, 0, 1);

        vec3 puddleNormal = upness > 0.2 ? mix(normals, upDir, clamp(puddle*PUDDLE_THICKNESS*mix(0.5,1,wetness), PUDDLE_THICKNESS*0.45, 1)) : normals;
        color.rgb *= 0.8 + ((1-puddle)*mix(0.6,0.1,porosity))*PUDDLE_COLOR;
        color.rgb += clearcoat(PUDDLE_COLOR, lightDir, outDir, puddleNormal, PUDDLE_ROUGHNESS, PUDDLE_WATER_F0) * puddle * lit;
    
        // Update the material correspondingly
        material.roughness = mix(roughness, PUDDLE_ROUGHNESS, puddle);
        material.normals = mix(normals, puddleNormal, puddle);
        if (f0.x == f0.y && f0.y == f0.z) { // If non-metal, we cannot encode colored F0s :(
            material.f0 = vec3(mix(f0.x, PUDDLE_WATER_F0, puddle));
        }
        editGBuffers = true;
    }
    #endif
    return editGBuffers;
}

// REMOVAL: Unused so commented out, if unused for too long then remove this - 2025/28/4
// bool shade(inout vec4 color, inout Material material, vec2 lightLevel, vec3 posView) {
//     float shadow;
//     return shade(color, material, lightLevel, posView, shadow);
// }