#version 460 core

uniform mat3 normalMatrix;
uniform mat4 gbufferModelViewInverse;
uniform float viewWidth;
uniform float viewHeight;

#include "/settings/debug.glsl"
#include "/func/depthToViewPos.glsl"
#include "/lib/pbr.glsl"
#if _SHOW_DEBUG_STATS == 1
#include "/lib/text_renderer.glsl"
uniform float frameTimeSmooth;
#endif
#if _SHOW_SSR != Off
#include "/settings/screen_space_reflections.glsl"
#include "/func/buffers/colortex3.glsl"
#endif

uniform float aspectRatio;
uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D shadowtex0;
uniform sampler2D depthtex0;
uniform float far;

#ifdef DISTANT_HORIZONS
    uniform sampler2D dhDepthTex0;
    uniform sampler2D dhDepthTex1;
#endif

in vec2 fragCoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 Color;

ivec2 moveTo(int position, ivec2 coord) {
    if (position == Off) {return ivec2(-1); }

    int x = int(viewWidth);
    int y = int(viewHeight);
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
    vec2 pixelSize = 1/vec2(viewWidth,viewHeight);
    ivec2 coord = ivec2(floor(fragCoord*vec2(viewWidth,viewHeight)));
    ivec2 squareCoord = ivec2(coord * vec2(aspectRatio, 1));
    vec4 color = texture(colortex0, fragCoord);

    Color = color;
   
    ivec2 A = moveTo(_SHOW_SHADOWMAP, squareCoord);
    if (clip(A)) { Color.rgb = vec3(texelFetch(shadowtex0, A, 0).r); }

    ivec2 AA = moveTo(_SHOW_DEPTHMAP, coord);
    if (clip(AA)) { Color.rgb = vec3((texelFetch(depthtex0, AA, 0).r-0.96)*25); }

#ifdef DISTANT_HORIZONS
    ivec2 B = moveTo(_SHOW_DH_DEPTH, coord);
    if (clip(B)) { Color.rgb = vec3(texelFetch(dhDepthTex0, B, 0).r); }
#endif
    
    ivec2 C = moveTo(_SHOW_ROUGHNESS, coord);
    if (clip(C)) { Color.rgb = vec3(roughnessRead(texelFetch(colortex1, C, 0).r)); }

    ivec2 D = moveTo(_SHOW_REFLECTANCE, coord);
    if (clip(D)) { Color.rgb = reflectanceRead(texelFetch(colortex1, D, 0).g, color.rgb); }

    ivec2 E = moveTo(_SHOW_POROSITY_SSS, coord);
    if (clip(E)) { 
        bool isPorosity = false;
        float porosity = porosityRead(texelFetch(colortex2, E, 0).b, isPorosity);
        Color.rgb = vec3(isPorosity ? porosity : -1, !isPorosity ? porosity : -1, 0); 
    }

    ivec2 F = moveTo(_SHOW_EMISSION, coord);
    if (clip(F)) { Color.rgb = vec3(texelFetch(colortex1, F, 0).a >= 0.996 ? 0 : texelFetch(colortex1, F, 0).a); }

    ivec2 G = moveTo(_SHOW_NORMALS, coord);
    if (clip(G)) { Color.rgb = vec3(normalsRead(texelFetch(colortex2, G , 0).rg)); }

    ivec2 H = moveTo(_SHOW_AO, coord);
    if (clip(H)) { Color.rgb = vec3(texelFetch(colortex2, H, 0).b); }

    ivec2 I = moveTo(_SHOW_HEIGHT, coord);
    if (clip(I)) { Color.rgb = vec3(texelFetch(colortex2, I, 0).a); }

    ivec2 J = moveTo(_SHOW_POSITION, coord);
    if (clip(J)) { Color.rgb = depthToViewPos(J, texelFetch(depthtex0, J, 0).r); }

    #if _SHOW_SSR != Off && SSR_ENABLED == 1
        ivec2 K = moveTo(_SHOW_SSR, coord);
        if (clip(K)) { 
            #if SSR_RESOUTION >= SSR_LINEAR_TURNOFF_THRESHOLD || _SHOW_SSR_FILTERING == 0
                vec3 hitCoord = readSSR(K*pixelSize);
            #elif SSR_RESOUTION < SSR_LINEAR_TURNOFF_THRESHOLD || _SHOW_SSR_FILTERING == 1
                vec3 hitCoord = readSSRLinear(K*pixelSize); 
            #endif
            
            Color.rgb = vec3(0);
            if (hitCoord.z > 0) {
                #if _SHOW_SSR_MODE == 0
                    Color.rgb = texture(colortex0, hitCoord.xy).rgb; 
                #elif _SHOW_SSR_MODE == 1
                    Color.rgb = vec3(hitCoord.xy, 0); 
                #elif _SHOW_SSR_MODE == 2
                    Color.rgb = vec3(hitCoord.z); 
                #endif
            }
        }
    #endif

    #if _SHOW_DEBUG_STATS == 1
        beginText(ivec2(gl_FragCoord.xy*0.5), ivec2(5, viewHeight*0.5 - 40));
        printFloat(frameTimeSmooth*1000); printString((_space, _m, _s));
        printLine(2);
        
        printString((_G, _L, _S, _L, _colon, _v)); printUnsignedInt(MC_GL_VERSION);
        printLine(2);

        uint fix = IRIS_VERSION % 100;
        uint minor = (IRIS_VERSION/100) % 100;
        uint major = IRIS_VERSION/10000;
        printString((_I, _r, _i, _s, _space, _v));
        printUnsignedInt(major); printString((_dot));
        printUnsignedInt(minor); printString((_dot));
        printUnsignedInt(fix);

        endText(Color.rgb);
    #endif
}