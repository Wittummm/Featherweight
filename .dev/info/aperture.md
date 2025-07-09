This is based on manually searching through source code, and is non comprehensive!

### Iris Commands
```
/iris debug
/iris stats
```
### Iris Typescript API
```ts
// This is an overview, look in iris.d.ts for full api

// pack.ts(AperturePipeline.java)
setupShader(dimension: NamespaceId)
onSettingsChanged(worldState: WorldState)
getBlockId(block: BlockState): number
// options.ts(OptionMenuCreator.java)
setupOptions()

// functions
addTag(index, namespace: NamespaceId) // Adds a tag
NamespaceId createTag(tag: NamespaceId, blocks: NamespaceId[]) // Creates a tag matching to blocks
enableShadows(resolution, cascadeCount)
setLightColor(namespaceId, r, g, b, a) // Assigns an arbitrary Color
setLightColor(namespaceId, hex)
defineGlobally(key, value: string | number) // Defined a "#define" for all programs
registerShader(objectShader)
registerShader(stage, compositeShader)
setCombinationPass(finalShader)

isKeyDown(keyId: int) // Keys.someKey enum?
getCompositeInfo(program: ProgramStage) // get shader order
sendInChat(text: string)
registerBarrier(?)

/// Creating settings(OptionMenuCreator.java)
Page.add(someSetting)
asInt(name, values)
asFloat(name, values)
asString(name, values)
asBool(name)
putTextLabel(id, text) // Idk what this is
putTranslationLabel(id, text) // Idk what this is
//// Note: Could also make a module for Ranges like `IntRange` or `FloatRange`

/// Reading settings
getStringSetting(name): string
getIntSetting(name): number
getFloatSetting(name): number
getBoolSetting(name): boolean

// Writing/Modifying setiings
setStringSetting(name, value)
setIntSetting(name, value)
setFloatSetting(name, value)
setBoolSetting(name, value)
setHidden(name, bool)
setDisabled(name, bool)

// objects
NamespaceId(namespace, path)
NamespaceId(combinedPath)
GPUBuffer
Vector2f
Vector3f
Vector4f
WorldState

// built in variables
screenWidth
screenHeight
worldSettings: WorldSettings
```


### Iris glsl API
```c
// functions
bool iris_hasTag(uint blockId, uint tag)
iris_TextureInfo iris_getTexture(uint textureId) // loads TextureInfo ssbo
vec4 iris_getLightColor(uint blockId) // loads BlockInfo ssbo
bool iris_hasTag(uint blockId, uint tag)
uint iris_getMetadata(uint blockId)
uint iris_getCustomId(uint blockId)

bool iris_isFullBlock(uint blockId) // is all side solid, metadata
bool iris_hasFluid(uint blockId) // gets from metadata
int iris_getEmission(uint blockId) // gets from metadata

// sectionPos can be calculated as `blockPos >> 4`
uint iris_getBlockIndex(ivec3 pos) // calculates(not fetch) blockIndex
ivec2 iris_getBlockAtPos(ivec3 loc) // loc is world space!! (blockId, packedLightData) loads Voxel SSBO
iris_chunkSection iris_getSection(ivec3 loc) // loads Voxel SSBO
bool iris_isSectionLoaded(ivec3 loc) // loads Voxel SSBO
ivec2 iris_getBlockInSection(iris_chunkSection sect, ivec3 blockPos) // (blockId, packedLightData) // seems to missing from aperture source code?

vec4 iris_sampleIRIS_TEXTURE(vec2 uv)
vec4 iris_sampleIRIS_TEXTURELod(vec2 uv, float lod)
vec4 iris_sampleIRIS_TEXTUREGrad(vec2 uv, vec2 dx, vec2 dy)
vec4 iris_sampleLightmap(vec2 uv)

void iris_modifyBase(inout vec2 uv, inout vec4 color, inout vec2 light) // fragment only, idk what it does
bool iris_discardFragment(vec4 color) // returns if alpha clip

// structs
struct iris_TextureInfo {vec2 minCoord; vec2 maxCoord;};
struct VertexData\n{\n    
  vec4 modelPos;
  vec4 clipPos; 
  vec2 uv;
  vec2 light;
  vec4 color;
  vec3 normal;
  vec4 tangent;
  vec4 overlayColor;
  vec3 midBlock;
  uint blockId;
  uint textureId;   
  vec2 midCoord;  
  float ao;
};
struct iris_chunkSection {
    ivec2 ap_chunkData[16 * 16 *16]; // index is `iris_getBlockIndex(ivec3 pos)`
};

// ap variables/uniforms
mat4 iris_modelViewMatrix
mat4 iris_modelViewMatrixInverse
mat4 iris_projectionMatrix
mat4 iris_projectionMatrixInverse
mat3 iris_normalMatrix
int iris_currentCascade // in shadow programs only
gl_Layer // alias of `iris_currentCascade`

/// below is ap. part
camera
  pos // VEC3
  fractPos // VEC3
  intPos // IVEC3, floored pos
  blockPos // IVEC3
  fluid // INT
  near // FLOAT
  far // FLOAT
  renderDistance // FLOAT
  view // MAT4
  viewInv // MAT4
  projection // MAT4
  projectionInv // MAT4
  brightness // VEC2, lightLevel

temporal // last frame's data
  view // MAT4
  viewInv // MAT4
  projection // MAT4
  projectionInv // MAT4
  pos // VEC3

world
  rain // FLOAT, [0, 1]
  thunder // FLOAT, [0, 1]
  time // INT, worldTime
  day // INT, day count
  skyColor // VEC3
  fogStart // FLOAT
  fogEnd // FLOAT
  fogColor // VEC4
  internal_chunkDiameter // IVEC3

game
  screenSize // VEC2
  guiHidden // BOOL
  brightness // FLOAT
  mainHand // INT, id of item 
  offHand // INT, is of tem

time
  frames // INT, frames elapsed
  delta // FLOAT
  elapsed // FLOAT

celestial
  angle // FLOAT, sun angle
  phase // INT
  pos // VEC3, shadow light pos
  sunPos // VEC3
  upPos // VEC3
  moonPos // VEC3
  view // MAT4
  viewInv // MAT4
  projection // MAT4[8], per cascade
  projectionInv // MAT4[8], per cascade
  bsl_shadowFade // FLOAT
  makeUp_lightMix // FLOAT
  
// misc
/// irisInt is internal, shouldnt use 
irisInt_textureName
/// built in texture names 
BaseTex
NormalMap
SpecularMap

```

