var __defProp = Object.defineProperty;
var __defNormalProp = (obj, key, value) => key in obj ? __defProp(obj, key, { enumerable: true, configurable: true, writable: true, value }) : obj[key] = value;
var __publicField = (obj, key, value) => __defNormalProp(obj, typeof key !== "symbol" ? key + "" : key, value);

// modules/FixedBuiltStreamingBuffer.ts
var FixedStreamingBuffer = class {
  constructor() {
    __publicField(this, "byteSize", 0);
  }
  int() {
    this.byteSize += 4;
    return this;
  }
  float() {
    this.byteSize += 4;
    return this;
  }
  bool() {
    this.byteSize += 4;
    return this;
  }
  vec4() {
    this.byteSize += 4 * 4;
    return this;
  }
  vec3() {
    return this.vec4();
  }
  vec2() {
    this.byteSize += 4 * 2;
    return this;
  }
  build() {
    return new FixedBuiltStreamingBuffer(this.byteSize);
  }
};
var FixedBuiltStreamingBuffer = class {
  constructor(byteSize) {
    __publicField(this, "size");
    __publicField(this, "b");
    __publicField(this, "offset", 0);
    this.b = new StreamingBuffer(byteSize).build();
    this.size = byteSize;
  }
  get buffer() {
    return this.b;
  }
  get byteOffset() {
    return this.offset;
  }
  end() {
    this.offset = 0;
  }
  uploadData() {
    this.b.uploadData();
  }
  int(value) {
    if (this.offset + 4 > this.size) throw new Error(`Cannot add value beyond FixedBuiltStreamingBuffer's size, ${this.offset + 4} > ${this.size}`);
    value = typeof value == "string" ? getIntSetting(value) : value;
    this.b.setInt(this.offset, value);
    this.offset += 4;
    return this;
  }
  float(value) {
    if (this.offset + 4 > this.size) throw new Error(`Cannot add value beyond FixedBuiltStreamingBuffer's size, ${this.offset + 4} > ${this.size}`);
    value = typeof value == "string" ? getFloatSetting(value) : value;
    this.b.setFloat(this.offset, value);
    this.offset += 4;
    return this;
  }
  bool(value) {
    if (this.offset + 4 > this.size) throw new Error(`Cannot add value beyond FixedBuiltStreamingBuffer's size, ${this.offset + 4} > ${this.size}`);
    value = typeof value == "string" ? getBoolSetting(value) : value;
    this.b.setBool(this.offset, value);
    this.offset += 4;
    return this;
  }
  vec4(x, y, z, w) {
    this.float(x);
    this.float(y);
    this.float(z);
    this.float(w);
    return this;
  }
  vec3(x, y, z) {
    this.vec4(x, y, z, 0);
    return this;
  }
  vec2(x, y) {
    this.float(x);
    this.float(y);
    return this;
  }
};

// modules/Settings.ts
var Settings = class {
  constructor() {
  }
  static get sunPathRotation() {
    return getIntSetting("SunPathRotation");
  }
};

// modules/KeyInput.ts
var lastKeyDowns = [];
var KeyInput = class {
  static update() {
    lastKeyDowns[Keys.UNKNOWN] = isKeyDown(Keys.UNKNOWN);
    lastKeyDowns[Keys.SPACE] = isKeyDown(Keys.SPACE);
    lastKeyDowns[Keys.APOSTROPHE] = isKeyDown(Keys.APOSTROPHE);
    lastKeyDowns[Keys.COMMA] = isKeyDown(Keys.COMMA);
    lastKeyDowns[Keys.MINUS] = isKeyDown(Keys.MINUS);
    lastKeyDowns[Keys.PERIOD] = isKeyDown(Keys.PERIOD);
    lastKeyDowns[Keys.SLASH] = isKeyDown(Keys.SLASH);
    lastKeyDowns[Keys["0"]] = isKeyDown(Keys["0"]);
    lastKeyDowns[Keys["1"]] = isKeyDown(Keys["1"]);
    lastKeyDowns[Keys["2"]] = isKeyDown(Keys["2"]);
    lastKeyDowns[Keys["3"]] = isKeyDown(Keys["3"]);
    lastKeyDowns[Keys["4"]] = isKeyDown(Keys["4"]);
    lastKeyDowns[Keys["5"]] = isKeyDown(Keys["5"]);
    lastKeyDowns[Keys["6"]] = isKeyDown(Keys["6"]);
    lastKeyDowns[Keys["7"]] = isKeyDown(Keys["7"]);
    lastKeyDowns[Keys["8"]] = isKeyDown(Keys["8"]);
    lastKeyDowns[Keys["9"]] = isKeyDown(Keys["9"]);
    lastKeyDowns[Keys.SEMICOLON] = isKeyDown(Keys.SEMICOLON);
    lastKeyDowns[Keys.EQUAL] = isKeyDown(Keys.EQUAL);
    lastKeyDowns[Keys.A] = isKeyDown(Keys.A);
    lastKeyDowns[Keys.B] = isKeyDown(Keys.B);
    lastKeyDowns[Keys.C] = isKeyDown(Keys.C);
    lastKeyDowns[Keys.D] = isKeyDown(Keys.D);
    lastKeyDowns[Keys.E] = isKeyDown(Keys.E);
    lastKeyDowns[Keys.F] = isKeyDown(Keys.F);
    lastKeyDowns[Keys.G] = isKeyDown(Keys.G);
    lastKeyDowns[Keys.H] = isKeyDown(Keys.H);
    lastKeyDowns[Keys.I] = isKeyDown(Keys.I);
    lastKeyDowns[Keys.J] = isKeyDown(Keys.J);
    lastKeyDowns[Keys.K] = isKeyDown(Keys.K);
    lastKeyDowns[Keys.L] = isKeyDown(Keys.L);
    lastKeyDowns[Keys.M] = isKeyDown(Keys.M);
    lastKeyDowns[Keys.N] = isKeyDown(Keys.N);
    lastKeyDowns[Keys.O] = isKeyDown(Keys.O);
    lastKeyDowns[Keys.P] = isKeyDown(Keys.P);
    lastKeyDowns[Keys.Q] = isKeyDown(Keys.Q);
    lastKeyDowns[Keys.R] = isKeyDown(Keys.R);
    lastKeyDowns[Keys.S] = isKeyDown(Keys.S);
    lastKeyDowns[Keys.T] = isKeyDown(Keys.T);
    lastKeyDowns[Keys.U] = isKeyDown(Keys.U);
    lastKeyDowns[Keys.V] = isKeyDown(Keys.V);
    lastKeyDowns[Keys.W] = isKeyDown(Keys.W);
    lastKeyDowns[Keys.X] = isKeyDown(Keys.X);
    lastKeyDowns[Keys.Y] = isKeyDown(Keys.Y);
    lastKeyDowns[Keys.Z] = isKeyDown(Keys.Z);
    lastKeyDowns[Keys.LEFT_BRACKET] = isKeyDown(Keys.LEFT_BRACKET);
    lastKeyDowns[Keys.BACKSLASH] = isKeyDown(Keys.BACKSLASH);
    lastKeyDowns[Keys.RIGHT_BRACKET] = isKeyDown(Keys.RIGHT_BRACKET);
    lastKeyDowns[Keys.GRAVE_ACCENT] = isKeyDown(Keys.GRAVE_ACCENT);
    lastKeyDowns[Keys.WORLD_1] = isKeyDown(Keys.WORLD_1);
    lastKeyDowns[Keys.WORLD_2] = isKeyDown(Keys.WORLD_2);
    lastKeyDowns[Keys.ESCAPE] = isKeyDown(Keys.ESCAPE);
    lastKeyDowns[Keys.ENTER] = isKeyDown(Keys.ENTER);
    lastKeyDowns[Keys.TAB] = isKeyDown(Keys.TAB);
    lastKeyDowns[Keys.BACKSPACE] = isKeyDown(Keys.BACKSPACE);
    lastKeyDowns[Keys.INSERT] = isKeyDown(Keys.INSERT);
    lastKeyDowns[Keys.DELETE] = isKeyDown(Keys.DELETE);
    lastKeyDowns[Keys.RIGHT] = isKeyDown(Keys.RIGHT);
    lastKeyDowns[Keys.LEFT] = isKeyDown(Keys.LEFT);
    lastKeyDowns[Keys.DOWN] = isKeyDown(Keys.DOWN);
    lastKeyDowns[Keys.UP] = isKeyDown(Keys.UP);
    lastKeyDowns[Keys.PAGE_UP] = isKeyDown(Keys.PAGE_UP);
    lastKeyDowns[Keys.PAGE_DOWN] = isKeyDown(Keys.PAGE_DOWN);
    lastKeyDowns[Keys.HOME] = isKeyDown(Keys.HOME);
    lastKeyDowns[Keys.END] = isKeyDown(Keys.END);
    lastKeyDowns[Keys.CAPS_LOCK] = isKeyDown(Keys.CAPS_LOCK);
    lastKeyDowns[Keys.SCROLL_LOCK] = isKeyDown(Keys.SCROLL_LOCK);
    lastKeyDowns[Keys.NUM_LOCK] = isKeyDown(Keys.NUM_LOCK);
    lastKeyDowns[Keys.PRINT_SCREEN] = isKeyDown(Keys.PRINT_SCREEN);
    lastKeyDowns[Keys.PAUSE] = isKeyDown(Keys.PAUSE);
    lastKeyDowns[Keys.F1] = isKeyDown(Keys.F1);
    lastKeyDowns[Keys.F2] = isKeyDown(Keys.F2);
    lastKeyDowns[Keys.F3] = isKeyDown(Keys.F3);
    lastKeyDowns[Keys.F4] = isKeyDown(Keys.F4);
    lastKeyDowns[Keys.F5] = isKeyDown(Keys.F5);
    lastKeyDowns[Keys.F6] = isKeyDown(Keys.F6);
    lastKeyDowns[Keys.F7] = isKeyDown(Keys.F7);
    lastKeyDowns[Keys.F8] = isKeyDown(Keys.F8);
    lastKeyDowns[Keys.F9] = isKeyDown(Keys.F9);
    lastKeyDowns[Keys.F10] = isKeyDown(Keys.F10);
    lastKeyDowns[Keys.F11] = isKeyDown(Keys.F11);
    lastKeyDowns[Keys.F12] = isKeyDown(Keys.F12);
    lastKeyDowns[Keys.F13] = isKeyDown(Keys.F13);
    lastKeyDowns[Keys.F14] = isKeyDown(Keys.F14);
    lastKeyDowns[Keys.F15] = isKeyDown(Keys.F15);
    lastKeyDowns[Keys.F16] = isKeyDown(Keys.F16);
    lastKeyDowns[Keys.F17] = isKeyDown(Keys.F17);
    lastKeyDowns[Keys.F18] = isKeyDown(Keys.F18);
    lastKeyDowns[Keys.F19] = isKeyDown(Keys.F19);
    lastKeyDowns[Keys.F20] = isKeyDown(Keys.F20);
    lastKeyDowns[Keys.F21] = isKeyDown(Keys.F21);
    lastKeyDowns[Keys.F22] = isKeyDown(Keys.F22);
    lastKeyDowns[Keys.F23] = isKeyDown(Keys.F23);
    lastKeyDowns[Keys.F24] = isKeyDown(Keys.F24);
    lastKeyDowns[Keys.F25] = isKeyDown(Keys.F25);
    lastKeyDowns[Keys.KP_0] = isKeyDown(Keys.KP_0);
    lastKeyDowns[Keys.KP_1] = isKeyDown(Keys.KP_1);
    lastKeyDowns[Keys.KP_2] = isKeyDown(Keys.KP_2);
    lastKeyDowns[Keys.KP_3] = isKeyDown(Keys.KP_3);
    lastKeyDowns[Keys.KP_4] = isKeyDown(Keys.KP_4);
    lastKeyDowns[Keys.KP_5] = isKeyDown(Keys.KP_5);
    lastKeyDowns[Keys.KP_6] = isKeyDown(Keys.KP_6);
    lastKeyDowns[Keys.KP_7] = isKeyDown(Keys.KP_7);
    lastKeyDowns[Keys.KP_8] = isKeyDown(Keys.KP_8);
    lastKeyDowns[Keys.KP_9] = isKeyDown(Keys.KP_9);
    lastKeyDowns[Keys.KP_DECIMAL] = isKeyDown(Keys.KP_DECIMAL);
    lastKeyDowns[Keys.KP_DIVIDE] = isKeyDown(Keys.KP_DIVIDE);
    lastKeyDowns[Keys.KP_MULTIPLY] = isKeyDown(Keys.KP_MULTIPLY);
    lastKeyDowns[Keys.KP_SUBTRACT] = isKeyDown(Keys.KP_SUBTRACT);
    lastKeyDowns[Keys.KP_ADD] = isKeyDown(Keys.KP_ADD);
    lastKeyDowns[Keys.KP_ENTER] = isKeyDown(Keys.KP_ENTER);
    lastKeyDowns[Keys.KP_EQUAL] = isKeyDown(Keys.KP_EQUAL);
    lastKeyDowns[Keys.LEFT_SHIFT] = isKeyDown(Keys.LEFT_SHIFT);
    lastKeyDowns[Keys.LEFT_CONTROL] = isKeyDown(Keys.LEFT_CONTROL);
    lastKeyDowns[Keys.LEFT_ALT] = isKeyDown(Keys.LEFT_ALT);
    lastKeyDowns[Keys.LEFT_SUPER] = isKeyDown(Keys.LEFT_SUPER);
    lastKeyDowns[Keys.RIGHT_SHIFT] = isKeyDown(Keys.RIGHT_SHIFT);
    lastKeyDowns[Keys.RIGHT_CONTROL] = isKeyDown(Keys.RIGHT_CONTROL);
    lastKeyDowns[Keys.RIGHT_ALT] = isKeyDown(Keys.RIGHT_ALT);
    lastKeyDowns[Keys.RIGHT_SUPER] = isKeyDown(Keys.RIGHT_SUPER);
    lastKeyDowns[Keys.MENU] = isKeyDown(Keys.MENU);
    lastKeyDowns[Keys.LAST] = isKeyDown(Keys.LAST);
  }
  static onKeyDown(key) {
    if (!lastKeyDowns[key] && isKeyDown(key)) return true;
  }
  static onKeyUp(key) {
    if (lastKeyDowns[key] && !isKeyDown(key)) return true;
  }
};

// modules/HelperFuncs.ts
function toggleBoolSetting(name) {
  setBoolSetting(name, !getBoolSetting(name));
}

// pack.ts
var DEBUG_CONFIG = {
  debug: true,
  outputToChat: true
};
var debugBuffer;
var settingsBuffer;
function setupSettings(state) {
  worldSettings.sunPathRotation = Settings.sunPathRotation;
  worldSettings.ambientOcclusionLevel = 1;
  worldSettings.mergedHandDepth = true;
  worldSettings.shadowMapDistance = 64;
  settingsBuffer.vec3(1, 1, 1).vec4(1, 1, 1, 1).int("ShadowSamples").int("ShadowFilter").bool("PresetPatternsPCF").float("ShadowDistort").float("Pixelization").int("Specular").end();
  if (debugBuffer) {
    debugBuffer.bool("_DebugEnabled").bool("_DebugStats").bool("_SliceScreen").int("_ShowDepth").int("_ShowRoughness").int("_ShowReflectance").int("_ShowPorosity").int("_ShowEmission").int("_ShowNormals").int("_ShowAmbientOcclusion").int("_ShowHeight").int("_ShowShadowMap").bool("_ShowShadows").end();
  }
}
function setup() {
  let sceneTexture = new Texture("sceneTex").imageName("sceneImg").format(Format.RGBA16F).build();
  let gbufferTexture = new Texture("gbufferTex").imageName("gbufferImg").format(Format.RG32UI).build();
  function terrainProgram(usage, name, programName) {
    return new ObjectShader(programName || name, usage).vertex(`programs/geometry/${name}.vsh`).fragment(`programs/geometry/${name}.fsh`).target(0, sceneTexture).target(1, gbufferTexture).blendOff(1);
  }
  function bindSettings(program) {
    return program.ssbo(0, settingsBuffer.buffer);
  }
  function setupResources() {
    debugBuffer = getBoolSetting("_DebugEnabled") ? new FixedStreamingBuffer().bool().bool().bool().int().int().int().int().int().int().int().int().int().bool().build() : null;
    settingsBuffer = new FixedStreamingBuffer().vec3().vec4().int().int().bool().float().float().int().build();
  }
  function setupPrograms() {
    registerShader(Stage.POST_RENDER, bindSettings(new Compute("init_settings")).location("programs/init/settings.csh").workGroups(1, 1, 1).build());
    registerShader(
      terrainProgram(Usage.TERRAIN_SOLID, "geometry_main", "terrain_solid").blendOff(0).build()
    );
    registerShader(
      terrainProgram(Usage.TERRAIN_CUTOUT, "geometry_main", "terrain_cutout").blendOff(0).define("CUTOUT", "1").build()
    );
    registerShader(
      terrainProgram(Usage.TERRAIN_TRANSLUCENT, "geometry_main", "terrain_translucent").define("TRANSLUCENT", "1").build()
    );
    registerShader(
      Stage.POST_RENDER,
      bindSettings(new Compute("shade")).location("programs/post_render/shade.csh").workGroups(Math.ceil(screenWidth / 16), Math.ceil(screenHeight / 16), 1).build()
    );
    enableShadows(512, 1);
    registerShader(
      bindSettings(new ObjectShader("shadow", Usage.SHADOW)).vertex(`programs/geometry/shadow.vsh`).fragment(`programs/geometry/shadow.fsh`).define("CUTOUT", "").build()
    );
    if (debugBuffer) {
      registerShader(
        Stage.POST_RENDER,
        bindSettings(new Compute("debug")).location("programs/post_render/debug.csh").workGroups(Math.ceil(screenWidth / 16), Math.ceil(screenHeight / 16), 1).ubo(0, debugBuffer.buffer).build()
      );
    }
  }
  setupResources();
  setupPrograms();
  setupSettings();
}
function onSettingsChanged(state) {
  setupSettings(state);
}
function setupShader(dimension) {
  setup();
  setCombinationPass(new CombinationPass("programs/finalize/final.fsh").build());
  if (DEBUG_CONFIG.debug) {
    let dumpDebugInfo = function(chat = false) {
      let output = chat ? sendInChat : print;
    };
    dumpDebugInfo(DEBUG_CONFIG.outputToChat);
  }
}
function setupFrame(state) {
  settingsBuffer.uploadData();
  if (debugBuffer) {
    debugBuffer.uploadData();
  }
  if (KeyInput.onKeyDown(Keys.E)) {
    toggleBoolSetting("_DebugEnabled");
    if (getBoolSetting("_DebugEnabled")) {
      sendInChat("Debug mode enabled, may need reload to work");
    }
  }
  if (KeyInput.onKeyDown(Keys.LEFT)) {
    setIntSetting("SunPathRotation", getIntSetting("SunPathRotation") - 5);
  }
  if (KeyInput.onKeyDown(Keys.RIGHT)) {
    setIntSetting("SunPathRotation", getIntSetting("SunPathRotation") + 5);
  }
  KeyInput.update();
}
export {
  onSettingsChanged,
  setupFrame,
  setupShader
};
//# sourceMappingURL=pack.js.map
