`gbuffers_main.fsh`

This is a self note of how Distant Horizons blending works
## Blending Modes
### Dither Mode
This is a simple dither blending, it is a simple method and thus has no bugs.

### Blend Mode
This is non-simple blending which combines dithering and actually blending the color.
It fallbacks to dithering when
 - DH and vanilla block has a discrepancy ie not same block (shape) or missing block.
 - Translucents