void fadeShadows(vec3 playerPos, out float alpha, out float softness) {
    alpha = 1;
    softness = 1;
    // TODONOWBUTLATER: port below to use uniforms settings
// #if SHADOW_FADE_OUT == Circle
//     float dist = length(playerPos.xyz)/shadowDistance;

//     if (SHADOW_FADE_OUT_STRENGTH > 0 && dist > SHADOW_FADE_OUT_START) { alpha = 1-((dist-SHADOW_FADE_OUT_START)*SHADOW_FADE_OUT_STRENGTH); }

//     #ifdef SHADOW_SOFTNESS
//         if (SHADOW_SOFTNESS_FADE_OUT_STRENGTH > 0 && dist > SHADOW_SOFTNESS_FADE_OUT_START) { softness = max(1-((dist-SHADOW_SOFTNESS_FADE_OUT_START)*SHADOW_SOFTNESS_FADE_OUT_STRENGTH), 0); }
//     #endif 
// #elif SHADOW_FADE_OUT == Box
//     vec3 dist = abs(playerPos.xyz/shadowDistance);
//     float maxAxis = max(dist.x,max(dist.y,dist.z));

//     if (SHADOW_FADE_OUT_STRENGTH > 0 && maxAxis > SHADOW_FADE_OUT_START) {
//         alpha = 1-((maxAxis-SHADOW_FADE_OUT_START)*SHADOW_FADE_OUT_STRENGTH);
//     }

//     #ifdef SHADOW_SOFTNESS
//         if (SHADOW_SOFTNESS_FADE_OUT_STRENGTH > 0 && maxAxis > SHADOW_SOFTNESS_FADE_OUT_START) {
//            softness = max(1-((maxAxis-SHADOW_SOFTNESS_FADE_OUT_START)*SHADOW_FADE_OUT_STRENGTH), 0);
//         }
//     #endif
// #endif
}

void fadeShadows(vec3 playerPos, out float alpha) {
    float _ = 0;
    fadeShadows(playerPos, alpha, _);
}