<!---
User-insignificant/developer-oriented details should be included as comments and excluded from the reading view.
-->

# Featherweight
An Iris minecraft shader focusing on lightweight features.

## Notes
- Built for and on Iris, other shader loaders may or may not work.
  - Iris v1.7.6 is incompatible.
- Built for OpenGL 4.2 or higher, lower versions may or may not work.
### Specific Behavior <!--- Behavior specific to versions of Sodium, Iris, Minecraft, or OpenGL -->
- `DH_FADE_BLENDING.Blend` requires GLSL 420 or higher; as it uses images.
<!---
- Program `shadow_cutout` and the corresponding cut program specific define `CUTOUT` requires Iris v1.8 or higher.
  - On pre Iris v1.8, the shader fallbacks to defining `CUTOUT` for the `shadow` program.
-->

## Acknowledgements
- ...
- <sub>Search `CREDIT:` and `ACKNOWLEDGE:` in the code for potentially missing or omitted references. </sub>

## Contact
You can contact me in the ShaderLABS discord(wittummm). 
Feel free to open Issues, Discussions and Pull Requests!
