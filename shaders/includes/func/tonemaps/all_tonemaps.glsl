// CREDIT: SOURCE: https://www.shadertoy.com/view/WdjSW3

#include "/includes/func/tonemaps/lottes.glsl"
#include "/includes/func/tonemaps/reinhard.glsl"
#include "/includes/func/tonemaps/unreal.glsl"
#include "/includes/func/tonemaps/hejl.glsl"
#include "/includes/func/tonemaps/agx.glsl"

bool tonemap(inout vec3 color, int tonemapper) {
    switch (tonemapper) {
        case 1: color = reinhardModified(color); break;
        case 2: color = agx(color); return false; break;
        case 3: color = hejl(color); break;
        case 4: color = unreal(color); return false; break;
        case 5: color = lottes(color); break;
    }
    return true;
}
