#ifndef getCascade_glsl
#define getCascade_glsl

int getCascade(vec3 shadowView) {
    for(int cascade = 0; cascade < ShadowCascadesCount; cascade++){
        vec3 clip = (ap.celestial.projection[cascade] * vec4(shadowView, 1)).xyz;

        if(all(lessThan(clip.xyz, vec3(1))) && all(greaterThan(clip.xyz, vec3(-1)))) {
            return cascade;
        }
    }
    return -1;
}

#endif