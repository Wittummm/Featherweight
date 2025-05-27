/* Crude Nitisha Atmospheric Scattering Sky
Sources:
    [x] https://www.scratchapixel.com/lessons/procedural-generation-virtual-worlds/simulating-sky/simulating-colors-of-the-sky.html
    [x] https://www.shadertoy.com/view/3lVyRc
*/

// Required Uniforms: gbufferModelViewInverse, eyeAltitude

// TODOEVENTUALLY: Actually understand the algorithm, Polish up the code, perhaps a rewrite from scratch

const float Re = 6360e3;
const float Ra = 6420e3;
const float Hr = 7994.0;
const vec3 betaR = vec3(3.8e-6, 13.5e-6, 33.1e-6);
const float Hm = 1200.0;
const vec3 betaM = vec3(21e-6);
const float g = 0.4;

#define MAX 1000000

const int SAMPLES = 6 + int(eyeAltitude*0.0008);
#define SAMPLES_LIGHT 3
#define MIE_EXTINCTION_MUL 1.1

bool raySphereIntersect(vec3 center, vec3 dir, float radius, out float t0, out float t1) {
    float b = dot(dir, center);
    float c = dot(center, center) - (radius * radius);
	float test = b*b - c;
    // Intersection should have two points
    if (test <= 0.0) return false;
	test = sqrt(test);
	t0 = -b - test;
	t1 = -b + test;
	if (t0 > t1) t0 = t1, t1 = t0;
	return true;
}

vec3 computeIncidentLight(in vec3 orig, in vec3 dir, in float tmin, in float tmax, in vec3 sunDirection, int samples) {
    float t0, t1;
    if (!raySphereIntersect(orig, dir, Ra, t0, t1) || t1 < 0.0) return vec3(0.0);
    if (t0 > tmin && t0 > 0.0) tmin = t0;
    if (t1 < tmax) tmax = t1;
    float segmentLength = (tmax*0.25) / float(samples);
    float tCurrent = tmin;
    vec3 sumR = vec3(0.0); // rayleigh contribution
    float opticalDepthR = 0.0;
    float mu = dot(dir, sunDirection); // mu in the paper which is the cosine of the angle between the sun direction and the ray direction
    float phaseR = 3.0 / (16.0 * PI) * (1.0 + mu * mu);
    vec3 sumM = vec3(0.0); // mie contribution
    float opticalDepthM = 0.0;
    float phaseM = 3.0 / (8.0 * PI) * ((1.0 - g * g) * (1.0 + mu * mu)) / ((2.0 + g * g) * pow(1.0 + g * g - 2.0 * g * mu, 1.5));
    for (uint i = 0u; i < samples; ++i) {
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

vec3 ACES(vec3 v) {
    v *= 0.6;
    return (v*(2.51*v+0.03))/(v*(2.43*v+0.59)+0.14);
}

vec3 skyNitisha(vec3 viewDir, vec3 lightDir, float time, float intensity, float max) {
    vec3 pos = vec3(0.0, Re + eyeAltitude, 0.0);
    int samples = SAMPLES;
    
    float t0, t1, tMax = MAX;
    if (raySphereIntersect(pos, viewDir, Re, t0, t1) && t0 > 0.0) {
        tMax = t0;
    }

    if (viewDir.y < 0) { // Handle below horizon(Hacky)
        tMax = MAX;
    }
    vec3 color = computeIncidentLight(pos, viewDir, 0.0, tMax*max, lightDir, samples);
    
    return ACES(color*intensity);
}
