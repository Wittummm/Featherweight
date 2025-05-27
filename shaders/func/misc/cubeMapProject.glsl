// Returns [-1, 1]
vec2 cubeMapProject(vec3 dir, out int face) {
    vec3 absDir = abs(dir);

    if (absDir.x >= absDir.y && absDir.x >= absDir.z) {
        // Major axis is X
        if (dir.x > 0.0) {
            face = 0; // +X
            return vec2(-dir.z, dir.y);
        } else {
            face = 1; // -X
            return vec2(dir.z, dir.y);
        }
    } else if (absDir.y >= absDir.x && absDir.y >= absDir.z) {
        // Major axis is Y
        if (dir.y > 0.0) {
            face = 2; // +Y
            return vec2(dir.x, -dir.z); // something wrong here
        } else {
            face = 3; // -Y
            return vec2(dir.x, dir.z);
        }
    } else {
        // Major axis is Z
        if (dir.z > 0.0) {
            face = 4; // +Z
            return vec2(dir.x, dir.y);
        } else {
            face = 5; // -Z
            return vec2(-dir.x, dir.y);
        }
    }
}