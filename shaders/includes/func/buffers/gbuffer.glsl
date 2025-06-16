// TODONOWBUTLATER: make this into `writeGbuffer(uvec2 specAndNorm)` and `uvec2 readGbuffer()`

uvec2 writeGBuffer(vec4 spec, vec4 norm) {
    return uvec2(packUnorm4x8(spec), packUnorm4x8(norm));
}

void readGBuffer(uvec2 specAndNorm, out vec4 spec, out vec4 norm) {
    spec = unpackUnorm4x8(specAndNorm.x);
    norm = unpackUnorm4x8(specAndNorm.y);
}