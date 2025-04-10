#include "/snippets/version.glsl"

uniform float viewWidth;
uniform float viewHeight;

#include "/common/const.glsl"
#include "/settings/main.glsl"
#include "/settings/pbr.glsl"
#include "/lib/pbr.glsl"
#include "/lib/light_level.glsl"

// TURN_ON_DEBUG_MODE_HERE
#include "/settings/debug.glsl" 

uniform sampler2D gtexture;
uniform sampler2D normals;
uniform sampler2D specular;
uniform vec3 shadowLightPosition;
uniform mat4 modelViewMatrix;
uniform int renderStage;

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
    GBuffer0 = texture(specular, texCoord, -3); // TODOLATER: arbitrary mip map bias? questionable
    GBuffer1 = texture(normals, texCoord, -3); // TODOLATER: arbitrary mip map bias? questionable
    
    const vec2 normal = (GBuffer1.rg * 2.0) - 1.0;
    GBuffer1.rg = normalsWrite(vertNormal, tangent, reconstructZ(normal*NORMAL_STRENGTH));

    Color = vec4(vertColor.rgb, 1) * texture(gtexture, texCoord);
	if (Color.a < alphaTestRef) {
		discard;
	}

    #include "/snippets/debug.fsh"
    if (renderStage != MC_RENDER_STAGE_TERRAIN_TRANSLUCENT) {
        Color = vec4(Color.rgb, packLightLevel(lightmapCoord));
    }
}
