

## Include flags
Flags whether to include a snippet of something when using "#include"
- `EXCLUDE_NORMALS_WRITE` on `encodeNormals.glsl`
This document is meant to document this shader but expect it to be heavily developer oriented.

### Feature Flags
Search for these keywords to see what extra features you can toggle, most are disabled to reduce compile time.
 - `TURN_ON_DEBUG_MODE_HERE` debug features and menus
 - `EXTRA_SETTINGS` extra customization settings

### Personal Naming Conventions
 - **Casing**
    - Settings values = UPPER_SNAKE_CASE
    - Out buffers = PascalCase
    - ~~Config values = PascalCase~~
 - Light level = [0, 1]
 - Light Brightness = [0, ∞) adjusted for brightness
 - "Light" with no context refers to directional light ie sun/moon light
 - To avoid ambiguity we should avoid naming things with vague relation **especially** for objects. Examples:
  (Object) `playerPosition` could be intepreted likely as "position of the player" or unlikely "player space position". (Non-Object)`worldPosition` could be intepreted likely as "the position in the world" or unlikely "position of the world"(this is the unlikely case as we cant *usually* move worlds but objects such as players are moveable)
  Instead we should name things like `posPlayer`, `posWorld` meaning "position in player (space)" and "position in world (space)".

### Dev 
  - **Comment Tags**
    - Crediting(usu. for specific person, not public domain info)
      - `CREDIT: someName (someLink)`
      - `ACKNOWLEDGEMENT: someName (someLink)` More important/significant than CREDIT
      - `ACKNOWLEDGED: someName (someLink)` same as `ACKNOWLEDGEMENT` but is acknowledge in front page
      - `SOURCE:` or `SOURCES:` refers to original source code
    - `POINT` a weak "NOTICE"
    - `TODO` to do
    - `TODOMAYBE` maybe do
    - `TODONOW` ongoing code
    - `TODOLATER` to do in the foreseeable future
    - `TODONOWBUTLATER` should do at the end of the session/feature.
    - `TODOEVENTUALLY` should do eventually
    - `NOTE` a note for readers, including oneself
    - `PIN` likely will come back to, usually to edit/add features
    - `CODE: xxx` a random code(literally button mash) 
    - `REMOVE` to remove for some reason
    - `CONFIGTODO` to add this config to user accessible settings.
    - `AP_ISSUE` an issue/bug with aperture
    - `TEMP` temporary
  - **Notes**
    - Put "#define DISTANT_HORIZONS_SHADER" in the top of DH shader stages
    - Pixelization Overrides syntax:
      - Negative refers to relative scaling; Example `75` for 0.75 scale
      - Positive refers to absolute scaling; Example `32` for 32 pixels per block
      - 0 will use the fallback(PIXELIZATION) value
      - Example, CODE: sahj1283
      - How pixelization overrides works in _Aperture_ version
        - It will all be managed on the CPU side, each effect will have its own pixelization setting from the perspective of the shader, but the CPU manages it
    - Use the custom `farPlane` `nearPlane` `renderDistance` instead of iris's weird `far` and `near`
  
### Define Flags(dev)
 - ~~`DISTANT_HORIZONS_SHADER`~~ dh is currently not supported on aperture
 - `CUTOUT`
 - `FORWARD` forward rendered
 - `INCLUDE_NORMALS_WRITE` `encodeNormals.glsl`
 - ~~`EXCLUDE_STARS`~~ not ported yet
 - `ShadowsEnabled` on shaders that uses any shadow functions(calcShadow)
For (#include) flags use INCLUDE_ and EXCLUDE_ prefix 

### Organization of Files
 - "program" folder stores the shader files that directly points to final shaders, usually for sharing between multiple final shaders.
 - "func" folder stores Functions, a file can have many variants of a function. It differs from libs in that the functions must have the same purpose and not a random collection of functions.
   - `func` files should not include any uniforms as it could cause conflicts. Ideally `lib`s should also not have uniforms but this is not really enforced.
   - `func` and `lib` files should document what uniforms they need.
 - "lib" folder stores Libraries, where a library stores functions relating to a category.
 - "settings" stores config files.
 - "snippets" stores shader code that is embedded in other code, it is not the sole code.
 - "shared" stores shared files.

### Citing, Sources, Referencing
 - List of "Sources" at top of file with links. Each link has an `sourceIndex`
    - `[x]` means it is purely a resource.
 - Cite by doing `[sourceIndex/anyArbitraryPath]` for example: `[1]` `[2/#100]` `[3/5.3]`
    - `/` is used to go into deeper paths
    - `#` usually refers to page or header
    - `1.0` a float-like text usually refers to chapters, writing as integer alone is not recommended and there should always be a decimal even if it is zero.

### Storage/Containers
  - **Framebuffers**
    - sceneTex, stores final rendered image
    - gbufferTex, stores geometry data
  - **UBOs**
    - 0, settings buffer
  - **SSBOs**
    - 0, metadata buffer