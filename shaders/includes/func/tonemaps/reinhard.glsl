vec3 reinhard(vec3 color) {
    return color / (color + 1.0);
}

vec3 reinhardModified(vec3 x) {
    const vec3 L_white = vec3(3);
    return (x * (1.0 + x / (L_white * L_white))) / (1.0 + x);
}