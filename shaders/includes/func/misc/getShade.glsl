float getShade(vec3 lightDir, vec3 normal) {
    return max(dot(lightDir, normal), 0);
}

