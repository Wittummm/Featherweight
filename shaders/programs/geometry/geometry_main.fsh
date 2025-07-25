#version 460 core

#include "/includes/shared/shared.glsl"
#include "/includes/shared/shadowmap_uniforms.glsl"
#include "/includes/func/color/srgb.glsl"
#include "/includes/func/packing/encodeNormals.glsl"
#include "/includes/func/buffers/gbuffer.glsl"
#include "/includes/func/buffers/data0.glsl"
#include "/includes/lib/math_lighting.glsl"


in vec2 texCoord;
in vec3 vertColor;
in vec2 lightmapCoord;
#ifdef PBREnabled
in mat3 tbn;
#else
in vec3 vertNormal;
#endif

#ifdef FORWARD
uniform sampler2D solidDepthTex;
in vec3 posView;
#ifdef TERRAIN
flat in uint blockId;
#endif
#include "/includes/func/shading/calcWater.glsl"
#endif

layout(location = 0) out vec4 Color;
#ifdef PBREnabled
layout(location = 1) out uvec4 GBuffer;
#endif
layout(location = 2) out uvec4 Data0;

void iris_emitFragment() {
    /*immut*/ vec4 texColor = iris_sampleBaseTex(texCoord);
    #ifdef CUTOUT
        if (iris_discardFragment(texColor)) discard;
    #endif

    Color = vec4(vertColor.rgb*srgbToLinear(texColor.rgb), texColor.a);
    
    vec4 gbuffer0 = gbuffer0Default; vec4 gbuffer1 = gbuffer1Default;
    #ifdef PBREnabled
        vec3 normalsPlayer = tbn[2];

        if (PBR != 0) {
            gbuffer0 = iris_sampleSpecularMap(texCoord);
            gbuffer1 = iris_sampleNormalMap(texCoord);

            /*immut*/ vec2 normal = (gbuffer1.rg * 2.0) - 1.0;
            gbuffer1.rg = normalsWrite(tbn * reconstructZ(normal*NormalStrength));
        }
    #else
        vec3 normalsPlayer = vertNormal;
    #endif

    #ifdef FORWARD
        Material material = Mat(Color.rgb, normalsPlayer, gbuffer0, gbuffer1);
        float shadow = 0;
        bool shouldUpdate = shade(Color, material, lightmapCoord, posView, shadow);
        #ifdef PBREnabled
        if (shouldUpdate) {writeMaterial(material, gbuffer0, gbuffer1);} 
        #endif
        
        #ifdef TERRAIN
        if (ap.camera.fluid != 1 && iris_getCustomId(blockId) == TYPE_WATER) {
            vec2 fragCoord = gl_FragCoord.xy/ap.game.screenSize;
            
            float waterDepth = distance(depthToViewPos(fragCoord, texture(solidDepthTex, fragCoord).r), posView);
            float LdotV = dot(normalize(ap.celestial.pos), normalize(posView));
            Color.rgb = calcWater(Color.rgb, (1-shadow) * LightColor, waterDepth, LdotV);
        }
        #endif
    #endif  

    Color = writeScene(Color);
    #ifdef PBREnabled
    GBuffer = writeGBuffer(gbuffer0, gbuffer1);
    #endif
    
    Data0 = writeData0(normalsPlayer, lightmapCoord);
}
