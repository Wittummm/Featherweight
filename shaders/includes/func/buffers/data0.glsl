#include "/includes/func/packing/encodeNormals.glsl"
#include "/includes/func/color/srgb.glsl"

uvec4 writeData0(vec3 normals, vec2 lightLevel) {
    return uvec4(packUnorm4x8(vec4(normalsWrite(normals), sqrt(lightLevel))), 0, 0, 0);
}

void readData0(uvec4 data0, out vec3 normals, out vec2 lightLevel) {
    vec4 data = unpackUnorm4x8(data0.x);
    normals = normalsRead(data.xy);
    lightLevel = data.zw*data.zw;
}