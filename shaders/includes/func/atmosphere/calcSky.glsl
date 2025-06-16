#ifndef calcSky_glsl
#define calcSky_glsl

uniform float eyeAltitude;
#include "/includes/func/atmosphere/skyCustom.glsl"

// Directions inputs in view space
vec3 calcSky(vec3 dir, vec2 intensity, vec2 attenuation) {
    return skyCustomNoStars(mat3(ap.camera.viewInv) * dir, intensity, attenuation); 
}

vec3 calcSky(vec3 dir) {
    return skyCustomNoStars(mat3(ap.camera.viewInv) * dir); 
}

vec3 calcSkyWithStars(vec3 dir) {
    return skyCustom(mat3(ap.camera.viewInv) * dir); 
}

#endif