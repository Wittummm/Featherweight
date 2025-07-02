uvec2 writeGBuffer(vec4 gbuffer0, vec4 gbuffer1) {
    return uvec2(packUnorm4x8(gbuffer0), packUnorm4x8(gbuffer1));
}

void readGBuffer(uvec2 specAndNorm, out vec4 gbuffer0, out vec4 gbuffer1) {
    gbuffer0 = unpackUnorm4x8(specAndNorm.x);
    gbuffer1 = unpackUnorm4x8(specAndNorm.y);
}