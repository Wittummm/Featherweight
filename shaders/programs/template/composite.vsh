#version 430 core

out vec2 fragCoord;

void main() {
    vec2 position = vec2(gl_VertexID % 2, gl_VertexID / 2) * 4.0 - 1.0;

    fragCoord = (position + 1.0) * 0.5;

    gl_Position = vec4(position, 0.0, 1.0);
}