/*
Sources:
 [1] https://www.shadertoy.com/view/WtBXWw
*/

#include "/includes/shared/math_const.glsl"
#include "/includes/shared/settings.glsl"
#include "/includes/func/atmosphere/calcStars.glsl"

vec3 moonDir = mat3(ap.camera.viewInv) * normalize(ap.celestial.moonPos);
vec3 sunDir = mat3(ap.camera.viewInv) * normalize(ap.celestial.sunPos);
float altitude = ap.camera.pos.y;

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

#define brightness(color) (0.299*color.r + 0.587*color.g + 0.114*color.b)

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
vec3 _skyCustom(vec3 viewDir, vec3 lightDir, vec2 intensity, vec2 attenuation) {
    ////// Sun Haze [1] //////

    float t = viewDir.y < 0 ? -viewDir.y/max(altitude, 10) : viewDir.y;

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
    if (Sky == 0) {return vec3(0);}

    float sunness = max(sunDir.y, 0); 
    float moonness = max(moonDir.y, 0);

    float altitudeBias = altitude*0.0001; // Fake Space
    viewDir.y += altitudeBias;
    viewDir = normalize(viewDir);
    if (altitudeBias > 1) { 
        return vec3(0); // We in SPACE!
    }

    float _moonIntensity = mix(0, 0.01, moonness);
    vec2 moonIntensity = DisableMoonHalo ? vec2(_moonIntensity, 0) : vec2(_moonIntensity);
    vec2 sunIntensity = vec2(mix(0.05, 1, sunness));
    if (IsolateCelestials) { 
        moonIntensity.x = 0;
        sunIntensity.x = 0;
    }

    return 
    _skyCustom(viewDir, sunDir, sunIntensity*intensity, vec2(1)*attenuation )*min(sunness+0.5, 1) + 
    _skyCustom(viewDir, moonDir, moonIntensity*intensity, vec2(mix(4, 10, moonness))*attenuation )*min(moonness+0.5, 1);
}

vec3 skyCustomNoStars(in vec3 viewDir, vec2 intensity, vec2 attenuation) {
    return _skyCustomNoStars(viewDir, intensity, attenuation);
}

vec3 skyCustomNoStars(in vec3 viewDir) {
    return skyCustomNoStars(viewDir, vec2(1), vec2(1));
}

vec3 skyCustom(vec3 viewDir, vec2 intensity, vec2 attenuation) {
    vec3 sky = _skyCustomNoStars(viewDir, intensity, attenuation);

    if (Stars == 0 || StarAmount == 0) {
        return sky;
    } else {
        //NOTE: This is supposed to anchor the stars to the moon, not sure if this is actually correct but it looks believable
        vec3 rotatedViewDir = rotateAroundX(rotateAroundZ(viewDir, -atan(moonDir.y, moonDir.x)), atan(moonDir.y, moonDir.z));
        
        vec3 stars; 
        // No stars under the horizon
        if (Stars == 1) {
            stars = viewDir.y >= 0 ? calcStarsLow(rotatedViewDir) : vec3(0);
        } else if (Stars == 2) {
            stars = viewDir.y >= 0 ? calcStarsMedium(rotatedViewDir) : vec3(0);
        }
        return sky + stars*max(1-brightness(sky)*STAR_EXPOSURE_THING, 0);
    }
}

vec3 skyCustom(vec3 viewDir) {
    return skyCustom(viewDir, vec2(1), vec2(1));
}