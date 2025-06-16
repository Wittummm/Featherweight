// Required Uniforms: viewWidth, viewHeight
/*
Sources:
 [1] https://www.shadertoy.com/view/WtBXWw
*/

#include "/includes/shared/math_const.glsl"
#if STARS != 0 &&  || STAR_AMOUNT != 0
#include "/includes/func/atmosphere/calcStars.glsl"
#endif

vec3 sunDir = mat3(ap.camera.viewInv) * normalize(ap.celestial.sunPos);

#ifdef CUSTOM_SKY
#include "/lib/metadata.glsl"
    vec3 moonDir = mat3(ap.camera.viewInv) * normalize(stellarViewMoonDir*0.5 + _stellarViewMoonDirMax*0.5);
#else
    vec3 moonDir = mat3(ap.camera.viewInv) * normalize(ap.celestial.moonPos);
#endif

#define rayleigh 1.
#define rayleighAtt 0.7
#define mie 1.
#define mieAtt 0.8
const float g = -0.93; // inverted anistropy closer to 1, closer to forward scattering [-1, 1]
const float g2 = g*g;

const vec3 betaR = vec3(1.95e-2, 1.1e-1, 2.94e-1);
const vec3 betaM = vec3(4.2e-2, 4e-2, 4e-2);

vec3 ACES(vec3 v) {
    v *= 0.6;
    return (v*(2.51*v+0.03))/(v*(2.43*v+0.59)+0.14);
}

float brightness(vec3 color) {
    return 0.299*color.r + 0.587*color.g + 0.114*color.b;
}

// DUPLICATE CODE: sadnin1
vec3 rotateAroundZ(vec3 v, float angle) {
    float s = sin(angle);
    float c = cos(angle);
    return vec3(
        c * v.x - s * v.y,
        s * v.x + c * v.y,
        v.z
    );
}
// DUPLICATE CODE: sadnin1
vec3 rotateAroundX(vec3 v, float angle) {
    float s = sin(angle);
    float c = cos(angle);
    return vec3(
        v.x,
        c * v.y - s * v.z,
        s * v.y + c * v.z
    );
}

//////////////////////////
vec3 skyCustom(vec3 viewDir, vec3 lightDir, vec2 intensity, vec2 attenuation) {
    ////// Sun Haze [1] //////

    float t = viewDir.y < 0 ? -viewDir.y/max(eyeAltitude, 10) : viewDir.y;

    float sR = rayleighAtt*attenuation.x / t ;
    float sM = mieAtt*attenuation.y / t ;

    float cosine = max(dot(viewDir, lightDir), 0);
    vec3 extinction = exp(-(betaR * sR + betaM * sM));

    const float g2 = g * g;
    float fcos2 = cosine * cosine;
    float miePhase = mie*intensity.y * pow(1. + g2 + 2. * g * cosine, -1.5) * (1. - g2) / (2. + g2);
    vec3 inScatter = (1 + fcos2) * vec3(rayleigh*intensity.x + betaM / betaR * miePhase*(1-extinction));

    vec3 sunHaze = ACES(inScatter*(1-extinction));

    ///////////////////

    return vec3( clamp(sunHaze, 0, 1) );
}

vec3 _skyCustomNoStars(inout vec3 viewDir, vec2 intensity, vec2 attenuation) {
    float sunness = max(sunDir.y, 0); 
    float moonness = max(moonDir.y, 0);

    float altitudeBias = eyeAltitude*0.0001; // Fake Space
    viewDir.y += altitudeBias;
    viewDir = normalize(viewDir);
    if (altitudeBias > 1) { 
        return vec3(0); // We in SPACE!
    }

    float _moonIntensity = mix(0, 0.01, moonness);
    #ifdef DISABLE_MOON_HALO
        vec2 moonIntensity = vec2(_moonIntensity, 0);
    #else
        vec2 moonIntensity = vec2(_moonIntensity);
    #endif

    vec2 sunIntensity = vec2(mix(0.05, 1, sunness));
    #ifdef CUSTOM_SKY // CODE: 12iosa
        moonIntensity.x = 0;
        sunIntensity.x = 0;
    #endif

    return 
    skyCustom(viewDir, sunDir, sunIntensity*intensity, vec2(1)*attenuation )*min(sunness+0.5, 1) + 
    skyCustom(viewDir, moonDir, moonIntensity*intensity, vec2(mix(4, 10, moonness))*attenuation )*min(moonness+0.5, 1);
}

vec3 skyCustomNoStars(in vec3 viewDir, vec2 intensity, vec2 attenuation) {
    return _skyCustomNoStars(viewDir, intensity, attenuation);
}

vec3 skyCustomNoStars(in vec3 viewDir) {
    return skyCustomNoStars(viewDir, vec2(1), vec2(1));
}

vec3 skyCustom(vec3 viewDir, vec2 intensity, vec2 attenuation) {
    vec3 sky = _skyCustomNoStars(viewDir, intensity, attenuation);

    #if STARS == 0 || STAR_AMOUNT == 0
        return sky;
    #else
        //NOTE: This is supposed to anchor the stars to the moon, not sure if this is actually correct but it looks believable
        vec3 rotatedViewDir = rotateAroundX(rotateAroundZ(viewDir, -atan(moonDir.y, moonDir.x)), atan(moonDir.y, moonDir.z));
        vec3 stars = viewDir.y >= 0 ? calcStars(rotatedViewDir) : vec3(0); // No stars under the horizon
        return sky + stars*max(1-brightness(sky)*STAR_EXPOSURE_THING, 0);
    #endif
}

vec3 skyCustom(vec3 viewDir) {
    return skyCustom(viewDir, vec2(1), vec2(1));
}