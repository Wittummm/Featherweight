#include "/snippets/version.glsl"

#include "/common/const.glsl"
#include "/func/packLightLevel.glsl"
#include "/settings/dh_main.glsl"

uniform vec3 cameraPosition;
uniform sampler2D depthtex0;
uniform float near;
uniform float far;
uniform float viewWidth;
uniform float viewHeight;
uniform sampler2D lightmap;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform bool isEyeUnderwater;

const vec2 pixelSize = 1.0/vec2(viewWidth, viewHeight);

#ifdef DISTANT_HORIZONS
    #if DH_FADE_QUALITY == 1
        layout (rgba8) uniform image2D colorimg0;
        layout (rgba8) uniform image2D colorimg1;
        layout (rgba8) uniform image2D colorimg2;
        uniform float dhNearPlane;
    #elif DH_FADE_QUALITY == 10 || DH_FADE_QUALITY == 11 || DH_FADE_QUALITY == 12
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

#include "/settings/main.glsl"
#include "/settings/pbr.glsl"
#include "/func/depthToViewPos.glsl"
#ifdef FORWARD
    #include "/lib/math_lighting.glsl"
    #include "/func/shading/calcWater.glsl"
    uniform sampler2D depthtex1;
    in vec2 blockType;
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

#include "/lib/pbr.glsl"
#include "/func/coloring/srgb.glsl"

in vec2 lightmapCoord;
in vec4 vertColor;
in vec3 vertNormal;
in vec3 vertPosition;

/* RENDERTARGETS: 0,1,2 */
layout(location = 0) out vec4 Color;
layout(location = 1) out vec4 GBuffer0;
layout(location = 2) out vec4 GBuffer1;

// TURN_ON_DEBUG_MODE_HERE
#include "/settings/debug.glsl" 

void main() {
    #include "/snippets/core_to_compat.fsh"
    vec2 fragCoord = gl_FragCoord.xy*pixelSize;
    Color = srgbToLinear(vertColor);

    #ifdef DISTANT_HORIZONS
        vec3 posPlayer = (gbufferModelViewInverse * vec4(vertPosition, 1)).xyz;
        float distToPlayer = length(posPlayer);
        float fade = min(smoothstep(DH_FADE_START*far, DH_FADE_END*far, distToPlayer), 1);

        #if DH_FADE_QUALITY == 10 || DH_FADE_QUALITY == 11 || DH_FADE_QUALITY == 12
            if (fadeDH(length(posPlayer), far)) {
                discard;
                return;
            }
        #endif
    #endif

#ifdef DISTANT_HORIZONS_SHADER
    if (texture(depthtex0, fragCoord).r < 1.0) {
        discard;
        return;
    }

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
    GBuffer1.a = 0.25; // Height
#else
    Color = vec4(Color.rgb, 1) * srgbToLinear(texture(gtexture, texCoord, MIP_MAP_BIAS));
	if (Color.a < alphaTestRef) {
		discard; return;
	}

    GBuffer0 = texture(specular, texCoord, -6); // TODOEVENTUALLY: should actually fix mipmaps
    GBuffer1 = texture(normals, texCoord, -6); // TODOEVENTUALLY: should actually fix mipmaps
    
    vec2 normal = (GBuffer1.rg * 2.0) - 1.0;
    GBuffer1.rg = normalsWrite(vertNormal, tangent, reconstructZ(normal*NORMAL_STRENGTH));
#endif
    // NOTE: Ideally we should disable alpha blending for GBuffer0 and 1 OR pack it into 32 bit buffer
    GBuffer0.a = GBuffer0.a == 0 ? 1 : GBuffer0.a; // 100 alpha = 1 emission = 0 alpha, but we need 1 for alpha blending or something
    
    // "Alpha" blend vanilla chunks to dh
    #if defined DISTANT_HORIZONS && !defined DISTANT_HORIZONS_SHADER && DH_FADE_QUALITY == 1
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
        shade(Color, material, lightmapCoord, depthToViewPos(fragCoord, gl_FragCoord.z), shadow);

        if (blockType.x == 1 && !isEyeUnderwater) { // Water
            float LdotV = dot(normalize(shadowLightPosition), calcViewDir(fragCoord));
            float waterDepth = distance(depthToViewPos(fragCoord, texture(depthtex1, fragCoord).r), depthToViewPos(fragCoord, gl_FragCoord.z));
            Color.rgb = 1 * calcWater(Color.rgb, (1-shadow) * lightColor, waterDepth, LdotV);
        }
        // NOTE: can control dh's water transparency here ig `Color.a`
        Color.rgb = vec3(gl_FragCoord.z);
    #else
        Color = vec4(Color.rgb, packLightLevel(lightmapCoord));
    #endif

    // "Alpha" blend vanilla chunks to dh
    #if defined DISTANT_HORIZONS && !defined DISTANT_HORIZONS_SHADER && DH_FADE_QUALITY == 1
        vec3 dhColor = srgbToLinear(imageLoad(colorimg0, ivec2(gl_FragCoord.xy)).rgb);
        Color.rgb = mix(Color.rgb, dhColor, fade);
    #endif

    Color = linearToSRGB(Color);

    #include "/snippets/debug.fsh"
}