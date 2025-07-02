## Todo
- Port over the whole gbuffers_Main
  - Fix things looking wrong behind translucents -> prolly related to diffuse
- Port shadow fade out
- Port deffered pass
  - Port the `lightLevel` over

## Todo Later

## Todo Planned
- Transitions between cascades splits: Dithered(r2 noise) and Blended(sample 2 nearest cascades)

## Issues
- Metals do not have shadows because theres basically no light to them besides ambient
  - There should be ambient specular reflection
- Shadow likes clip out, maybe its near plane?
- CSM Zbiasing is broken, it biases too much -> Wait for Aperture to finalize CSMs to fix/improve it
  - Actually non CSM(1 cascade) is presumbly broken(you have to manually set near/far planes) and this shader is currently developed for 1 cascade thus causing CSM to not match
  - Maybe distort shadow in View Space instead of Clip Space as the latter is not consistent across cascades(?)

## Codes
- CODE: sadi1n, Requires more flexible reloading features from Aperturegg