This document is **heavily** subject to change, DO NOT expect any of these features.
It is meant to be a self note, but is **not** private.

### To-do:
- Actually Fix dh blending now

- SSR
    - Do sky/ambient reflection in composite instead of deferred, just like ssr -> maybe even do in same pass as ssr
- Water
    - Make water also scatter skylight(attenuates based on if sun is directly above)
    - (Might defer to do later) Make shadows on water be softer than on solids(when pcf/pcss/non-hard shadows enabled)
- Fix/Check if Fog works properly with translucents(rain, glass, etc) as it does not have depth
    - perhaps render fog in `shade()`(math_lighting.glsl) so it renders forward and deferred instead of in composite
- change the release zip name `Featherweight` to `§6§lFeatherweight§r§r` (gold)

- Buffer Reworking
    - HDR colortex0 [10 11 11 8]
    - Pack Gbuffers into one `RG32UI`(64) buffer
        - `LOWER_PRECISION_GBUFFERS` -> `RGB16UI`(48) buffer for low precision (default)
- Water
    - fix `CODE: 12jk3h` by either hardcoding waterColor or temporally smooth color with 1 color sample per frame
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
- Fix mip maps
    - Albedo
    - All gbuffers
- Distant Horizons support
    - Add noise for DH like vanilla DH
    - (Is this still an issue with the new blending rework?) Particles fade out when out of vanilla range due to DH sorting issues
    - Try shading specifically for water, foliage(hardcoded pbr/shading using dh block id)
    - Broken on 1.21.4 iris
        - DH chunks doesnt cast shadows -> verify what MC version supports it by using a verified shader such as super duper vanilla
- In caves, make the skybox black/dark(should not have ANY false positives)
  - Reimplement fog color adjustment based on mood and player light level like pre-deferred version
- Use a better shadow distortion algo, as this one makes the far chunks super thin
- Fix or deprecate PCSS as its hard to tune
- Make sunrays origin size consistent across fov levels either by making it use world space size OR use fov to counterscale it
- Integrated pbr
- Rain (Re)work
  - Moving rain particles -> shear the rain based on weather/wind
  - Make rain clear instead of vibrant blue

### Issues/Limitations
 - (!) Entity shadows disappear at certain angles, may be iris bug? (1.21.4)
 - Mipmaps fade out too quick, perhaps use `textureGrad`
 - (?) Turning on Shadow Fade Out makes an unknown black fade in the distance appear
 - Boat has water visible in it (RN on MC 1.21.4 Iris 1.8.8)
 - (!) The auto water color detection is flickering `CODE: 12jk3h`
 - Shadows when dh blending is on is wrong, because it doesnt blend in shadow pass.
   - Need to add support for dh shadows before this can be fixed
 - #WontFix SSR cannot trace behind hand and trying to do so is too impractical as it requires a **color buffer without hand and a depth buffer without hand**
 - #ShouldFixEventually Translucents with no Opaque behind it does not fog properly `CODE: woxjw`

### Ideas:
- (?) Exponential shadow mapping(medium)
- Entity Light Emission(low priorty)
    - Store `Position` and `Brightness` in an SSBO list
    - 2 Modes: Per-vertex, Per-Vertex Shadowed(Injects into LPV)
    - Can also render the player's light separately for free, without needing this feature on
- Foliage Deformation
    - Basically free around local player
    - For entities, need to store some data probably `center`, `size` -> can reuse data from entity light emission
- Light Shafts 
    - ~~Radial blur~~
    - Volumetric Based, check with shadowmap depth
- Bloom
- Waving Plants
- HBAO?
- (?) Requires Voxelization
    - Fallback Voxel Reflection [https://youtu.be/QtSFUg-h3vw?si=CA6-8T0Mi3lCvJm4]
- Custom LUTs and Tonemapping

### Ideas Later:
- Wavings blocks like hanging laterns, banners
- Shadows should be softer/fainter on foliage
- Maybe add fake sun angle by shearing shadows
- A shortcut menu for all performance options separated into Low, Medium, High and Unknown
