// Required Uniforms: gbufferModelViewInverse, sunAngle, shadowLightPosition
#ifndef calcSky_glsl
#define calcSky_glsl

uniform float eyeAltitude;
#include "/func/atmosphere/skyNitisha.glsl"

// Directions inputs in view space
vec3 calcSky(vec3 dir, vec3 lightDir, float time) {
    dir = (mat3(gbufferModelViewInverse) * dir); // To Player Space
    lightDir = (mat3(gbufferModelViewInverse) * lightDir); // To Player Space
    // dir.y += 0.13; // Bias, lowers the horizon a bit as we have a limited render distance
    dir.y += 0.1 + eyeAltitude*0.002;
    
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

// Kinda hacky
vec3 calcSkyNoHorizon(vec3 dir, vec3 lightDir, float time) {
    dir = (mat3(gbufferModelViewInverse) * dir); // To Player Space
    lightDir = (mat3(gbufferModelViewInverse) * lightDir); // To Player Space
    dir.y = (dir.y+1)*0.5;

    float alpha = time > 0.5 ? abs(0.75 - time)*0.5 : 1;

    // NOTE: Assumes moon is opposite of sun, but that may not always be the case
    // TODOEVENTUALLY: use `moonPosition` and `sunPosition` respectively
    vec3 sun = skyNitisha(dir, lightDir, time, 55, 1);
    if (alpha < 1) {
        vec3 moon = skyNitisha(dir, lightDir, -time, 5, 0.01);
        return mix(moon, sun, alpha);
    } else {
        return sun;
    }
}

vec3 calcSkyNoHorizon(vec3 dir, vec3 lightDir) {
    return calcSkyNoHorizon(dir, lightDir, sunAngle);
}

vec3 calcSkyNoHorizon(vec3 dir) {
    return calcSkyNoHorizon(dir, normalize(shadowLightPosition), sunAngle);
}

#endif