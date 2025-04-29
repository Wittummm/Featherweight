Version: v0.3.1.2.Prototype

### Version Phases
Major.Minor.Patch.Build, pre version 1 versions are highly volatile.
 - Prototype - Unstable, features are easily phased in and out
 - Alpha - Core mechanics

### Branches
 - `main` stable releases
 - `dev` unstable releases
 - `v0.0.0.0_feature-some-feature` for working on features
 - `v0.0.0.0_patch-some-patch` for working on patches (Uncommon unless issue is hard to patch)

### Notes, Caution
 - Iris v1.7.6 is incompatible. v1.7.6 parses `vaUV2` weirdly/differently.
    - v1.7.6 patching of `vaUV2` in **Sodium** shader stages errors. The patching itself causes the crash, not the value it patches to. This issue is presumably a bug in Iris 1.7.6

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

