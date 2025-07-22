// Allows for intercepting values written to fbo, if it is not used for a long time then REMOVE: it, 2025/21/7
vec3 readScene(vec3 compressed) {
    return compressed;
}
vec3 writeScene(vec3 linear) {
    return linear;
}

vec4 readScene(vec4 compressed) {
    return vec4(readScene(compressed.rgb), compressed.a);
}
vec4 writeScene(vec4 linear) {
    return vec4(writeScene(linear.rgb), linear.a);
}