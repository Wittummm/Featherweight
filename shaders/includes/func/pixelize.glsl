#include "/includes/shared/settings.glsl"

// General Pixelize function. Each feature can have their own Override
#define pixelize(pos, size) ((size == 0) ? (pos) : floor((pos)*size + 0.003)/size)