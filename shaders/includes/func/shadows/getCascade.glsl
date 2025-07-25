#ifndef getCascade_glsl
#define getCascade_glsl

int getCascade(vec3 shadowView) {
    for(int cascade = 0; cascade < ShadowCascadeCount; cascade++){
        vec3 clip = mat3(ap.celestial.projection[cascade]) * shadowView  + ap.celestial.projection[cascade][3].xyz;

        if(all(lessThan(clip.xyz, vec3(1))) && all(greaterThan(clip.xyz, vec3(-1)))) {
            return cascade;
        }
    }
    return -1;
}

#endif