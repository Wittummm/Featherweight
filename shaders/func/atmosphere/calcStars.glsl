uniform sampler2D sparkle;

#define STAR_SHAPE 1 // [0 1] {Textured Circle}

// TODO: make star have varying intensities

// TODONOW: finalize below and turn into config(internal config?)
const float stars = 0.02;
const uint cellSize = 10;
const float starRadius = 1;
const float padding = 0.5;
const vec3 starColor = vec3(0.9412, 0.9333, 0.898);

// This is hardcoded, use above controls (do not use this: SCALE)
#define SCALE 1000

uint murmurMix32 (uint h) {
  h ^= h >> 16;
  h *= 0x85ebca6b;
  h ^= h >> 13;
  h *= 0xc2b2ae35;
  h ^= h >> 16;

  return h;
}

// Returns [-1, 1]
vec2 cubeMapProject(vec3 dir, out int face) {
    vec3 absDir = abs(dir);

    if (absDir.x >= absDir.y && absDir.x >= absDir.z) {
        // Major axis is X
        if (dir.x > 0.0) {
            face = 0; // +X
            return vec2(-dir.z, dir.y);
        } else {
            face = 1; // -X
            return vec2(dir.z, dir.y);
        }
    } else if (absDir.y >= absDir.x && absDir.y >= absDir.z) {
        // Major axis is Y
        if (dir.y > 0.0) {
            face = 2; // +Y
            return vec2(dir.x, -dir.z); // something wrong here
        } else {
            face = 3; // -Y
            return vec2(dir.x, dir.z);
        }
    } else {
        // Major axis is Z
        if (dir.z > 0.0) {
            face = 4; // +Z
            return vec2(dir.x, dir.y);
        } else {
            face = 5; // -Z
            return vec2(-dir.x, dir.y);
        }
    }
}

vec3 calcStars(vec2 pixelCoord) {
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
    bool reject = hash > stars*4294967295u;

    if (!reject) {
            vec2 jitter = vec2(sin(hash*1.3e-4), cos(hash*0.8e-4)) * jitterOffset;
            vec2 starPos = floor(gridPos + cellSize*0.5 + jitter);
            float starIntensity = mix(0.08, 1, sin(hash*2.8e-5)*0.5 + 0.5);

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

    return calcStars(pixelCoord);
}