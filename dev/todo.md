This document is **heavily** subject to change, DO NOT expect any of these features.
It is meant to be a self note, but is **not** private.

### To-do:
- Deferred rendering
    - reimplement DH support
        - in `deferred.fsh` also make it use `dhDepth` so it shades dh chunks too
        - readd fog
    - make `light_level.glsl` into a `packLightLevel.glsl` `func`
    - ability to turn off: diffuse, specular, clearcoat(rain)
    - Integrated pbr
- Sky
    - sky + metals support sky reflections
- Water
    - vert displacement
    - shore foam
    - absorption?
    - fresnel
    - SSR
- fog color changes according to time

### To-do Later:
- `PUDDLE_EXPOSURE_MIN` should correlate with the unimplemented `WIND_STRENGTH`
- Add a global pixelization override setting which will mean it takes the max pixelation of global and local 
- Fix mip maps
    - Albedo
    - All gbuffers
- Pack gbuffers into `rgba16` instead of 2 `rgba8`s
- Distant Horizons support
    - Add noise for DH like vanilla DH
    - Particles fade out when out of vanilla range due to DH sorting issues
    - Try shading specifically for water, foliage
    - Broken on 1.21.4 iris
        - DH chunks doesnt cast shadows
- In caves, make the skybox black/dark(should not have ANY false positives)
- Use a better shadow distortion algo, as this one makes the far chunks super thin
- (?) Distort PCF's offset, and maybe also PCSS
- Fix or deprecate PCSS as its hard to tune
- Make sunrays origin size consistent across fov levels either by making it use world space size OR use fov to counterscale it

### Issues
 - (!) Entity shadows disappear at certain angles, may be iris bug? (1.21.4)
 - Mipmaps fade out too quick, perhaps use `textureGrad`
 - (?) Turning on Shadow Fade Out makes an unknown black fade in the distance appear

### Ideas:
- Exponential shadow mapping(medium)
- Temporal Shadows(medium priority). Store the history of shadow in a buffer
- Fake Soft Clouds(medium priority)
    - Generate and render backfaces first, then get the depth difference of front and back
    - Using geometry shader to generate the backfaces first will naturally render all the backfaces first
    - Optimization 1: Use lower resolution buffer (half to quarter) with 16 bit precision depth
    - Optimization 2: Distort the buffer so it utilizes the most space as clouds are usually only partially on screen
- Super Duper Vanilla-like clouds with faded edges using a texture + shell textured
- Entity Light Emission(low priorty)
    - Store `Position` and `Brightness` in an SSBO list
    - 3 Modes: Per-vertex, Per-Pixel, Per-vertex Shadowed, Per-Pixel Shadowed
    - Shadow using screen space shadow(utilizing depth map, and maybe even shadowmap)
    - Directional shading
    - Helper func `shadePointLight(pos, brightness, range)`
    - Can also render the player's light separately
- Godrays 
    - ~~Radial blur~~
    - Volumetric Based, check with shadowmap depth
    - Hybrid, uses the Radial Blur godrays as support since the shadowmap can be quite low res
- Bloom
- Waving Plants
- Water with absorption, etc
    - Underwater blur
- HBAO
- Fast Screen Space Reflections
- Fog
- Simple PBR
- (?) Requires Voxelization
    - Directional Lighting [THEORY]
        - Capture/Voxelize light value, if is air then generate a vertex to capture it.
    - Foliage Deformation
        - Basically free around local player
        - For entities, need to store some data probably `center`, `size`
    - Fallback Voxel Reflection [https://youtu.be/QtSFUg-h3vw?si=CA6-8T0Mi3lCvJm4]
- Custom LUTs and Tonemapping

### Ideas Later:
- Wavings blocks like hanging laterns, banners
- Shadows should be softer/fainter on foliage
- Maybe add fake sun angle by shearing shadows
- A shortcut menu for all performance options separated into Low, Medium, High and Unknown