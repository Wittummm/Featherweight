#version 460 core

uniform sampler2DArrayShadow shadowMapFiltered;
uniform sampler2DArray shadowMap;

#include "/includes/shared/settings.glsl"
#include "/includes/func/color/srgb.glsl"
#include "/includes/func/packing/encodeNormals.glsl"
#include "/includes/func/buffers/gbuffer.glsl"
#include "/includes/lib/math_lighting.glsl"

in vec2 texCoord;
in vec3 vertColor;
in mat3 tbn;
in vec3 posView;
#ifdef FORWARD
in vec2 lightmapCoord;
#endif

layout(location = 0) out vec4 Color;
layout(location = 1) out uvec2 GBuffer;

void iris_emitFragment() {
    /*immut*/ vec4 texColor = iris_sampleBaseTex(texCoord);
    #ifdef CUTOUT
        if (iris_discardFragment(texColor)) discard;
    #endif

    Color = vec4(srgbToLinear(vertColor)*srgbToLinear(texColor.rgb), texColor.a);
    
    float lod = clamp(textureQueryLod(irisInt_SpecularMap, texCoord).y, 0, 1); // NOTE: PBR maps only have 1 mip level for some reason, this might be hacky
    vec4 gbuffer0 = mix(iris_sampleSpecularMapLod(texCoord, floor(lod)), iris_sampleSpecularMapLod(texCoord, ceil(lod)), fract(lod));
    vec4 gbuffer1 = mix(iris_sampleNormalMapLod(texCoord, floor(lod)), iris_sampleNormalMapLod(texCoord, ceil(lod)), fract(lod));

    /*immut*/ vec2 normal = (gbuffer1.rg * 2.0) - 1.0;
    gbuffer1.rg = normalsWrite(tbn * reconstructZ(normal*NormalStrength));
    
    #ifdef FORWARD
        Material material = Mat(Color.rgb, gbuffer0, gbuffer1);
        float shadow = 0;
        bool shouldUpdate = shade(Color, material, lightmapCoord, posView, shadow); //TEMP TODONOW: this break translucent colors
        if (shouldUpdate) {
			writeMaterial(material, gbuffer0, gbuffer1);
            GBuffer.rg = writeGBuffer(gbuffer0, gbuffer1).rg;
		} 

        // TODONOW:
    #endif  

    GBuffer = writeGBuffer(gbuffer0, gbuffer1);

    /*
        bool isWater = blockType.x == 1;
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
    */
}
