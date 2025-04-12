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
#endif

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
layout(location = 0) out vec4 Color;
layout(location = 1) out vec4 GBuffer0;
layout(location = 2) out vec4 GBuffer1;

// TURN_ON_DEBUG_MODE_HERE
#include "/settings/debug.glsl" 

void main() {
    #include "/snippets/core_to_compat.fsh"
        
    // TODO: Move this to `snippets` or make it a `func` that returns a boolean
    const vec3 posPlayer = (gbufferModelViewInverse * vec4(vertPosition, 1)).xyz;
    if (fadeDH(length(posPlayer), far)) {
        discard;
        return;
    }

#ifdef DISTANT_HORIZONS_SHADER
    if (texture(depthtex0, gl_FragCoord.xy*pixelSize).r < 1.0) {
        discard;
        return;
    }
    Color = vertColor;
    GBuffer1.rg = normalsWrite(vertNormal);
#else
    Color = vec4(vertColor.rgb, 1) * texture(gtexture, texCoord, MIP_MAP_BIAS);
	if (Color.a < alphaTestRef) {
		discard;
        return;
	}

    GBuffer0 = texture(specular, texCoord, MIP_MAP_BIAS); 
    GBuffer1 = texture(normals, texCoord, MIP_MAP_BIAS); 
    
    const vec2 normal = (GBuffer1.rg * 2.0) - 1.0;
    GBuffer1.rg = normalsWrite(vertNormal, tangent, reconstructZ(normal*NORMAL_STRENGTH));

    #ifdef FORWARD
        Material material = Mat(Color.rgb, GBuffer0, GBuffer1);
        shade(Color, material, lightmapCoord, gl_FragCoord.xy*pixelSize, gl_FragCoord.z);
    #else
        Color = vec4(Color.rgb, packLightLevel(lightmapCoord));
    #endif
    #include "/snippets/debug.fsh"
#endif
}