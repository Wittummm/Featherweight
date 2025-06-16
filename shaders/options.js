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
var canReload = false;
var shouldReload = true;
function texIsolate(name) {
  return asInt(name, -1, 0, 1, 2, 3, 4).values("Off", "Full", "Top Left", "Top Right", "Bottom Left", "Bottom Right").needsReload(false).build(-1);
}
function texIsolates(...names) {
  let objs = [];
  for (const name of names) {
    objs.push(texIsolate(name));
  }
  return objs;
}
function setupOptions() {
  const general = new Page("General").add(asIntRange("SunPathRotation", 0, -90, 90, 5, false)).add(asFloat("Pixelization", 8, 16, 32, 64, 128, 256).needsReload(false).build(16)).build();
  const shadow = new Page("Shadows").add(asFloatRange("ShadowDistort", 0.7, 0, 1, 0.05, false)).add(asIntRange("ShadowSamples", 3, 2, 128, 1, false)).add(asInt("ShadowFilter", 0, 1, 2).values("Nearest", "Linear", "Uniform Soft").needsReload(canReload).build(1)).add(asBool("PresetPatternsPCF", true, canReload)).build();
  const debug = new Page("Debug").add(asBool("_DebugEnabled", false, shouldReload)).add(asBool("_DebugStats", false, false)).add(asBool("_SliceScreen", false, false)).add(asBool("_ShowShadows", false, false)).add(EMPTY).add(...texIsolates(
    "_ShowShadowMap",
    "_ShowDepth",
    "_ShowRoughness",
    "_ShowReflectance",
    "_ShowPorosity",
    "_ShowEmission",
    "_ShowNormals",
    "_ShowAmbientOcclusion",
    "_ShowHeight"
  )).build();
  const UNSORTED = new Page("UNSORTED").add(asInt("Specular", 0, 1).needsReload(false).build(1)).build();
  return new Page("Featherweight").add(general).add(shadow).add(UNSORTED).add(debug).build();
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
  for (let value = valueMin; value <= valueMax; value += interval) {
    values.push(value);
  }
  return values;
}
export {
  setupOptions
};
//# sourceMappingURL=options.js.map
