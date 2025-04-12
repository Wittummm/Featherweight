#include "/snippets/version.glsl"

#include "/common/const.glsl"
// TURN_ON_DEBUG_MODE_HERE
#include "/settings/debug.glsl" 

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
    #include "/lib/pbr.glsl"
    #include "/lib/light_level.glsl"
    #include "/lib/math_lighting.glsl"

    uniform sampler2D gtexture;
    uniform sampler2D normals;
    uniform sampler2D specular;
    uniform int renderStage;
    uniform float viewWidth;
    uniform float viewHeight;

    in vec2 texCoord;
    in vec4 tangent;
    const vec2 pixelSize = 1.0/vec2(viewWidth, viewHeight);
#endif
in vec4 vertColor;
in vec3 vertNormal;
in vec2 lightmapCoord;

/* RENDERTARGETS: 0,1,2 */
layout(location = 0) out vec4 Color;
layout(location = 1) out vec4 GBuffer0;
layout(location = 2) out vec4 GBuffer1;

void main() {
    #include "/snippets/core_to_compat.fsh"

#ifdef DISTANT_HORIZONS_SHADER
    Color = vec4(vertColor.rgb, 1);
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