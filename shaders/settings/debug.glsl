// ## Debug Flags, TURN_ON_DEBUG_MODE_HERE
/* INSTRUCTIONS
Comment ALL below out to completely disable and stop debug from loading
Uncomment ALL below to enable debug loading

Uncommenting it reduces load/compile time
*/ 
/* Dev Notes
Debug settings start with "_"
*/

#define DEBUG 1 // [0 1] 
#define _SHOW_DEBUG_STATS 0 // [0 1]

#define Off -100

#define Fullscreen 0
#define TopLeft 1
#define TopRight 2
#define BottomLeft 3
#define BottomRight 4

#define _SHADOW_FADE_OUT 0 // [0 0.1 0.2 0.3 0.8 1]
#define _ISOLATE_DIFFUSE 0 // [0 1 2 3 4] {off diffuse shade light shade&light}
#define _ISOLATE_VERT_COLOR 0 // [0 1]
#define _ISOLATE_SKYLIGHT 0 // [0 1]

#define _SHOW_SHADOWMAP Off // [Off Fullscreen TopLeft TopRight BottomLeft BottomRight]
#define _SHOW_DH_DEPTH Off // [Off Fullscreen TopLeft TopRight BottomLeft BottomRight]
#define _SHOW_DEPTHMAP Off // [Off Fullscreen TopLeft TopRight BottomLeft BottomRight]
#define _SHOW_POSITION Off // [Off Fullscreen TopLeft TopRight BottomLeft BottomRight]

#define _SHOW_ROUGHNESS Off // [Off Fullscreen TopLeft TopRight BottomLeft BottomRight]
#define _SHOW_REFLECTANCE Off // [Off Fullscreen TopLeft TopRight BottomLeft BottomRight]
#define _SHOW_POROSITY_SSS Off // [Off Fullscreen TopLeft TopRight BottomLeft BottomRight]
#define _SHOW_EMISSION Off // [Off Fullscreen TopLeft TopRight BottomLeft BottomRight]
#define _SHOW_NORMALS Off // [Off Fullscreen TopLeft TopRight BottomLeft BottomRight]
#define _SHOW_AO Off // [Off Fullscreen TopLeft TopRight BottomLeft BottomRight]
#define _SHOW_HEIGHT Off // [Off Fullscreen TopLeft TopRight BottomLeft BottomRight]

// SSR
#define _SHOW_SSR Off // [Off Fullscreen TopLeft TopRight BottomLeft BottomRight]
#define _SHOW_SSR_MODE 0 // [0 1 2] {Color Coord Distanace}
#define _SHOW_SSR_FILTERING -1 // [-1 0 1] {Auto Nearest Linear}