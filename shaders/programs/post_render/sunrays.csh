#version 460 core
layout (local_size_x = 32, local_size_y = 8) in;

#include "/includes/shared/shared.glsl"
// Resources: "https://www.shadertoy.com/view/XsfSDs", "https://developer.nvidia.com/gpugems/gpugems3/part-ii-light-and-shadows/chapter-13-volumetric-light-scattering-post-process"
/* RGR - Radial God Rays
 - Adds screen-space basic sun shafts
 - Bloom-like effect on the body as a side effect

Bugs/Limitations:
    - The shaft can go through objects and looks quite bad, idk how to fix this, this is mitigated by `SunraysSpread`
    - `PassTint` may display Color incorrectly when objects behind the glass is strongly colored too
*/
//

// CONFIGTODONOW: add config for this

vec3 sunraysColor = LightColor.rgb * (ap.camera.fluid == 1 ? vec3(0.2,0.45,0.85) : vec3(1));

//
float oneOverSamples = 1.0/SunraysSamples;
float precompute = SunraysSpread * (1.0 / (SunraysSamples - 1.0));
//
uniform sampler2D solidDepthTex;

layout(SCENE_FORMAT) uniform image2D sceneImg;

vec2 applyAspectRatio = vec2(ap.game.screenSize.x/ap.game.screenSize.y, 1);

float sampleDepth1(vec2 samplePos) {
    vec4 depths = textureGather(solidDepthTex, samplePos);
    float depth = min(depths.x, min(depths.y, min(depths.z, depths.w))); // Soft, less streaky, less flickerly than naive sampling, multi-tap would be nicer but probably overkill

    return depth;
}

void main() {
    ivec2 pixelPos = ivec2(gl_GlobalInvocationID.xy);
    if (any(greaterThanEqual(pixelPos, ivec2(ap.game.screenSize)))) return;
    vec2 fragCoord = vec2(pixelPos) / ap.game.screenSize;

    vec3 lightDir = normalize(ap.celestial.pos);
    float strength = -lightDir.z*1.4;
    if (strength <= 0) {return;}

    float adjustedFakeSampleMult = SunraysFakeSamples > 0 ? SunraysFakeSamples + ceil((1+lightDir.z)*4)*0.5 : SunraysFakeSamples;

    vec4 lightClip = ap.camera.projection * vec4(ap.celestial.pos, 1);
    vec2 lightPos = ((lightClip.xyz/lightClip.w + 1.0)*0.5).xy;

    vec2 uv = fragCoord - lightPos;
    vec2 uvCorrected = uv*applyAspectRatio;
    float offset = adjustedFakeSampleMult > 1 ? length(fract(pixelPos/adjustedFakeSampleMult)*precompute) : 0;
    
    float blurStart = ((1-SunraysSpread) - offset) ;
    float blurStartOffseted = blurStart - offset;

    float rayAlpha = 0;
    for(float i = 0; i < SunraysSamples; i++) {
        float scale = blurStartOffseted + (i * precompute);
        float len = length(uvCorrected*scale);

        // Sun mask
        if (len < SunraysOriginSize) {
            vec2 samplePos = (uv * scale) + lightPos;
           
            float depth = sampleDepth1(samplePos);

            float reduceSunIntensity = ((SunraysSamples - i) * oneOverSamples);// Inverts the influence when its on the sun itself, so sun isnt super bright
            float spreadStrength = (SunraysOriginSize-len); 

            rayAlpha += step(1, depth) * reduceSunIntensity * spreadStrength; 
        }
    }

    vec4 Color = imageLoad(sceneImg, pixelPos);
    Color.rgb += sunraysColor*(rayAlpha*oneOverSamples)*strength*SunraysStrength;

    imageStore(sceneImg, pixelPos, Color);
}