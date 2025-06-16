#ifndef goldenDiskSample_glsl
#define goldenDiskSample_glsl

vec2 goldenDiskSample(float index, float count) {
    float theta = index * 2.4;
    float r = sqrt((index + 0.5) / count);

    return vec2(r * cos(theta), r* sin(theta));
}

#endif