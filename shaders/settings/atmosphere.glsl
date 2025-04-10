
#define FOG_DETAIL PerVertex // [PerVertex PerPixel]
vec3 ATMOSPHERE_COLOR = vec3(176, 204, 255)*0.00392156862745098;

#define FOG_DENSITY 1 // [0.75 1 1.25 1.5 1.75 2 2.25 2.5 3]
#define FOG_START 0.2 // [0 0.05 0.1 0.15 0.2 0.25 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1]
#define FOG_END 0.95 // [0 0.1 0.2 0.3 0.4 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1]