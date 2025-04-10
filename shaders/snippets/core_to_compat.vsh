#ifdef DISTANT_HORIZONS_SHADER  

    const vec3 vaNormal = gl_Normal.xyz;
    const vec4 vaColor = gl_Color.rgba;
    const vec3 vaPosition = gl_Vertex.xyz;
    const vec2 vaUV2 = gl_MultiTexCoord2.xy;
    const vec4 at_midBlock = vec4(0);
    const mat4 gbufferModelViewInverse = gl_ModelViewMatrixInverse;
    const mat4 gbufferModelView = gl_ModelViewMatrix;
    const mat4 modelViewMatrix = gl_ModelViewMatrix;
    const mat4 projectionMatrix = gl_ProjectionMatrix;

    const mat4 TEXTURE_MATRIX_2 = gl_TextureMatrix[1];
#else

    const mat4 TEXTURE_MATRIX_2 = mat4(vec4(0.00390625, 0.0, 0.0, 0.0), vec4(0.0, 0.00390625, 0.0, 0.0), vec4(0.0, 0.0, 0.00390625, 0.0), vec4(0.03125, 0.03125, 0.03125, 1.0));
#endif