<!---
The shader developer should make use of Issues(bugs), Discussions(ideas), and Pull Requests(changes) especially when it is significant to do so and when not in a dev version.
-->

Version: v0.x.x.x.Dev (Refer to changelog as pre v1 is volatile)

### Version Phases
Major.Minor.Revision.Patch.Tag, pre v1 versions are highly volatile.
 - Dev - Unstable
 - Alpha - Core mechanics
 - Beta

### Branches
 - `main` stable releases
 - `dev` unstable releases
 - `v0.0.0.0_feature-some-feature` for working on features
 - `v0.0.0.0_patch-some-patch` for working on patches (Uncommon unless issue is hard to patch)

### Notes, Caution

### Change Logs Summary
- v0.1.0.0 Initial Features, deferred rendering, shadows, sunrays
- v0.2.0.0 (Lab) PBR Support
- v0.3.0.0 Shadows reimplementation
- v0.4.0.0 Initial Distant Horizons Support
- v0.5.0.0 Initial Crude Nitisha Atmosphere -> Fog, Sky, Sky/Ambient Reflections
- v0.6.0.0 to v0.6.5.0 Initial Water
- v0.6.6.0 Extra Distant Horizons Support -> Handles translucency, supports non-dithered blending
- v0.7.0.0 Initial Screen Space Reflections
- v0.7.3.0 SSR: Full-res resolve, crude blurring
- v0.7.4.0 SSR: Edge retaining linear filtering for deferred resolve, Allow control of normal strength by reconstructing normals
- v0.7.4.1 SSR
  - Normal softening at grazing angles
  - Fixed translucents not reflection due to alt/main frame buffers
- v0.7.5.0 SSR
  - Improved the filtering on valid-invalid ssr pixels
  - Mitigated streaks. Cause: ssr depth imprecision. Solution: bias it by a bit
  - Changed to trace in screen space instead of view space for better efficiency
- v0.7.6.0 SSR
  - SSR Dh support
- v0.7.6.1 Patched new dh bugs
  - Fixed dh causing ghosting; caused by sampling dhdepthtex1 instead of 0
  - Fixed dh water getting "clipped" arbitrary; code was legacy and supposedly wrong
  - Fixed dh water(translucents) getting masked by invisible vanilla fragemnts; fixed by dithering *some* vanilla chunks, specificially one where we think the dh-vanilla block is not the same block ie foliage doesnt exist in DH chunks
  - Ongoing Patch: Properly dithering dh-vanilla chunks -> need to dither out dh chunks too :/
- v0.7.6.2.dev Misc Patches & Changes
  - `block_entities` now have `CUTOUT` flag
  - Specfically only `CUTOUT` in `shadow_cutout` program if Iris v1.8+
  - (Untested) Remove `DH_FADE_BLENDING.Blend` option when images are not supported(glsl 420)
- v0.8.0.0 New Custom Sky! Supports Stellar view.
  - Sky
  - Stars(appears based on sky brightness!)
  - Changed `getFogFactor` to use a biased Beer's Law
- v0.9.0.0 Porting to Aperture!
  - Realtime settings, yay! 🎉
  - **Removals**
    - Removed Distant Horizons support :(, Aperture currently doesn't support it. However, if DH is added in the future, I'll likely support it.
    - Removed Stellar view support, couldnt bother to port + its not on 1.21.6 yet. Support might come back?
    - Removed PCSS. It was a hassle to use, possibly coming back if I am able to do it goodly.
  - **Additions**
    - Changed shadow distortion to use `https://www.desmos.com/calculator/nvofvyom4h`
    - Improved and rewrote zBias biasing "ShadowBias"
      - CSM zbiasing is still borked though -> waiting for csm to get finalized/refined Aperture side
  - **Commit Notes**
    - Fixed "Shadow likes clip out, maybe its near plane?"
- v0.9.1.0 Still porting to AP
  - Shadows are working
  - Added HDR, auto exposure, tonemapping
    - Auto exposure isnt the best, probably should be improved in the future