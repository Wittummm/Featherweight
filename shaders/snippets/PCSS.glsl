float blockerSearchOffset = MAX_SOFTNESS*PCSS_SEARCH_OFFSET_BIAS*softnessStrength*0.5;

float blockerDepth = 0; float blockerCount = 0;

for (int i = 0; i < PCSS_SEARCH_SAMPLES; ++i) {
    vec2 sampleOffset = goldenDiskSample(i, PCSS_SEARCH_SAMPLES) * blockerSearchOffset;
    float currentBlockerDepth = sampleShadowMap(shadowScreenPos.xy + sampleOffset);

    if (depth > currentBlockerDepth) {
        blockerDepth += currentBlockerDepth;
        blockerCount++;
    }
}

if (blockerCount > 0) {
    blockerDepth /= blockerCount;

    float penumbraSize = (((depth - blockerDepth) * LIGHT_SIZE)/blockerDepth)*softnessStrength;
    #ifdef PCSS_SAMPLES_MULT
        float pcssSamples = floor(clamp(penumbraSize*600*PCSS_SAMPLES_MULT, PCSS_MIN_SAMPLES, PCSS_MAX_SAMPLES));
        // float pcssSamples = PCSS_MIN_SAMPLES+floor(min(penumbraSize*600*PCSS_SAMPLES_MULT, PCSS_MAX_SAMPLES));
    #else
        float pcssSamples = SHADOW_SAMPLES;
    #endif
    shadowedBy = pcfSampleShadow(shadowScreenPos, pcssSamples, clamp(penumbraSize, MIN_SOFTNESS, MAX_SOFTNESS)); 
} 