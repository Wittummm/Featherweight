#if DEBUG == 1
    #ifdef _SHADOW_FADE_OUT
        // float shadowAlpha = 1; float softness = 1;
        // fadeShadows(playerPos, shadowAlpha, softness);
        // color.rgb = mix(color.rgb, vec3(shadowAlpha-softness, softness, 0), _SHADOW_FADE_OUT);
    #endif

    #if _ISOLATE_DIFFUSE == 1
        Color.rgb = vec3(_diffuseAlpha);
    #elif _ISOLATE_DIFFUSE == 2
        Color.rgb = vec3(shade, 0, 0);
    #elif _ISOLATE_DIFFUSE == 3
        Color.rgb = vec3(lightness, 0, 0);
    #elif _ISOLATE_DIFFUSE == 4
        Color.rgb = vec3(shade, 0, lightness);
        
    #elif _ISOLATE_VERT_COLOR == 1 
        Color.rgb = vertColor.rgb;
    #elif _ISOLATE_SKYLIGHT == 1
        Color.rgb = vec3(lightmapCoord.y);
    #endif
#endif