// Required Uniforms: gbufferModelViewInverse, sunAngle, shadowLightPosition
#ifndef calcSky_glsl
#define calcSky_glsl

uniform float eyeAltitude;
#include "/func/atmosphere/skyCustom.glsl"

// Directions inputs in view space
vec3 calcSky(vec3 dir, vec3 lightDir, float time) {
    dir = (mat3(gbufferModelViewInverse) * dir); // To Player Space
    lightDir = (mat3(gbufferModelViewInverse) * lightDir); // To Player Space

    return skyCustom(dir); // /TODONOWBUTLATER REMOVAL: remove these comments as is unneeded
}

vec3 calcSky(vec3 dir, vec3 lightDir) {
    return calcSky(dir, lightDir, sunAngle); // /TODONOWBUTLATER REMOVAL: remove these comments as is unneeded
}

vec3 calcSky(vec3 dir) {
    return calcSky(dir, normalize(shadowLightPosition), sunAngle);
}

// Kinda hacky
vec3 calcSkyNoHorizon(vec3 dir, vec3 lightDir, float time) {
    // dir = (mat3(gbufferModelViewInverse) * dir); // To Player Space
    // lightDir = (mat3(gbufferModelViewInverse) * lightDir); // To Player Space
    return vec3(0);
}

vec3 calcSkyNoHorizon(vec3 dir, vec3 lightDir) {
    return calcSkyNoHorizon(dir, lightDir, sunAngle);
}

vec3 calcSkyNoHorizon(vec3 dir) {
    return calcSkyNoHorizon(dir, normalize(shadowLightPosition), sunAngle);
}

#endif