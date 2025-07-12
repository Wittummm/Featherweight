// Required Uniforms: shadowMap, shadowMapFiltered
#include "/includes/lib/shadow/shadow0.glsl"
#include "/includes/lib/pbr.glsl"
#include "/includes/func/shading/specular.glsl"
#include "/includes/func/shading/diffuse.glsl"
#include "/includes/func/shading/clearcoat.glsl"
#include "/includes/func/random/noiseSimplex.glsl"
#include "/includes/func/random/noise.glsl"
#include "/includes/func/depthToViewPos.glsl"
#include "/includes/lib/material.glsl"
#include "/includes/func/pixelize.glsl"

/*immut*/ vec3 lightDir = normalize(ap.celestial.pos);
/*immut*/ vec3 upDir = normalize(ap.celestial.upPos);
#define PUDDLE_HORIZONTAL_SCALE 1 // CONFIGTODO: do this
#define PUDDLE_VERTICAL_SCALE 1 // CONFIGTODO: do this
const vec3 puddleScale = vec3(PUDDLE_HORIZONTAL_SCALE, PUDDLE_VERTICAL_SCALE,PUDDLE_HORIZONTAL_SCALE);
#define PUDDLES // CONFIGTODO:
#define PUDDLE_EXPOSURE_MIN 0.2 // CONFIGTODO:
#define PUDDLE_EXPOSURE_MAX 0.7 // CONFIGTODO:
#define PUDDLE_DISTORT_SCALE 1 // CONFIGTODO:
#define PUDDLE_DISTORT_STRENGTH 1 // CONFIGTODO:
#define PUDDLE_SIZE 1 // CONFIGTODO:
#define RAIN_INTENSITY 1 // CONFIGTODO:
#define PUDDLE_THICKNESS 1 // CONFIGTODO:
#define PUDDLE_ROUGHNESS 0.7 // CONFIGTODO:
#define PUDDLE_WATER_F0 0.3 // CONFIGTODO:
const vec3 PUDDLE_COLOR = vec3(0.8,0.8,0.85); // CONFIGTODO:
//////////////////////////////

// PIN!
bool shade(inout vec4 color, inout Material material, vec2 lightLevel, vec3 posView, out float shadow) {
    bool editGBuffers = false;
    float skylight = lightLevel.y;

    vec3 posWorld = (mat3(ap.camera.viewInv) * posView) + ap.camera.pos + ap.camera.viewInv[3].xyz;
    vec3 _posWorld = posWorld;
    if (ShadingPixelization != 0) {
        posWorld = pixelize(posWorld, ShadingPixelization);
        posView = (ap.camera.view * vec4(posWorld - ap.camera.pos, 1)).xyz;
    }
    vec3 viewDir = normalize(posView);

    vec3 albedo = color.rgb;
    vec3 geoNormals = material.baseNormals;
    vec3 normals = material.normals;
    float roughness = material.roughness;
    float porosity = material.porosity;
    vec3 f0 = material.f0;
    float emission = material.emission;
    float metallic = material.metallic;
    vec3 outDir = -viewDir;
    /////////////////////////////////////////
    vec3 shadowPosWorld = _posWorld;
    if (ShadowPixelization != 0) shadowPosWorld += (mat3(ap.camera.viewInv) * geoNormals)*(0.75/ShadowPixelization); // POINT: Bias the position outward so it doesnt round to be inside the block
    /// Intermediate
    vec3 kS = vec3(0.0);
    vec3 specular = vec3(0);
    if (Specular == 1) {
        specular = calcSpecular(lightDir, outDir, normals, roughness, f0, kS);
    }
    vec3 kD = 1-kS;
    float diffuseFactor = calcDiffuseFactor(lightDir, outDir, normals, roughness);
    if (diffuseFactor > 0) {
        shadow = calcShadow(pixelize(shadowPosWorld, ShadowPixelization) - ap.camera.pos, geoNormals);
    }
    float visibility = min(diffuseFactor,1-shadow);
    vec3 diffuse = albedo*(1-metallic) *kD;
    // vec3 localLight = iris_sampleLightmap(lightLevel).rgb; // TODONOW: AP_ISSUE: Aperture only define this func for fragment, not compute..
    vec3 localLight = lightLevel.x*localLightColor.rgb;

    color.rgb = (diffuse + specular)*visibility*LightColor.rgb + 
                albedo*(skylight*AmbientColor.rgb + EMISSION_LUX*emission + localLight);

    #ifdef PUDDLES // TODONOWBUTLATER:
    /* Rain Puddles using Clearcoat layer
        Issue: When block is light source the skylight goes dark, is an issue with mc/iris
    */
    if (Wetness > 0.001) {
        float upness = dot(normals, upDir);
        float skyExposure = clamp(smoothstep(PUDDLE_EXPOSURE_MIN, PUDDLE_EXPOSURE_MAX, skylight), 0, 1);
        
        vec3 noiseCoord = posWorld*puddleScale;
        float distortion = noise(noiseCoord*PUDDLE_DISTORT_SCALE);
        vec3 distort = max(vec3(-distortion, 0, distortion), 0);
        float puddle = (noiseSimplex(noiseCoord * (1-PUDDLE_DISTORT_STRENGTH) + distort*PUDDLE_DISTORT_STRENGTH)*0.5 + 0.5);
        puddle = puddle - mix(1-PUDDLE_SIZE , 0.1, Rain) - (1-skyExposure);
        puddle = clamp(puddle * (0.5 + upness*0.5) * Rain * RAIN_INTENSITY, 0, 1);

        vec3 puddleNormal = upness > 0.2 ? mix(normals, upDir, clamp(puddle*PUDDLE_THICKNESS*mix(0.5,1,Wetness), PUDDLE_THICKNESS*0.45, 1)) : normals;
        color.rgb *= 0.8 + ((1-puddle)*mix(0.6,0.1,porosity))*PUDDLE_COLOR;
        color.rgb += clearcoat(PUDDLE_COLOR, lightDir, outDir, puddleNormal, PUDDLE_ROUGHNESS, PUDDLE_WATER_F0) * puddle * visibility;
    
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

#ifdef PBREnabled
void writeMaterial(Material material, inout vec4 GBuffer0, inout vec4 GBuffer1) {
    GBuffer0.r = roughnessWrite(material.roughness);
    GBuffer1.rg = normalsWrite(mat3(ap.camera.viewInv) * (material.normals));
    GBuffer0.g = reflectanceWriteFromF0(material.f0.x);
}
#endif