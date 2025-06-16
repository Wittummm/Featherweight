#version 460 core

#include "/includes/func/color/srgb.glsl"
#include "/includes/func/packing/encodeNormals.glsl"
#include "/includes/func/buffers/gbuffer.glsl"

in vec2 texCoord;
// in vec2 lightmapCoord;
in vec3 vertColor;
in mat3 tbn;

layout(location = 0) out vec4 Color;
layout(location = 1) out uvec2 GBuffer;

void iris_emitFragment() {
    /*immut*/ vec4 texColor = iris_sampleBaseTex(texCoord);
    #ifdef CUTOUT
        if (iris_discardFragment(texColor)) discard;
    #endif

    Color = vec4(srgbToLinear(vertColor)*srgbToLinear(texColor.rgb), texColor.a);
    
    float lod = clamp(textureQueryLod(irisInt_SpecularMap, texCoord).y, 0, 1); // NOTE: PBR maps only have 1 mip level for some reason, this might be hacky
    vec4 spec = iris_sampleSpecularMapLod(texCoord, lod);
    vec4 norm = iris_sampleNormalMapLod(texCoord, lod);

    #define NORMAL_STRENGTH 1 // CONFIGTODO: make into config
    /*immut*/ vec2 normal = (norm.rg * 2.0) - 1.0;
    norm.rg = normalsWrite(tbn * reconstructZ(normal*NORMAL_STRENGTH));
    
    GBuffer = writeGBuffer(spec, norm);
}
