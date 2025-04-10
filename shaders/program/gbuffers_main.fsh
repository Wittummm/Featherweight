#include "/snippets/version.glsl"

uniform vec3 upPosition;
uniform vec3 shadowLightPosition;
uniform vec3 cameraPosition;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

#include "/common/const.glsl"
#include "/settings/main.glsl"
#include "/settings/pbr.glsl"
#include "/lib/pbr.glsl"
#include "/lib/light_level.glsl"
#include "/lib/math_lighting.glsl"

// TURN_ON_DEBUG_MODE_HERE
#include "/settings/debug.glsl" 

uniform sampler2D gtexture;
uniform sampler2D normals;
uniform sampler2D specular;
uniform mat4 modelViewMatrix;
uniform int renderStage;
uniform float viewWidth;
uniform float viewHeight;

in vec2 texCoord;
in vec4 vertColor;
in vec3 vertNormal;
in vec4 tangent;
in vec2 lightmapCoord;

/* RENDERTARGETS: 0,1,2 */
layout(location = 0) out vec4 Color;
layout(location = 1) out vec4 GBuffer0;
layout(location = 2) out vec4 GBuffer1;


void main() {

    Color = vec4(vertColor.rgb, 1) * texture(gtexture, texCoord);
	if (Color.a < alphaTestRef) {
		discard;
        return;
	}

    GBuffer0 = texture(specular, texCoord, -3); // TODOLATER: arbitrary mip map bias? questionable
    GBuffer1 = texture(normals, texCoord, -3); // TODOLATER: arbitrary mip map bias? questionable
    
    const vec2 normal = (GBuffer1.rg * 2.0) - 1.0;
    GBuffer1.rg = normalsWrite(vertNormal, tangent, reconstructZ(normal*NORMAL_STRENGTH));

#ifdef FORWARD
    Material material = Mat(Color.rgb, GBuffer0, GBuffer1);
    shade(Color, material, lightmapCoord, texCoord, gl_FragCoord.z);
#else
    Color = vec4(Color.rgb, packLightLevel(lightmapCoord));
#endif
    #include "/snippets/debug.fsh"
}