#include "/snippets/version.glsl"

#include "/common/const.glsl"
#include "/func/fadeDH.glsl"

#ifndef DISTANT_HORIZONS_SHADER
    uniform vec3 upPosition;
    uniform vec3 shadowLightPosition;
    uniform vec3 cameraPosition;
    uniform mat4 shadowModelView;
    uniform mat4 shadowProjection;
    uniform mat4 gbufferModelView;
    uniform mat4 gbufferModelViewInverse;
    uniform mat3 normalMatrix;

    #include "/settings/main.glsl"
    #include "/settings/pbr.glsl"
    #include "/lib/light_level.glsl"
    #include "/lib/math_lighting.glsl"

    uniform sampler2D gtexture;
    uniform sampler2D normals;
    uniform sampler2D specular;
    uniform int renderStage;

    in vec2 texCoord;
    in vec4 tangent;
    in vec2 lightmapCoord;
#else
    uniform int dhMaterialId;
#endif

uniform sampler2D colortex0;
uniform sampler2D depthtex0;
uniform float far;
uniform float viewWidth;
uniform float viewHeight;

const vec2 pixelSize = 1.0/vec2(viewWidth, viewHeight);

#include "/lib/pbr.glsl"

in vec4 vertColor;
in vec3 vertNormal;
in vec3 vertPosition;

/* RENDERTARGETS: 0,1,2 */
layout(location = 0) in vec4 InColor;
layout(location = 0) out vec4 Color;
layout(location = 1) out vec4 GBuffer0;
layout(location = 2) out vec4 GBuffer1;

// TURN_ON_DEBUG_MODE_HERE
#include "/settings/debug.glsl" 

void main() {
    #include "/snippets/core_to_compat.fsh"
    const vec2 fragCoord = gl_FragCoord.xy*pixelSize;
        
    const vec3 posPlayer = (gbufferModelViewInverse * vec4(vertPosition, 1)).xyz;
    if (fadeDH(length(posPlayer), far)) {
        discard;
        return;
    }

#ifdef DISTANT_HORIZONS_SHADER
    if (texture(depthtex0, fragCoord).r < 1.0) {
        discard;
        return;
    }
    Color = vertColor;;

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
            GBuffer0.rgba = vec4(0.7, 0.2, 0, 0); break;
        case DH_BLOCK_ILLUMINATED:
            GBuffer0.a = 0.95; break;
        default:
            GBuffer0.rgba = vec4(0.5, 0.05, 0, 0); break;
    }

    GBuffer1.rg = normalsWrite(vertNormal);
    GBuffer1.a = 0.25; // Height
#else
    Color = vec4(vertColor.rgb, 1) * texture(gtexture, texCoord, MIP_MAP_BIAS);
	if (Color.a < alphaTestRef) {
		discard; return;
	}

    GBuffer0 = texture(specular, texCoord, -7); // TODOEVENTUALLY: should actually fix mipmaps
    GBuffer1 = texture(normals, texCoord, -7); // TODOEVENTUALLY: should actually fix mipmaps
    
    const vec2 normal = (GBuffer1.rg * 2.0) - 1.0;
    GBuffer1.rg = normalsWrite(vertNormal, tangent, reconstructZ(normal*NORMAL_STRENGTH));

    #ifdef FORWARD
        Material material = Mat(Color.rgb, GBuffer0, GBuffer1);
        shade(Color, material, lightmapCoord, fragCoord, gl_FragCoord.z);
    #else
        Color = vec4(Color.rgb, packLightLevel(lightmapCoord));
    #endif

    #include "/snippets/debug.fsh"
#endif
}