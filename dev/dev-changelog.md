<!---
The shader developer should make use of Issues(bugs), Discussions(ideas), and Pull Requests(changes) especially when it is significant to do so and when not in a dev version.
-->

Version: v0.x.x.x-alpha (Refer to changelog as pre v1 is volatile)

### Version Phases
Major.Minor.Revision.Patch-Tag, pre v1 versions are highly volatile.
- Major = A set of new features, likely breaking
- Minor = New feature, potentially breaking
- Revision = Changes to how a pre-existing feature works, should not be breaking
- Patch = Fix an issue, cannot be breaking. Can also be a small revision(ie tweaking). 

#### Tags
 - `-alpha` Alpha - Unstable, Development version (Some may not be able to load the shader)
 - `-beta` Beta - Non-stable (Most will be able to load the shader)
 - `-rc0.0.0.0` RC(Release Candidate) - Mostly stable, can be applied every Major version(There may be exceptions for certain Minors)
   - Release Candidate version(`0.0.0.0` part) is optional. The normal version must still be used even when the RC version is used, it is simply a parallel version of how close it is to being released. The RC version should be: `currentVersion - lastNonRCVersion` which is the diff of the two.
 - `noTag` Release - Stable

### Branches
 - `main` stable releases
 - `dev` unstable prereleases
 - `v0.0.0.0_feature-some-feature` for working on features
 - `v0.0.0.0_patch-some-patch` for working on patches (Uncommon unless issue is hard to patch ie. takes multiple commits)

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
    - Fixed translucents not reflecting due to alt/main frame buffers
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
 - v0.7.6.2-alpha Misc Patches & Changes
    - `block_entities` now have `CUTOUT` flag
    - Specfically only `CUTOUT` in `shadow_cutout` program if Iris v1.8+
    - (Untested) Remove `DH_FADE_BLENDING.Blend` option when images are not supported(glsl 420)

