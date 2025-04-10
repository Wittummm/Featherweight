#if DEBUG == 1
    #if _ISOLATE_LIGHTMAP == 1
        vertColor.rgb = vec3(lightMapCoord.xy, 0);
    #endif
#endif