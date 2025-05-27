/*
const int colortex3Format = R32UI;
*/

uniform usampler2D colortex3;

const vec2 colortex3Size = vec2(textureSize(colortex3, 0));
const vec2 colortex3TexelSize = 1.0/colortex3Size;

uint writeSSR(vec2 _coord, float a) {
    uvec2 coord = uvec2(_coord.xy*4095.0);

    return coord.x | (coord.y << 12) | (uint(a*255.0) << 24);
}

vec3 readSSR(uint data) {
    vec2 coord = vec2(data & 0xFFFu, (data >> 12) & 0xFFFu) * 0.0002442002442002442;

    return vec3(coord, float(data >> 24)*0.00392156862745098);
}

vec3 readSSR(vec2 fragCoord) {
    return readSSR(texture(colortex3, fragCoord).r);
}

vec3 readSSRLinear(vec2 fragCoord) {
    vec2 frac = fract(fragCoord*colortex3Size);

    vec2 p = fragCoord - frac*colortex3TexelSize;
    uvec4 data = textureGather(colortex3, p, 0);

    // v0 v1
    // v3 v2
    vec3 v0 = readSSR(data.x); // 0 1
    vec3 v1 = readSSR(data.y); // 1 1
    vec3 v2 = readSSR(data.z); // 1 0
    vec3 v3 = readSSR(data.w); // 0 0

    float x0 = frac.x + (v0.x - v1.x)*SHARPNESS;
    float x1 = frac.x + (v3.x - v2.x)*SHARPNESS;

    vec2 m = mix(v0.xy, v1.xy, clamp(x0, 0, 1));
    vec2 n = mix(v3.xy, v2.xy, clamp(x1, 0, 1));

    float y0 = frac.y + (n.y - m.y)*SHARPNESS;
    vec3 result = vec3(
        mix(n, m, clamp(y0, 0, 1)), 
        v3.z
    );

    return result;
}