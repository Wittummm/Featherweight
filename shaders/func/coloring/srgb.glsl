// Source: https://chilliant.blogspot.com/2012/08/srgb-approximations-for-hlsl.html

vec3 srgbToLinear(vec3 srgb) {
    return srgb * (srgb * (srgb * 0.305306011 + 0.682171111) + 0.012522878);
}

vec3 linearToSRGB(vec3 linear) {
    return max(1.055 * pow(linear, vec3(0.416666667)) - 0.055, 0);
}
//////////////////
vec4 srgbToLinear(vec4 srgb) {
    return vec4(srgbToLinear(srgb.rgb), srgb.a);
}

vec4 linearToSRGB(vec4 linear) {
    return vec4(linearToSRGB(linear.rgb), linear.a);
}