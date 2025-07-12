#ifdef PBREnabled
uvec4 writeGBuffer(vec4 gbuffer0, vec4 gbuffer1) {
    return uvec4(packUnorm4x8(gbuffer0), packUnorm4x8(gbuffer1), 0, 0);
}

void readGBuffer(uvec4 specAndNorm, out vec4 gbuffer0, out vec4 gbuffer1) {
    gbuffer0 = unpackUnorm4x8(specAndNorm.x);
    gbuffer1 = unpackUnorm4x8(specAndNorm.y);
}
#endif