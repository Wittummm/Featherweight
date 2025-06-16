#version 460 core

in vec2 texCoord;

void iris_emitFragment() {
    /*immut*/ vec4 texColor = iris_sampleBaseTex(texCoord);
    #ifdef CUTOUT
        if (iris_discardFragment(texColor)) discard;
    #endif
}
