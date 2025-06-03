#version 460 core
// Resources: "https://www.shadertoy.com/view/XsfSDs", "https://developer.nvidia.com/gpugems/gpugems3/part-ii-light-and-shadows/chapter-13-volumetric-light-scattering-post-process"
/* RGR - Radial God Rays
 - Adds screen-space basic sun shafts
 - Bloom-like effect on the body as a side effect

Bugs/Limitations:
    - The shaft can go through objects and looks quite bad, idk how to fix this, this is mitigated by `sunraysSpread`
    - `PassTint` may display Color incorrectly when objects behind the glass is strongly colored too
*/
#include "/common/shader.glsl"
//

#define SUNRAYS_STRENGTH 1.5 // [0.5 0.75 1 1.25 1.5 1.75 2 2.5]
#define SUNRAYS_SPREAD 1 // [0.5 0.75 1 1.25 1.5]
#define SUNRAYS_ORIGIN_SIZE 1 // [0.75 1 1.25 1.5] 

uniform float sunraysStrength;
uniform float sunraysSpread; 
uniform vec3 sunraysColor;
uniform float sunraysOriginSize;

#define SUNRAYS_SAMPLES 1 // [0.25 0.5 1 1.5 2 2.5 3 3.5 4]
#define SUNRAYS_FAKE_SAMPLES 1 // [0 0.5 1 1.5 2 2.5 3 3.5 4] {Multiples the sample count via dithering}
#define SUNRAYS_AUTO_FAKE_SAMPLES On // [Off On]
const float falloff = 5; // How tight the falloff is, higher is tighter

#define Diamond Low
#define Circle Medium
#define SUNRAYS_ORIGIN_SHAPE Circle // [Diamond Circle] {Diamond is may be cheaper}

#define SUNRAYS_MODE 1 // [0 1 2 3] {Off Block PassDarken PassTint(EXPERIMENTAL! EXPECT BUGS)}
#define SUNRAYS_MAX_TRANSPARENCY 0.75 // [0 0.5 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1]
#define SUNRAYS_TINT_STRENGTH 0.5 // [0.5 1 1.5 2 2.5 3 3.5 4]

#define SUNRAYS_SAMPLES_OVERRIDE Off // [Off 10 20 30 40 50 60 70 80 100 120 140 160 180 200]
#if SUNRAYS_SAMPLES_OVERRIDE == Off
    const float samples = sunraysSpread*SUNRAYS_SAMPLES*25;
#else
    const float samples = SUNRAYS_SAMPLES_OVERRIDE;
#endif
const float oneOverSamples = 1.0/samples;
const float precompute = sunraysSpread * (1.0 / (samples - 1.0));

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
uniform bool isEyeUnderwater;

in vec2 texCoord;
in vec3 vertPosition;
in vec2 lightPos;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 Color;

const vec2 applyAspectRatio = vec2(aspectRatio, 1);

float sampleDepth0(vec2 samplePos) {
    vec4 depths = textureGather(depthtex0, samplePos);
    float depth = min(depths.x, min(depths.y, min(depths.z, depths.w))); // Soft, less streaky, less flickerly than naive sampling, multi-tap would be nicer but probably overkill

    #ifdef DISTANT_HORIZONS
        if (depth < 1) { return depth; }
        else { return textureLod(dhDepthTex0, samplePos, 0).r; }
    #else
        return depth;
    #endif
}

float sampleDepth1(vec2 samplePos) {
    vec4 depths = textureGather(depthtex1, samplePos);
    float depth = min(depths.x, min(depths.y, min(depths.z, depths.w))); // Soft, less streaky, less flickerly than naive sampling, multi-tap would be nicer but probably overkill

    #ifdef DISTANT_HORIZONS
        if (depth < 1) { return depth; }
        else { return textureLod(dhDepthTex1, samplePos, 0).r; }
    #else
        return depth;
    #endif
}

void main() {
    Color = textureLod(colortex0, texCoord, 0);

    vec3 lightDir = normalize(shadowLightPosition);
    float strength = -lightDir.z*1.4;
    if (strength <= 0) {return;}

#if SUNRAYS_AUTO_FAKE_SAMPLES == On
    float adjustedFakeSampleMult = SUNRAYS_FAKE_SAMPLES > 0 ? SUNRAYS_FAKE_SAMPLES + ceil((1+lightDir.z)*4)*0.5 : SUNRAYS_FAKE_SAMPLES;
#else
    float adjustedFakeSampleMult = SUNRAYS_FAKE_SAMPLES;
#endif

    vec2 uv = texCoord - lightPos;
    float offset = adjustedFakeSampleMult > 1 ? length(fract(gl_FragCoord.xy/adjustedFakeSampleMult)*precompute) : 0;
    float blurStart = ((1-sunraysSpread) - offset) ;
    float blurStartOffseted = blurStart - offset;
    vec2 uvCorrected = uv*applyAspectRatio;

#if SUNRAYS_MODE == 3
    vec3 rayColor = sunraysColor;
    int rayColorCount = 1;
#endif
    float rayAlpha = 0;
    for(float i = 0; i < samples; i++) {
        float scale = blurStartOffseted + (i * precompute);
        #if SUNRAYS_ORIGIN_SHAPE == Diamond
            vec2 scaledUV = abs(uvCorrected*scale);
            float len = (scaledUV.x + scaledUV.y)*0.75; // Compensate a bit to match Circle
        #elif SUNRAYS_ORIGIN_SHAPE == Circle
            float len = length(uvCorrected*scale);
        #endif

        // Sun mask
        if (len < sunraysOriginSize) {
            vec2 samplePos = (uv * scale) + lightPos;
            float blockTransparency = 1;
           
        #if SUNRAYS_MODE == 1
            float depth = isEyeUnderwater ? sampleDepth1(samplePos) : sampleDepth0(samplePos);
            // TODO: adjust the spread and strength and color when underwater here
        #elif SUNRAYS_MODE == 2 || SUNRAYS_MODE == 3
            float depth = sampleDepth1(samplePos);
            blockTransparency = depth - sampleDepth0(samplePos) > 0 ? SUNRAYS_MAX_TRANSPARENCY : 1; 

            #if SUNRAYS_MODE == 3
                // Probably not physically accurate tinting at all
                if (blockTransparency < 1 && blockTransparency > 0) {
                    vec3 tint = textureLod(colortex0, samplePos, 0).rgb; 
                    blockTransparency *= dot(tint, skyColor); // Closer to skyColor = more transparent
                    rayColor = mix(rayColor+tint, rayColor*tint*SUNRAYS_TINT_STRENGTH, (1-blockTransparency) * 1.5 * max(tint.x, max(tint.y, tint.z)));
                    rayColorCount++;
                }
            #endif
        #endif

            float reduceSunIntensity = ((samples - i) * oneOverSamples);// Inverts the influence when its on the sun itself, so sun isnt super bright
            float spreadStrength = (sunraysOriginSize-len-0.05)*2; 

            rayAlpha += blockTransparency * step(1, depth) * reduceSunIntensity * spreadStrength; 
        }
    }
#if SUNRAYS_MODE == 3
    vec3 rayColorFactor = mix(sunraysColor, normalize(rayColor/float(rayColorCount)), SUNRAYS_MAX_TRANSPARENCY);
#else
    vec3 rayColorFactor = sunraysColor;
#endif
    Color.rgb += rayColorFactor*(rayAlpha*oneOverSamples)*lightColor.a*strength*sunraysStrength;
}