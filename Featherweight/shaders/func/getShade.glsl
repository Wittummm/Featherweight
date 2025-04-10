uniform vec3 upPosition;
uniform vec3 shadowLightPosition;

float lightAngle() {
    return dot(normalize(upPosition), normalize(shadowLightPosition));
}

float getShade(vec3 lightDir, vec3 normal) {
    return max(dot(lightDir, normal), 0);
}

