#ifndef calcSky_glsl
#define calcSky_glsl

#include "/includes/shared/settings.glsl"
#include "/includes/func/atmosphere/skyCustom.glsl"

// Directions inputs in view space
vec3 calcSkyNoStars(vec3 dir, vec2 intensity, vec2 attenuation) {
    return skyCustomNoStars(mat3(ap.camera.viewInv) * dir, intensity, attenuation); 
}

vec3 calcSkyNoStars(vec3 dir) {
    return skyCustomNoStars(mat3(ap.camera.viewInv) * dir); 
}

vec3 calcSky(vec3 dir) {
    if (Stars == 0) { // Vanilla stars, so no shader stars
        return calcSkyNoStars(dir);
    } else {
        return skyCustom(mat3(ap.camera.viewInv) * dir); 
    }
}

#endif

