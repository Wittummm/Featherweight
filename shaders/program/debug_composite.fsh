#version 460 core

uniform mat3 normalMatrix;
uniform mat4 gbufferModelViewInverse;

#include "/settings/debug.glsl"
#include "/func/depthToViewPos.glsl"
#include "/lib/pbr.glsl"

uniform float aspectRatio;
uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D shadowtex0;
uniform sampler2D depthtex0;
uniform float far;
uniform float viewWidth;
uniform float viewHeight;

#ifdef DISTANT_HORIZONS
    uniform sampler2D dhDepthTex0;
#endif

in vec2 texCoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 Color;

ivec2 moveTo(int position, ivec2 coord) {
    if (position == Off) {return ivec2(-1); }

    const int x = int(viewWidth);
    const int y = int(viewHeight);
    if (position == Fullscreen) {
        coord = coord;
    } else if (position == BottomLeft) {
        coord = coord * 2;
    } else if (position == BottomRight) {
        coord = ivec2(-x, 0) + coord*2;
    } else if (position == TopLeft) {
        coord = ivec2(0, -y) + coord*2;
    } else if (position == TopRight) {
        coord = ivec2(-x, -y) + coord*2;
    }

    return ivec2(coord);
}

// is inside bounds
bool clip(ivec2 coord) {
    return coord.x < viewWidth && coord.y < viewHeight && coord.x >= 0 && coord.y >= 0;
}

void main() {
    const ivec2 coord = ivec2(floor(texCoord*vec2(viewWidth,viewHeight)));
    const ivec2 squareCoord = ivec2(coord * vec2(aspectRatio, 1));
    const vec4 color = texture(colortex0, texCoord);

    Color = color;
   
    const ivec2 A = moveTo(_SHOW_SHADOWMAP, squareCoord);
    if (clip(A)) { Color.rgb = vec3(texelFetch(shadowtex0, A, 0).r); }

    const ivec2 AA = moveTo(_SHOW_DEPTHMAP, coord);
    if (clip(AA)) { Color.rgb = vec3((texelFetch(depthtex0, AA, 0).r-0.96)*25); }

#ifdef DISTANT_HORIZONS
    const ivec2 B = moveTo(_SHOW_DH_DEPTH, coord);
    if (clip(B)) { Color.rgb = vec3(texelFetch(dhDepthTex0, B, 0).r); }
#endif
    
    const ivec2 C = moveTo(_SHOW_ROUGHNESS, coord);
    if (clip(C)) { Color.rgb = vec3(roughnessRead(texelFetch(colortex1, C, 0).r)); }

    const ivec2 D = moveTo(_SHOW_REFLECTANCE, coord);
    if (clip(D)) { Color.rgb = reflectanceRead(texelFetch(colortex1, D, 0).g, color.rgb); }

    const ivec2 E = moveTo(_SHOW_POROSITY_SSS, coord);
    if (clip(E)) { 
        bool isPorosity = false;
        const float porosity = porosityRead(texelFetch(colortex2, E, 0).b, isPorosity);
        Color.rgb = vec3(isPorosity ? porosity : -1, !isPorosity ? porosity : -1, 0); 
    }

    const ivec2 F = moveTo(_SHOW_EMISSION, coord);
    if (clip(F)) { Color.rgb = vec3(texelFetch(colortex1, F, 0).a >= 0.996 ? 0 : texelFetch(colortex1, F, 0).a); }

    const ivec2 G = moveTo(_SHOW_NORMALS, coord);
    if (clip(G)) { Color.rgb = vec3(normalsRead(texelFetch(colortex2, G , 0).rg)); }

    const ivec2 H = moveTo(_SHOW_AO, coord);
    if (clip(H)) { Color.rgb = vec3(texelFetch(colortex2, H, 0).b); }

    const ivec2 I = moveTo(_SHOW_HEIGHT, coord);
    if (clip(I)) { Color.rgb = vec3(texelFetch(colortex2, I, 0).a); }

    const ivec2 J = moveTo(_SHOW_POSITION, coord);
    if (clip(J)) { Color.rgb = depthToViewPos(J, texelFetch(depthtex0, J, 0).r); }
}