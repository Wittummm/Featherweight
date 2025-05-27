## Stellar View

### Stars `settings/sky.glsl`
- To Use Stellar View stars -> Set `STARS` to `Vanilla`
- To Use Shader stars -> set `STARS` to not `Vanilla` + turn off Stellar View's stars

### Issues
- Shader Sky + Stellar Stars 
  - ISSUE: Vanilla sunset cannot be removed unless you turn Stellar View's `Textured Stars` and `REMOVE_STELLAR_VIEW_UNTEXTURED_STARS` on (This is a limitation as there is no way to detect the sunset currently)
  - ISSUE: sunPathRotation also offsets the moon, this should happen as Stellar View has its own moon movement. But i cant seem to find a (acceptable) way to mask out the moon from offsetting :( 