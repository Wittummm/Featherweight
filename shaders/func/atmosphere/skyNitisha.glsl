/* Nitisha Atmospheric Scattering Sky
Sources:
    [x] https://www.scratchapixel.com/lessons/procedural-generation-virtual-worlds/simulating-sky/simulating-colors-of-the-sky.html
    [x] https://www.shadertoy.com/view/3lVyRc
*/

// Required Uniforms: gbufferModelViewInverse, upPosition

// TODOEVENTUALLY: Actually understand the algorithm, Polish up the code, perhaps a rewrite from scratch

const float Re = 6360e3;
const float Ra = 6420e3;
const float Hr = 7994.0;
const vec3 betaR = vec3(3.8e-6, 13.5e-6, 33.1e-6);
const float Hm = 1200.0;
const vec3 betaM = vec3(21e-6);
const float g = 0.8;

#define MAX 1000000

#define SAMPLES 2
#define SAMPLES_LIGHT 2
#define ALTITUDE 0.0
#define MIE_EXTINCTION_MUL 1.2

const vec3 pos = vec3(0.0, Re + ALTITUDE, 0.0);

bool raySphereIntersect(const vec3 center, const vec3 dir, const float radius, out float t0, out float t1) {
    const float b = dot(dir, center);
    const float c = dot(center, center) - (radius * radius);
	float test = b*b - c;
    // Intersection should have two points
    if (test <= 0.0) return false;
	test = sqrt(test);
	t0 = -b - test;
	t1 = -b + test;
	if (t0 > t1) t0 = t1, t1 = t0;
	return true;
}

vec3 computeIncidentLight(const in vec3 orig, const in vec3 dir, in float tmin, in float tmax, const in vec3 sunDirection) {
    float t0, t1;
    if (!raySphereIntersect(orig, dir, Ra, t0, t1) || t1 < 0.0) return vec3(0.0);
    if (t0 > tmin && t0 > 0.0) tmin = t0;
    if (t1 < tmax) tmax = t1;
    float segmentLength = (tmax*0.25) / float(SAMPLES);
    float tCurrent = tmin;
    vec3 sumR = vec3(0.0); // rayleigh contribution
    float opticalDepthR = 0.0;
    float mu = dot(dir, sunDirection); // mu in the paper which is the cosine of the angle between the sun direction and the ray direction
    float phaseR = 3.0 / (16.0 * PI) * (1.0 + mu * mu);
    vec3 sumM = vec3(0.0); // mie contribution
    float opticalDepthM = 0.0;
    float phaseM = 3.0 / (8.0 * PI) * ((1.0 - g * g) * (1.0 + mu * mu)) / ((2.0 + g * g) * pow(1.0 + g * g - 2.0 * g * mu, 1.5));
    for (uint i = 0u; i < SAMPLES; ++i) {
        vec3 samplePosition = orig + (tCurrent + segmentLength * 0.5) * dir;
        float height = length(samplePosition) - Re;
        // compute optical depth for light
        float hr = exp(-height / Hr) * segmentLength;
        opticalDepthR += hr;
        float hm = exp(-height / Hm) * segmentLength;
        opticalDepthM += hm;
        // light optical depth
        float t0Light, t1Light;
        raySphereIntersect(samplePosition, sunDirection, Ra, t0Light, t1Light);
        float segmentLengthLight = t1Light / float(SAMPLES_LIGHT), tCurrentLight = 0.0;
        float opticalDepthLightR = 0.0;
        float opticalDepthLightM = 0.0;
        uint j;
        for (j = 0u; j < SAMPLES_LIGHT; ++j) {
            vec3 samplePositionLight = samplePosition + (tCurrentLight + segmentLengthLight * 0.5) * sunDirection;
            float heightLight = length(samplePositionLight) - Re;
            if (heightLight < 0.0) break;
            opticalDepthLightR += exp(-heightLight / Hr) * segmentLengthLight;
            opticalDepthLightM += exp(-heightLight / Hm) * segmentLengthLight;
            tCurrentLight += segmentLengthLight;
        }
        if (j == SAMPLES_LIGHT) {
            vec3 tau = betaR * (opticalDepthR + opticalDepthLightR) + betaM * MIE_EXTINCTION_MUL * (opticalDepthM + opticalDepthLightM);
            vec3 attenuation = vec3(exp(-tau.x), exp(-tau.y), exp(-tau.z));
            sumR += attenuation * hr;
            sumM += attenuation * hm;
        }
        tCurrent += segmentLength;
    }

    return (sumR * betaR * phaseR + sumM * betaM * phaseM) ;
}

vec3 calcSky(vec3 viewDir, vec3 lightDir, float time) {
    viewDir = (mat3(gbufferModelViewInverse) * viewDir); // To Player Space
    lightDir = (mat3(gbufferModelViewInverse) * lightDir); // To Player Space

    float t0, t1, tMax = MAX;
    if (raySphereIntersect(pos, viewDir, Re, t0, t1) && t0 > 0.0) {
        tMax = t0;
    }
    float strength = 15;

    if (viewDir.y < 0) {
        viewDir.y *= 0.7;
        tMax = MAX;
    }
    if (time < 1 && time > 0.5) {
        tMax = MAX*0.01;
        strength = 5;
    }
    
    return computeIncidentLight(pos, viewDir, 0.0, tMax, lightDir)*strength;
}
