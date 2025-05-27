vec2 random2(vec2 p) {
    vec2 k = vec2(127.1, 311.7);
    float a = fract(sin(dot(p, k)) * 43758.5453123);
    float b = fract(sin(dot(p, k.yx)) * 43758.5453123);
    return vec2(a, b);
}

float random(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}