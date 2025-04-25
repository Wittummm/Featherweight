// CAUTION: This snippet MUST be put in the top of the main function 
// and CANNOT be outside or else it will crash :)

#ifdef DISTANT_HORIZONS_SHADER  
    vec3 vaNormal = gl_Normal.xyz;
    vec4 vaColor = gl_Color.rgba;
    vec3 vaPosition = gl_Vertex.xyz;
    vec2 vaUV2 = gl_MultiTexCoord1.xy;
    mat4 modelViewMatrix = gl_ModelViewMatrix;
    mat4 projectionMatrix = gl_ProjectionMatrix;

    const mat4 textureMatrix2 = mat4(1);
#else

    const mat4 textureMatrix2 = mat4(vec4(0.00390625, 0.0, 0.0, 0.0), vec4(0.0, 0.00390625, 0.0, 0.0), vec4(0.0, 0.0, 0.00390625, 0.0), vec4(0.03125, 0.03125, 0.03125, 1.0));
#endif