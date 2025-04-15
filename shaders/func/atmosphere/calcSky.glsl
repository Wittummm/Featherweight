// Required Uniforms: gbufferModelViewInverse, sunAngle, shadowLightPosition
#ifndef calcSky_glsl
#define calcSky_glsl

#include "/func/atmosphere/skyNitisha.glsl"

// Directions inputs in view space
vec3 calcSky(vec3 dir, vec3 lightDir, float time) {
    dir = (mat3(gbufferModelViewInverse) * dir); // To Player Space
    lightDir = (mat3(gbufferModelViewInverse) * lightDir); // To Player Space
    dir.y += 0.08; // Bias, lowers the horizon a bit as we have a limited render distance

    // NOTE: Assumes moon is opposite of sun, but that may not always be the case
    // TODOEVENTUALLY: use `moonPosition` and `sunPosition` respectively
    vec3 sun = skyNitisha(dir, lightDir, time, 55, 1);
    vec3 moon = skyNitisha(dir, lightDir, -time, 5, 0.01);

    return mix(moon, sun, time > 0.5 ? abs(0.75 - time)*0.5 : 1);
}

vec3 calcSky(vec3 dir, vec3 lightDir) {
    return calcSky(dir, lightDir, sunAngle);
}

vec3 calcSky(vec3 dir) {
    return calcSky(dir, normalize(shadowLightPosition), sunAngle);
}

#endif