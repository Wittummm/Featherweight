## Todo
- Port over the whole deferred shader(DO sky)
- Port shadow fade out
- Port deffered pass
  - Port the `lightLevel` over

## Todo Later
- Make caves not fully lit(water and non shadowing)
- SSR: Instead of using geometry normals based on depth, use actual normals from gbuffer that will be implemented soon, only sample normals(not whole pbr) -> only need to fetch normals in ssr compute, no color, no full pbr 


## Todo Planned
- Transitions between cascades splits: Dithered(r2 noise) and Blended(sample 2 nearest cascades)
- SSR: do an actual blur + make the blur depth aware
  - Actually you gotta skew the blur in the direction of the reflection ie draw vector from origin to hit, and then blur in that direction in screen space


## Issues
- Metals do not have shadows because theres basically no light to them besides ambient
  - There should be ambient specular reflection
- CSM Zbiasing is broken, it biases too much -> Wait for Aperture to finalize CSMs to fix/improve it
  - Actually non CSM(1 cascade) is presumbly broken(you have to manually set near/far planes) and this shader is currently developed for 1 cascade thus causing CSM to not match
  - Maybe distort shadow in View Space instead of Clip Space as the latter is not consistent across cascades(?)
- AmbientColor and LightColor and presumably all ssbos that are set on GPU and initialized values on CPU, will "flash" and worsens with higher framerates.
- Auto Exposure will get brighter as fps gets higher, it should be constant no matter the fps.
- Vanilla sky does not work perfectly as there is a weird mesh that is like a plane for some reason in Iris. In aperture this is rendered, but in iris it is seemingly not rendered(rendered but not to screen).

## Codes
- CODE: sadi1n, Requires more flexible reloading features from Aperturegg