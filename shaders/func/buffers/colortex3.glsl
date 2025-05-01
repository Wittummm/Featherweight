/*
const int colortex3Format = RGB8UI;
*/

uniform usampler2D colortex3;

const vec2 colortex3Size = vec2(textureSize(colortex3, 0));
const vec2 colortex3TexelSize = 1.0/colortex3Size;

uvec3 writeSSR(vec2 _data) {
    uvec2 data = uvec2(_data.xy*4095.0);
    uint packedData = data.x | (data.y << 12);

    return uvec3(packedData & 0xFFu, (packedData >> 8) & 0xFFu, (packedData >> 16) & 0xFFu);
}

vec2 readSSR(uint r, uint g, uint b) {
    uint data = r | (g << 8) | (b << 16);

    return vec2(data & 0xFFFu, (data >> 12) & 0xFFFu) * 0.0002442002442002442;
}

vec2 readSSR(uvec3 texel) {
    uint data = texel.r | (texel.g << 8) | (texel.b << 16);

    return vec2(data & 0xFFFu, (data >> 12) & 0xFFFu) * 0.0002442002442002442;
}

vec2 readSSR(vec2 fragCoord) {
    return readSSR(texture(colortex3, fragCoord).rgb);
}

vec2 readSSRLinear(vec2 fragCoord) {
    // TODONOW: ignore pixel if it is invalid ie 0,0
    vec2 frac = fract(fragCoord*colortex3Size);

    vec2 p = fragCoord - frac*colortex3TexelSize;
    uvec4 r = textureGather(colortex3, p, 0);
    uvec4 g = textureGather(colortex3, p, 1);
    uvec4 b = textureGather(colortex3, p, 2);

    // v0 v1
    // v3 v2
    vec2 v0 = readSSR(r.x, g.x, b.x); // 0 1
    vec2 v1 = readSSR(r.y, g.y, b.y); // 1 1
    vec2 v2 = readSSR(r.z, g.z, b.z); // 1 0
    vec2 v3 = readSSR(r.w, g.w, b.w); // 0 0

    float x0 = mix(mix(frac.x
        , 0, step(v3.x, 0)*step(v3.y, 0) )
        , 1, step(v2.x, 0)*step(v2.y, 0) );

    float x1 = mix(mix(frac.x
        , 0, step(v0.x, 0)*step(v0.y, 0) )
        , 1, step(v1.x, 0)*step(v1.y, 0) );

    vec2 m = mix(v3, v2, x0);
    vec2 n = mix(v0, v1, x1);

    vec2 result = mix(m, n, 
        mix(mix(frac.y
        , 0, step(m.x, 0)*step(m.y, 0) )
        , 1, step(n.x, 0)*step(n.y, 0) )
    );

    return result;
}