This document is **heavily** subject to change, DO NOT expect any of these features.
It is meant to be a self note, but is **not** private.

### To-do:
- SSR
    - The dh-vanilla chunk boundary/blending seem to make the ssr reflect wrongly, perhaps fix that if possible
    - Do sky/ambient reflection in composite instead of deferred, just like ssr -> maybe even do in same pass as ssr

- Buffer Reworking
    - HDR colortex0 [10 11 11 8]
    - Pack Gbuffers into one `RG32UI`(64) buffer
        - `LOWER_PRECISION_GBUFFERS` -> `RGB16UI`(48) buffer for low precision (default)
- Water
    - use hardcoded water colors per biome, dont do auto color
    - use a small scale noise layer the scrolls vertically to add movement to water puddles
    - fix shadows bing broken when enabling water displacement
        - consolidate the displacement code, so that we can reuse it in shadow.vsh
    - Total internal reflection using snells law, and if TIR then use ssr for reflection
    - water refraction
    - caustics
    - shore foam(? maybe not)
- Colored + translucent shadows + hardcoded translucent shadows like leaves
- DH shadows support(1.20.1?)


### To-do Planned:
- Make sky non-physically based as it is inflexible. 
    - Make it artist friendly but still support, top, mid, bottom, sun/moon halo/horizon sky colors -> maybe use preetham's for sunset
- Water blur and underwater blur
-  Disable alpha blending on gbuffers, ISSUECODE: 12xnd

### To-do Later:
- `PUDDLE_EXPOSURE_MIN` should correlate with the unimplemented `WIND_STRENGTH`
- Add a global pixelization override setting which will mean it takes the max pixelation of global and local 
- Fix mip maps
    - Albedo
    - All gbuffers
- Distant Horizons support
    - Add noise for DH like vanilla DH
    - Particles fade out when out of vanilla range due to DH sorting issues
    - Try shading specifically for water, foliage
    - Broken on 1.21.4 iris
        - DH chunks doesnt cast shadows -> verify what MC version supports it by using a verified shader such as super duper vanilla
- In caves, make the skybox black/dark(should not have ANY false positives)
- Use a better shadow distortion algo, as this one makes the far chunks super thin
- (?) Distort PCF's offset, and maybe also PCSS
- Fix or deprecate PCSS as its hard to tune
- Make sunrays origin size consistent across fov levels either by making it use world space size OR use fov to counterscale it
- Improve translucent on dh translucent blending as you can see the sky when blending between vanilla and dh chunks on translucents
- DH support (Cant seem to do this currently, on the initial DH support since it doesnt seem to work on 1.21.4 and couldnt get to run on 1.20.1)
    - Cast Shadows
    - Per Mat Id pbrs
- Sky reflection should be cached/precomputed like 128 directions or something instead of runtime computation
- Integrated pbr
- Reimplement fog color adjustment based on mood and player light level like pre-deferred version
- Moving rain particles -> shear the rain based on weather/wind

### Issues
 - (!) Entity shadows disappear at certain angles, may be iris bug? (1.21.4)
 - Mipmaps fade out too quick, perhaps use `textureGrad`
 - (?) Turning on Shadow Fade Out makes an unknown black fade in the distance appear
 - Boat has water visible in it (RN on MC 1.21.4 Iris 1.8.8)
 - Current fog implementation has an issue as it uses a hack by multiply by 0, resulting in the bottommost part of the fog(if you fly up) being pitched
 - (!) The auto water color detection is flickering `CODE: 12jk3h`
 - DH shadowmap's depth rn doesnt blend according to the vanila-dh chunk blend, should do this eventually but needs to be after supporting dh chunks casting shadows
 - #WontFix SSR cannot trace behind hand and trying to do so is too impractical as it requires a **color buffer without hand and a depth buffer without hand**
 - #ShouldFixEventually Rain-Fog does not fog properly
 - #ShouldMaybeFix SSR has noisy results at grazing reflection angles which exaggerates the effect of normal maps

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

### Scrapped(Acrhive):
 - ~~- Make sky under the horizon same as fog color.~~