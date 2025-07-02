// ../build/generateLangDummy.ts
Object.prototype.name = function() {
  return this;
};
Object.prototype.values = function() {
  return this;
};
Object.prototype.prefix = function() {
  return this;
};
Object.prototype.suffix = function() {
  return this;
};
Object.prototype.desc = function() {
  return this;
};

// options.ts
var shouldReload = true;
function texIsolate(name) {
  return asInt(name, -1, 0, 1, 2, 3, 4).values("Off", "Full", "Top Left", "Top Right", "Bottom Left", "Bottom Right").name(name.replace("_Show", "Show ")).needsReload(false).build(-1);
}
function texIsolates(...names) {
  let objs = [];
  for (const name of names) {
    objs.push(texIsolate(name));
  }
  return objs;
}
function setupOptions() {
  const shadowPixelization = asPixelizationOverride("ShadowPixelization").name();
  const shadingPixelization = asPixelizationOverride("ShadingPixelization").name();
  const general = new Page("General").add(asIntRange("SunPathRotation", 0, -90, 90, 5, false).name()).add(
    new Page("Page_Pixelization").name().add(
      asInt("Pixelization", 0, 8, 16, 32, 64, 128, 256).needsReload(false).build(16).values("Off")
    ).add(shadowPixelization).add(shadingPixelization).build()
  ).build();
  const shadow = new Page("Shadows").add(asBool("ShadowsEnabled", true, true).name()).add(
    asInt("ShadowResolution", 128, 256, 512, 768, 1024, 1536, 2048, 2560, 3072, 4096, 6144, 8192, 12288, 16384).needsReload(true).build(768).name()
  ).add(asInt("ShadowDistance", 16, 32, 48, 64, 80, 96, 128, 160, 192, 240, 288, 352, 400, 448, 512, 640, 768, 896, 1024, 1280, 1536, 1792, 2048).needsReload(false).build(64).name()).add(
    asInt("ShadowFilter", 0, 1, 2).needsReload(false).build(1).name().values("Nearest", "Linear", "Uniform Soft")
  ).add(putTextLabel("LabelSoftShadows", "Soft Shadows")).add(
    asFloat("ShadowSamples", -2, -1.75, -1.5, -1.25, -1, -0.75, 2, 3, 5, 7, 9, 12, 15, 20, 25, 30, 35, 40, 48, 54, 60, 70, 80, 90, 100, 110, 120, 130).needsReload(false).build(-1).name()
  ).add(asFloatRange("ShadowSoftness", 0.7, 0, 6, 0.05, false).name()).add(
    new Page("ShadowsExtra").name().add(shadowPixelization).add(asFloatRange("ShadowDistort", 2, 0, 5, 0.05, false).name().desc("Allocate more resolution closer to the player.\n When using Shadow Cascades, this value should generally be lowered.")).add(asIntRange("ShadowCascadeCount", 0, 0, 8, 1, true).name().values("Auto")).add(asFloatRange("ShadowBias", 0.5, 0, 1, 0.025, false).name().desc("Increase to reduce shadow acne at the cost of increasing peter panning.")).build()
  ).build();
  const debug = new Page("Debug").add(asBool("_DumpUniforms", false, false).name()).add(asBool("_DebugEnabled", false, shouldReload).name()).add(asFloatRange("_ShadowLightBrightness", 1, 0, 5, 0.05, false).name()).add(asBool("_ShowShadows", false, false).name()).add(asBool("_ShowShadowCascades", false, false).name()).add(asIntRange("_ShadowCascadeIndex", 0, 0, 8, 1, false).name()).add(
    new Page("ShowTextures").name().add(asBool("_SliceScreen", false, false).name()).add(...texIsolates(
      "_ShowShadowMap",
      "_ShowDepth",
      "_ShowRoughness",
      "_ShowReflectance",
      "_ShowPorosity",
      "_ShowEmission",
      "_ShowNormals",
      "_ShowAmbientOcclusion",
      "_ShowHeight"
    )).build()
  ).add(
    new Page("DebugUI").name("Debug UI").add(asFloatRange("_DebugUIScale", 2, 0, 8, 0.1, false).name("Debug UI Scale")).add(asBool("_DebugStats", false, false).name("Debug Stats")).add(putTextLabel("_LabelDisplaySettings", "Display Settings")).add(asBool("_DisplayAtmospheric", false, false).name()).add(asBool("_DisplaySunlightColors", false, false).name()).build()
  ).build();
  const shading = new Page("Shading").add(asInt("Specular", 0, 1).needsReload(false).build(1)).add(asFloatRange("NormalStrength", 1, 0, 1, 0.05, false)).add(shadingPixelization).build();
  return new Page("Featherweight").add(general).add(shadow).add(shading).add(debug).build();
}
function asPixelizationOverride(name) {
  return asFloat(name, -0.25, -0.5, -1, 0, 8, 16, 32, 64, 128, 256).needsReload(false).build(-1).values("25 %", "50 %", "100 %");
}
function asIntRange(keyName, defaultValue, valueMin, valueMax, interval, reload = true) {
  const values = getValueRange(valueMin, valueMax, interval);
  return asInt(keyName, ...values).needsReload(reload).build(defaultValue);
}
function asFloatRange(keyName, defaultValue, valueMin, valueMax, interval, reload = true) {
  const values = getValueRange(valueMin, valueMax, interval);
  return asFloat(keyName, ...values).needsReload(reload).build(defaultValue);
}
function getValueRange(valueMin, valueMax, interval) {
  const values = [];
  for (let value = valueMin; value <= valueMax + 1e-3; value += interval) {
    values.push(value);
  }
  return values;
}
export {
  setupOptions
};
//# sourceMappingURL=options.js.map
