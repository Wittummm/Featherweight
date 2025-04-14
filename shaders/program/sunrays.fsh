#version 460 core
// Resources: "https://www.shadertoy.com/view/XsfSDs", "https://developer.nvidia.com/gpugems/gpugems3/part-ii-light-and-shadows/chapter-13-volumetric-light-scattering-post-process"
/* RGR - Radial God Rays
 - Adds screen-space basic sun shafts
 - Bloom-like effect on the body as a side effect

Bugs/Limitations:
    - The shaft can go through objects and looks quite bad, idk how to fix this, this is mitigated by `SUNRAYS_SPREAD`
    - `PassTint` may display color incorrectly when objects behind the glass is strongly colored too
*/
#include "/common/shader.glsl"
//

#define SUNRAYS_STRENGTH 1 // [0.2 0.4 0.6 0.8 1 1.1 1.25 1.5 1.75 2 2.25 2.5 3 3.5 4 4.5 5]

#define SUNRAYS_SPREAD 0.6 // [0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1]
#define SUNRAYS_SAMPLES 1 // [0.25 0.5 1 1.5 2 2.5 3 3.5 4]
#define SUNRAYS_FAKE_SAMPLES 1 // [0 0.5 1 1.5 2 2.5 3 3.5 4] {Multiples the sample count via dithering}
#define SUNRAYS_ORIGIN_SIZE 0.25 // [0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5] // 0.2
#define SUNRAYS_AUTO_FAKE_SAMPLES On // [Off On]
const float falloff = 5; // How tight the falloff is, higher is tighter

#define Diamond Low
#define Circle Medium
#define SUNRAYS_ORIGIN_SHAPE Circle // [Diamond Circle] {Diamond is may be cheaper}

#define SUNRAYS_MODE 1 // [0 1 2 3 4] {Off Block Pass PassDarken PassTint(EXPERIMENTAL! EXPECT BUGS)}
#define SUNRAYS_MAX_TRANSPARENCY 0.75 // [0 0.5 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1]
#define SUNRAYS_TINT_STRENGTH 1 // [0.5 1 1.5 2 2.5 3 3.5 4]

#define SUNRAYS_SAMPLES_OVERRIDE Off // [Off 10 20 30 40 50 60 70 80 100 120 140 160 180 200]
#if SUNRAYS_SAMPLES_OVERRIDE == Off
    const float samples = SUNRAYS_SPREAD*SUNRAYS_SAMPLES*25;
#else
    const float samples = SUNRAYS_SAMPLES_OVERRIDE;
#endif
const float oneOverSamples = 1.0/samples;
const float precompute = SUNRAYS_SPREAD * (1.0 / (samples - 1.0));

//

#ifdef DISTANT_HORIZONS
    uniform sampler2D dhDepthTex0;
    uniform sampler2D dhDepthTex1;
#endif
uniform sampler2D depthtex0;
uniform sampler2D depthtex1;
uniform vec3 skyColor;
uniform sampler2D colortex0;
uniform vec3 shadowLightPosition;
uniform vec3 upPosition;
uniform float aspectRatio;
uniform vec4 lightColor;

in vec2 texCoord;
in vec3 vertPosition;
in vec2 lightPos;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

const vec2 applyAspectRatio = vec2(aspectRatio, 1);

float sampleDepth0(vec2 samplePos) {
    const float depth = textureLod(depthtex0, samplePos, 0).r;
    #ifdef DISTANT_HORIZONS
        if (depth < 1) { return depth; }
        else { return textureLod(dhDepthTex0, samplePos, 0).r; }
    #else
        return depth;
    #endif
}

float sampleDepth1(vec2 samplePos) {
    const float depth = textureLod(depthtex1, samplePos, 0).r;
    #ifdef DISTANT_HORIZONS
        if (depth < 1) { return depth; }
        else { return textureLod(dhDepthTex1, samplePos, 0).r; }
    #else
        return depth;
    #endif
}

void main() {
    color = textureLod(colortex0, texCoord, 0);

    const vec3 lightDir = normalize(shadowLightPosition);
    const float strength = -lightDir.z*1.4;
    if (strength <= 0) {return;}

#if SUNRAYS_AUTO_FAKE_SAMPLES == On
    const float adjustedFakeSampleMult = SUNRAYS_FAKE_SAMPLES > 0 ? SUNRAYS_FAKE_SAMPLES + ceil((1+lightDir.z)*4)*0.5 : SUNRAYS_FAKE_SAMPLES;
#else
    const float adjustedFakeSampleMult = SUNRAYS_FAKE_SAMPLES;
#endif

    const vec2 uv = texCoord - lightPos;
    const float offset = adjustedFakeSampleMult > 1 ? length(fract(gl_FragCoord.xy/adjustedFakeSampleMult)*precompute) : 0;
    const float blurStart = ((1-SUNRAYS_SPREAD) - offset) ;
    const float blurStartOffseted = blurStart - offset;
    const vec2 uvCorrected = uv*applyAspectRatio;

#if SUNRAYS_MODE == 4
    vec3 rayColor = lightColor.rgb;
    int rayColorCount = 1;
#endif
    float rayAlpha = 0;
    for(float i = 0; i < samples; i++) {
        const mediump float scale = blurStartOffseted + (i * precompute);
        #if SUNRAYS_ORIGIN_SHAPE == Diamond
            const vec2 scaledUV = abs(uvCorrected*scale);
            const float len = (scaledUV.x + scaledUV.y)*0.75; // Compensate a bit to match Circle
        #elif SUNRAYS_ORIGIN_SHAPE == Circle
            const float len = length(uvCorrected*scale);
        #endif

        // Sun mask
        if (len < SUNRAYS_ORIGIN_SIZE) {
            const vec2 samplePos = (uv * scale) + lightPos;
            float blockTransparency = 1;
           
        #if SUNRAYS_MODE == 1
            const float depth = sampleDepth0(samplePos);
        #elif SUNRAYS_MODE == 2
            const float depth = textureLod(depthtex1, samplePos, 0).r;
        #elif SUNRAYS_MODE == 3 || SUNRAYS_MODE == 4
            const float depth = textureLod(depthtex1, samplePos, 0).r;
            blockTransparency = depth - textureLod(depthtex0, samplePos, 0).r > 0 ? SUNRAYS_MAX_TRANSPARENCY : 1; 

            #if SUNRAYS_MODE == 4
                // Probably not physically accurate tinting at all
                if (blockTransparency < 1 && blockTransparency > 0) {
                    const vec3 tint = textureLod(colortex0, samplePos, 0).rgb; 
                    blockTransparency *= dot(tint, skyColor); // Closer to skyColor = more transparent
                    rayColor = mix(rayColor+tint, rayColor*tint*SUNRAYS_TINT_STRENGTH, (1-blockTransparency) * 1.5 * max(tint.x, max(tint.y, tint.z)));
                    rayColorCount++;
                }
            #endif
        #endif

            const float reduceSunIntensity = ((samples - i) * oneOverSamples);// Inverts the influence when its on the sun itself, so sun isnt super bright
            const float spreadStrength = (SUNRAYS_ORIGIN_SIZE-len-0.05)*2; 

            rayAlpha += blockTransparency * step(1, depth) * reduceSunIntensity * spreadStrength; 
        }
    }
#if SUNRAYS_MODE == 4
    const vec3 rayColorFactor = mix(lightColor.rgb, normalize(rayColor/float(rayColorCount)), SUNRAYS_MAX_TRANSPARENCY);
#else
    const vec3 rayColorFactor = lightColor.rgb;
#endif
    color.rgb += rayColorFactor*(rayAlpha*oneOverSamples)*lightColor.a*strength*SUNRAYS_STRENGTH;
}