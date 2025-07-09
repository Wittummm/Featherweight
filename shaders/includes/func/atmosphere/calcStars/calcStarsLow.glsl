#include "/includes/func/random/random2.glsl"
#include "/includes/func/misc/cubeMapProject.glsl"

float linearstep(float edge0, float edge1, float x) {
    return clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0);
}

vec3 calcStarsLow(vec3 viewDir) {
    int face;
    float rand = mix(STAR_INTENSITY_MIN, STAR_INTENSITY_MAX, 
        random( floor(cubeMapProject(viewDir, face)*(ap.game.screenSize.y/starRadius*0.5)) 
    ));

    return starColor * smoothstep(1-StarAmount*0.1, 1, rand);
}