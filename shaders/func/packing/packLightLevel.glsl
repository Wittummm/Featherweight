
float packLightLevel(vec2 lightmapCoord) {
    return lightmapCoord.y;
}

vec2 unpackLightLevel(float lightmapCoord) {
   return vec2(0, lightmapCoord);
}

/*
DESC: This is currently unused as it is imprecise as i dont need block light values rn, 
so ill just store just the full precision skylight :)

// NOTE: Packed values cannot be interpolated so it MUST be in the fragment shader NOT vertex.
#include "/func/dither/dither4.glsl"

float packLightLevel(vec2 lightmapCoord) {
    // Dithering; Not sure if this is completely 100% correct as it seems its like half the width its supposed to actually be
    lightmapCoord += fract(lightmapCoord*15) * 0.06666666666666667 * dither4(gl_FragCoord.xy);
    const uint x = uint(lightmapCoord.x*15);
    const uint y = uint(lightmapCoord.y*15);
    return float((x << 4) | y)/255.0;
}

vec2 unpackLightLevel(float _lightmapCoord) {
    uint lightmapCoord = uint(_lightmapCoord * 255.0);
    return vec2(lightmapCoord >> 4, lightmapCoord & 15)/15.0;
}


*/