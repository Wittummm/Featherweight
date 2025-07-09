#define HDR

// Allocate more precision to darker areas by applying gamma 2(or 3)
vec3 readScene(vec3 compressed) {
    #ifdef HDR
        return compressed*compressed;
    #else
        return compressed;
    #endif
}
vec3 writeScene(vec3 linear) {
    #ifdef HDR
        return sqrt(linear);
    #else
        return linear;
    #endif
}

vec4 readScene(vec4 compressed) {
    return vec4(readScene(compressed.rgb), compressed.a);
}
vec4 writeScene(vec4 linear) {
    return vec4(writeScene(linear.rgb), linear.a);
}