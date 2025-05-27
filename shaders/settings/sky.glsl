#include "/common/shader.glsl"

#ifndef SKY

#define STARS 2 // {def: 2} [0 1 2] {VanillaGeometry Low Medium} 
#define SKY 1 // {def: 1} [0 1] {Vanilla ShaderSky}

#define STAR_AMOUNT 50 // [0 10 20 30 40 50 60 70 80 90 100]
#define STAR_SHAPE 1 // [0 1] {Textured Circle}
//

const float starAmount = STAR_AMOUNT*0.001;
/// Hardcoded ///
#define STAR_EXPOSURE_THING 40 // NAME IS INACCURRATE, Higher = less bright it needs to be for star to disappear
#define STAR_INTENSITY_MAX 1
#define STAR_INTENSITY_MIN 0.08
const vec3 starColor = vec3(0.9412, 0.9333, 0.898);
const uint cellSize = 10; 
const float starRadius = 1;
const float padding = 0.5;

#endif