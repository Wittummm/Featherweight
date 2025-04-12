// CAUTION: This snippet MUST be put in the top of the main function 
// and CANNOT be outside or else it will crash :)

#ifdef DISTANT_HORIZONS_SHADER  

    const mat4 gbufferModelViewInverse = gl_ModelViewMatrixInverse;
    const mat4 modelViewMatrix = gl_ModelViewMatrix;
    const mat4 projectionMatrix = gl_ProjectionMatrix;
    
#endif