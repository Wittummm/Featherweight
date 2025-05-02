/*
const int colortex3Format = R32UI;
*/

uniform usampler2D colortex3;

const vec2 colortex3Size = vec2(textureSize(colortex3, 0));
const vec2 colortex3TexelSize = 1.0/colortex3Size;

uint writeSSR(vec2 _coord, float a) {
    uvec2 coord = uvec2(_coord.xy*4095.0);

    return coord.x | (coord.y << 12) | (uint(a*255) << 24);
}

vec3 readSSR(uint data) {
    vec2 coord = vec2(data & 0xFFFu, (data >> 12) & 0xFFFu) * 0.0002442002442002442;

    return vec3(coord, float(data >> 24)*0.00392156862745098);
}

vec3 readSSR(vec2 fragCoord) {
    return readSSR(texture(colortex3, fragCoord).r);
}

vec3 readSSRLinear(vec2 fragCoord) {
    // TODONOW: ignore pixel if it is invalid ie 0,0
    vec2 frac = fract(fragCoord*colortex3Size);

    vec2 p = fragCoord - frac*colortex3TexelSize;
    uvec4 data = textureGather(colortex3, p, 0);

    // v0 v1
    // v3 v2
    vec3 v0 = readSSR(data.x); // 0 1
    vec3 v1 = readSSR(data.y); // 1 1
    vec3 v2 = readSSR(data.z); // 1 0
    vec3 v3 = readSSR(data.w); // 0 0

    float x0 = mix(mix(frac.x
        , 0, step(v3.x, 0)*step(v3.y, 0) )
        , 1, step(v2.x, 0)*step(v2.y, 0) );

    float x1 = mix(mix(frac.x
        , 0, step(v0.x, 0)*step(v0.y, 0) )
        , 1, step(v1.x, 0)*step(v1.y, 0) );

    vec3 m = mix(v3, v2, x0);
    vec3 n = mix(v0, v1, x1);

    vec3 result = mix(m, n, 
        mix(mix(frac.y
        , 0, step(m.x, 0)*step(m.y, 0) )
        , 1, step(n.x, 0)*step(n.y, 0) )
    );

    return result;
}