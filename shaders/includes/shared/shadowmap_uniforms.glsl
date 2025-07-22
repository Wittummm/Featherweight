#ifndef shadowmap_uniforms_glsl
#define shadowmap_uniforms_glsl

#ifdef ShadowsEnabled
    uniform sampler2DArray shadowMap;
    uniform sampler2DArrayShadow shadowMapFiltered;
#endif

#endif