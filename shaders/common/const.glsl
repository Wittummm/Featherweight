uniform float alphaTestRef = 0.1;
const int noiseTextureResolution = 256;
const float wetnessHalflife = 50.0;
const float centerDepthHalflife = 2.0;

#define PI 3.14159265358979323846264338327950288419716939937510
#define ONE_OVER_PI 0.3183098861837907

// Derived
const int noiseTexRes = noiseTextureResolution;
const vec2 noiseTexSize = vec2(noiseTexRes, noiseTexRes);