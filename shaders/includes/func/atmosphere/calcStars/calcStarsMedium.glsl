#include "/includes/func/misc/cubeMapProject.glsl"

#if STAR_SHAPE == 0
uniform sampler2D sparkle;
#endif

// This is hardcoded, use actual controls (do not use this: SCALE)
#define SCALE 1000

uint murmurMix32 (uint h) {
  h ^= h >> 16;
  h *= 0x85ebca6b;
  h ^= h >> 13;
  h *= 0xc2b2ae35;
  h ^= h >> 16;

  return h;
}

vec3 _calcStars(vec2 pixelCoord) {
    /* Algorithm I came up from scratch(somewhat)
    - Divide the screen into Cells
    - For each cell, shuffle the index and threshold reject using that index
    - If not rejected then jitter from the center to get the star position

    This ensures that there is some space between stars
    */

    // below is derived consts
    const float jitterOffset = max(cellSize*0.5 - starRadius - padding, 0);

    vec2 gridPos = floor(pixelCoord/cellSize)*cellSize;
    uint hash = murmurMix32(uint(gridPos.x + gridPos.y*SCALE));
    bool reject = hash > starAmount*4294967295u;

    if (!reject) {
            vec2 jitter = vec2(sin(hash*1.3e-4), cos(hash*0.8e-4)) * jitterOffset;
            vec2 starPos = floor(gridPos + cellSize*0.5 + jitter);
            float starIntensity = mix(STAR_INTENSITY_MIN, STAR_INTENSITY_MAX, sin(hash*2.8e-5)*0.5 + 0.5);

        #if STAR_SHAPE == 0
            if ( all(lessThanEqual(abs(pixelCoord - starPos), vec2(starRadius))) ) {
                vec2 texCoord = (((pixelCoord - starPos)/starRadius)+1.0)*0.5;
                return texture(sparkle, texCoord).rgb * starColor * starIntensity;
        #else
            if (distance(starPos, pixelCoord) <= starRadius) {
                return starColor * starIntensity;
        #endif
            }
    }

    return vec3(0);
}

vec3 calcStars(vec3 viewDir) {
    // TODOEVENTUALLY: Use a simpler but good enough projection
    // NOTE: Cubemap projection is likely overkill and expensive, a simple low distortion projection should suffice.
    int face;
    vec2 pixelCoord = (cubeMapProject(viewDir, face)*0.5 + 0.5) * SCALE; // Theres seams but we just hope user doesnt see that
    pixelCoord.y += face;

    return _calcStars(pixelCoord);
}