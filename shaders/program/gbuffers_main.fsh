#include "/snippets/version.glsl"

#include "/common/const.glsl"
#include "/func/packing/packLightLevel.glsl"
#include "/settings/dh_main.glsl"

uniform vec3 cameraPosition;
uniform float renderDistance;
uniform float viewWidth;
uniform float viewHeight;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform bool isEyeUnderwater;

const vec2 pixelSize = 1.0/vec2(viewWidth, viewHeight);

#ifdef DISTANT_HORIZONS
    uniform float dhNearPlane;
    #if DH_FADE_BLENDING == 2
        layout (rgba8) uniform image2D colorimg0;
        layout (rgba8) uniform image2D colorimg1;
        layout (rgba8) uniform image2D colorimg2;
    #endif
    #if DH_FADE_DITHER > 0
        #include "/func/fadeDH.glsl"
    #endif
#endif

uniform vec3 upPosition;
uniform vec3 shadowLightPosition;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform mat3 normalMatrix;
uniform float sunAngle;
uniform vec4 lightColor;
uniform sampler2D depthtex1;
uniform sampler2D depthtex0;

#include "/settings/main.glsl"
#include "/settings/pbr.glsl"
#include "/func/depthToViewPos.glsl"

#ifdef FORWARD
    uniform vec2 mc_Entity;
    #include "/lib/math_lighting.glsl"
    #include "/func/shading/calcWater.glsl"
    in vec2 blockType;

#endif
#ifdef DISTANT_HORIZONS
    #ifndef DISTANT_HORIZONS_SHADER
        uniform sampler2D dhDepthTex0; // Use depth0 in some cases because DH handles the 0/1 depth buffer weirdly :)
    #endif
    uniform sampler2D dhDepthTex1;
    uniform mat4 dhProjectionInverse;
#endif
#ifndef DISTANT_HORIZONS_SHADER
    uniform sampler2D gtexture;
    uniform sampler2D normals;
    uniform sampler2D specular;
    uniform int renderStage;

    in vec2 texCoord;
    in vec4 tangent;
#else
    uniform int dhMaterialId;
#endif

#define YES_NORMALS_WRITE
#include "/func/packing/encodeNormals.glsl"
#include "/func/coloring/srgb.glsl"

in vec2 lightmapCoord;
in vec4 vertColor;
in vec3 vertNormal;
in vec3 vertPosition;
in vec4 at_midBlock;

/* RENDERTARGETS: 0,1,2 */
layout(location = 0) out vec4 Color;
layout(location = 1) out vec4 GBuffer0;
layout(location = 2) out vec4 GBuffer1;

// TURN_ON_DEBUG_MODE_HERE
#include "/settings/debug.glsl" 

void main() {
    #include "/snippets/core_to_compat.fsh"
    vec2 fragCoord = gl_FragCoord.xy*pixelSize;

    #ifdef DISTANT_HORIZONS
        #if defined DISTANT_HORIZONS_SHADER && defined FORWARD 
            // Depth checks DH fragments, ensures that DH frag behind Vanilla doesnt get drawn
            /*immut*/ float depth1 = texture(depthtex1, fragCoord).r;
            if (depth1 < 1 && vertPosition.z < depthToViewPos(fragCoord, depth1).z) {
                discard;
                return;
            }
        #endif

        vec3 posPlayer = (gbufferModelViewInverse * vec4(vertPosition, 1)).xyz;
        float distToPlayer = length(posPlayer);
        float fade = clamp(smoothstep(DH_FADE_START*renderDistance, DH_FADE_END*renderDistance, distToPlayer), 0, 1);

        #if DH_FADE_DITHER > 0
            #ifndef DISTANT_HORIZONS_SHADER
                #if DH_FADE_BLENDING == 1
                    bool shouldDither = true;
                #else
                     // This fixes the "invisible" vanilla chunks by dithering some vanilla chunks
                    const float thresholdToDither = 0.25; // This is how far behind in blocks until it starts dithering
                    vec3 dhPos = depthToViewPos(fragCoord, texture(dhDepthTex0, fragCoord).r, dhProjectionInverse);
                    bool shouldDither = -vertPosition.z > dhNearPlane && vertPosition.z - dhPos.z > thresholdToDither;
                #endif
                if (shouldDither && fadeDH(fade)) { discard; return; }
            #elif defined FORWARD
                /* As dithering is a threshold method it is inherently non-uniform meaning 
                it does not gurantee that the inverse will have the exact opposite pixel resulting in "holes"
                We could mitigate this by biasing the fade value, but that causes some pixels to double up drawing both dh and vanilla */

                // TODOLATER: it still has holes at grazing angles, perhaps make it dynamic on viewing angle?
                if (!fadeDH(smoothstep(DH_FADE_START*renderDistance, DH_FADE_END*renderDistance, distToPlayer*1.1))) { discard; return; } // NOTE: 1.1 here is arbitrary, and probably shouldnt be
            #endif
        #endif
    #endif

    Color = srgbToLinear(vertColor);

#ifdef DISTANT_HORIZONS_SHADER
    // TODOEVENTUALLY: Move this somewhere else for better organization
    switch (dhMaterialId) { // TODOEVENTUALLY NOTE: Not tested bc it doesnt work on 1.21.4
        // Smoothness, Reflectance, Porosity/SSS, Emissive
        case DH_BLOCK_LEAVES:
            GBuffer0.rgba = vec4(0.3, 0.07, 0.9, 0); break;
        case DH_BLOCK_DIRT:
            GBuffer0.rgba = vec4(0.1, 0.0, 0.4, 0); break;
        case DH_BLOCK_WOOD:
            GBuffer0.rgba = vec4(0.3, 0.12, 0, 0); break;
        case DH_BLOCK_METAL:
            GBuffer0.rgba = vec4(0.7, 1.0, 0, 0); break;
        case DH_BLOCK_DEEPSLATE:
            GBuffer0.rgba = vec4(0.25, 0.01, 0, 0); break;
        case DH_BLOCK_SAND:
            GBuffer0.rgba = vec4(0.25, 0.01, 0.65, 0); break;
        case DH_BLOCK_SNOW:
            GBuffer0.rgba = vec4(0.1, 0.0, 0.8, 0); break;
        case DH_BLOCK_NETHER_STONE:
            GBuffer0.rgba = vec4(0.2, 0.01, 0, 0); break;
        case DH_BLOCK_WATER:
            GBuffer0.rgba = vec4(0.7, 0.2, 0, 0.99); break;
        case DH_BLOCK_ILLUMINATED:
            GBuffer0.a = 0.95; break;
        default:
            GBuffer0.rgba = vec4(0.1, 0.05, 0, 0); break;
    }

    GBuffer1.rg = normalsWrite(vertNormal);
    GBuffer1.a = 1; // Need 1 alpha for the blending, but value should actually be 0.25 ISSUECODE: 12xnd TODOEVENTUALLY: Fix this by turning of alpha blending on gbuffers
#else
    Color = vec4(Color.rgb, 1) * srgbToLinear(texture(gtexture, texCoord, MIP_MAP_BIAS));
    #ifdef CUTOUT
        if (Color.a < alphaTestRef) {
            discard; return;
        }
    #endif

    // Encode PBR data to buffers here
    GBuffer0 = texture(specular, texCoord, -6); // TODOEVENTUALLY: should actually fix mipmaps
    GBuffer1 = texture(normals, texCoord, -6); // TODOEVENTUALLY: should actually fix mipmaps
    
    vec2 normal = (GBuffer1.rg * 2.0) - 1.0;
    GBuffer1.rg = normalsWrite(vertNormal, tangent, reconstructZ(normal*NORMAL_STRENGTH));
#endif
    // ISSUECODE: 12xnd NOTE: Ideally we should disable alpha blending for GBuffer0 and 1 OR pack it into 32 bit buffer
    GBuffer0.a = GBuffer0.a == 0 ? 1 : GBuffer0.a;
    
    // "Alpha" blend vanilla chunks to dh
    #if defined DISTANT_HORIZONS && !defined DISTANT_HORIZONS_SHADER && DH_FADE_BLENDING == 2
        if (-vertPosition.z > dhNearPlane) {
            vec4 dhGBuffer0 = imageLoad(colorimg1, ivec2(gl_FragCoord.xy));
            GBuffer0 = mix(GBuffer0, dhGBuffer0, fade);
            
            vec4 dhGBuffer1 = imageLoad(colorimg2, ivec2(gl_FragCoord.xy));
            GBuffer1.rg = normalsWrite(mix(normalsRead(GBuffer1.rg), normalsRead(dhGBuffer1.rg), fade));
            GBuffer1.ba = mix(GBuffer1.ba, dhGBuffer1.ba, fade);
        }
    #endif

    #ifdef FORWARD
        Material material = Mat(Color.rgb, GBuffer0, GBuffer1);
        float shadow = 0;
        bool shouldUpdate = shade(Color, material, lightmapCoord, vertPosition, shadow);
        if (shouldUpdate) writeMaterialToGbuffer(material, GBuffer0, GBuffer1);

        #ifdef DISTANT_HORIZONS_SHADER
            // Below is a bad solution and hacky, should not hardcode the alpha, color, etc
            bool isWater = true; // TODOBUTLATER: should ideally use `dhMaterialId`
            Color.b *= 1.7;
            Color.a = 0.8; // can control dh's water transparency here ig `Color.a`
        #else
            bool isWater = blockType.x == 1;
        #endif
        if (isWater && !isEyeUnderwater) {
            #ifdef DISTANT_HORIZONS_SHADER
                vec3 dhPos = depthToViewPos(fragCoord, texture(dhDepthTex1, fragCoord).r, dhProjectionInverse);
                float waterDepth = distance(dhPos, vertPosition);
            #elif defined DISTANT_HORIZONS
                float terrainDepth = texture(depthtex1, fragCoord).r;
                vec3 pos = terrainDepth < 1 ? depthToViewPos(fragCoord, terrainDepth) : depthToViewPos(fragCoord, texture(dhDepthTex1, fragCoord).r, dhProjectionInverse);
                float waterDepth = distance(pos, vertPosition);
            #else
                float waterDepth = distance(depthToViewPos(fragCoord, texture(depthtex1, fragCoord).r), vertPosition);
            #endif

            float LdotV = dot(normalize(shadowLightPosition), calcViewDir(fragCoord));
            Color.rgb = calcWater(Color.rgb, (1-shadow) * lightColor, waterDepth, LdotV);
            // Color.rgb = vec3(waterDepth)*0.1; // TODONOW: fix the depth at the blending boundary being "wrong"
        }
    #else
        Color = vec4(Color.rgb, packLightLevel(lightmapCoord));
    #endif

    // "Alpha" blend vanilla chunks to dh (Cannot blend dh to vanilla as dh renders first and thus have no data to vanilla color)
    #if defined DISTANT_HORIZONS && !defined DISTANT_HORIZONS_SHADER && DH_FADE_BLENDING == 2
        vec4 dhColor = srgbToLinear(imageLoad(colorimg0, ivec2(gl_FragCoord.xy)));
        Color.rgb = mix(Color.rgb, dhColor.rgb, fade);
    #endif

    Color = linearToSRGB(Color);

    #include "/snippets/debug.fsh"
}

