// Required Uniforms: gbufferTex

#ifdef PBREnabled
#include "/includes/shared/settings.glsl"

// Need this for "Reduced PBR" mode
#include "/includes/func/packing/encodeNormals.glsl"

uvec4 writeGBuffer(vec4 gbuffer0, vec4 gbuffer1) {
    if (PBR == 1) {
        uint smoothness = uint(min(sqrt(gbuffer0.r), 1)*63);

        float r = gbuffer0.g;
        if (r >= 0.9) {
            r = min(r*255, 237) - 230; // hcm index
            r = 63 - r; // reverse index encoding, first is rightmost, last is leftmost
            r /= 63;
        }
        uint reflectance = uint(min(r, 1)*63);
        uint porosity = uint(min(sqrt(gbuffer0.b), 1)*31);
        uint emissive = uint(min(gbuffer0.a, 1)*31);
        uvec2 normals = uvec2(round(clamp(gbuffer1.rg, 0, 1)*31));

        uint data = 0;
        data = bitfieldInsert(data, smoothness, 0, 6);
        data = bitfieldInsert(data, reflectance, 6, 6);
        data = bitfieldInsert(data, porosity, 12, 5);
        data = bitfieldInsert(data, emissive, 17, 5);
        data = bitfieldInsert(data, normals.x, 22, 5);
        data = bitfieldInsert(data, normals.y, 27, 5);

        return uvec4(data, 0, 0, 0);
    } else if (PBR == 2) {
        return uvec4(packUnorm4x8(gbuffer0), packUnorm4x8(gbuffer1), 0, 0);
    }
}

#ifdef INCLUDE_READ_GBUFFER
void readGBuffer(uvec4 gbuffers, out vec4 gbuffer0, out vec4 gbuffer1) {
    if (PBR == 1) { 
        uint data = gbuffers.x;
        gbuffer0.r = pow(bitfieldExtract(data, 0, 6)/63.0, 2);
        gbuffer0.g = bitfieldExtract(data, 6, 6)/63.0;
        if (gbuffer0.g >= 0.9) {
            float hcmIndex = (1-gbuffer0.g)*63;
            gbuffer0.g = (230 + hcmIndex)/255.0;
        } 

        gbuffer0.b = pow(bitfieldExtract(data, 12, 5)/31.0, 2);
        gbuffer0.a = bitfieldExtract(data, 17, 5)/31.0;
        gbuffer1.r = bitfieldExtract(data, 22, 5)/31.0;
        gbuffer1.g = bitfieldExtract(data, 27, 5)/31.0;
    } else if (PBR == 2) {
        gbuffer0 = unpackUnorm4x8(gbuffers.x);
        gbuffer1 = unpackUnorm4x8(gbuffers.y);
    }
        //     gbuffer0.r = 0.3;
        // gbuffer0.g = 0.5;
}
#endif

#endif