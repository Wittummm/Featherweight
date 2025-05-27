// Required Uniforms: viewWidth, viewHeight
/*
Sources:
 [1] https://www.shadertoy.com/view/WtBXWw

Temp:
Make it artist friendly but still support, top, mid, bottom, sun/moon halo/horizon sky colors 
-> maybe use preetham's for sunset

TODONOW: 
- make it so you can actually go into space(if possible)
- finalize calcStars's config
- revise fog and how it uses the atmosphere function
*/

#include "/common/const.glsl"
#include "/func/atmosphere/calcStars.glsl"

#define STAR_EXPOSURE_THING 40 // NAME IS INACCURRATE, Higher = less bright it needs to be for star to disappear

uniform vec3 sunPosition; 
uniform vec3 moonPosition; 

vec3 sunDir = mat3(gbufferModelViewInverse) * normalize(sunPosition);
vec3 moonDir = mat3(gbufferModelViewInverse) * normalize(moonPosition);

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

//////////////////////////
vec3 skyCustom(vec3 viewDir, vec3 lightDir, float intensity, float attenuation) {
    ////// Sun Haze [1] //////

    float t = viewDir.y < 0 ? -viewDir.y*0.1 : viewDir.y; 

    float sR = rayleighAtt*attenuation / t ;
    float sM = mieAtt*attenuation / t ;

    float cosine = max(dot(viewDir, lightDir), 0);
    vec3 extinction = exp(-(betaR * sR + betaM * sM));

    const float g2 = g * g;
    float fcos2 = cosine * cosine;
    float miePhase = mie*intensity * pow(1. + g2 + 2. * g * cosine, -1.5) * (1. - g2) / (2. + g2);
    vec3 inScatter = (1 + fcos2) * vec3(rayleigh*intensity + betaM / betaR * miePhase*(1-extinction));

    vec3 sunHaze = ACES(inScatter*(1-extinction));

    ///////////////////

    return vec3( clamp(sunHaze, 0, 1) );
}

vec3 skyCustom(vec3 viewDir) {
    float sunness = max(sunDir.y, 0); 
    float moonness = max(moonDir.y, 0);

    vec3 skyColor = sunDir.y >= 0 ?
    /*sun*/ skyCustom(viewDir, sunDir, mix(0, 1, sunness), 1) :
    /*moon*/skyCustom(viewDir, moonDir, max(mix(-0.0013, 0.01, moonness), 0.0002), mix(4, 10, moonness));
    
    vec3 starColor = calcStars(viewDir);

    return skyColor + starColor*max(1-brightness(skyColor)*STAR_EXPOSURE_THING, 0);
}
