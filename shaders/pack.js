var __defProp = Object.defineProperty;
var __typeError = (msg) => {
  throw TypeError(msg);
};
var __defNormalProp = (obj, key, value) => key in obj ? __defProp(obj, key, { enumerable: true, configurable: true, writable: true, value }) : obj[key] = value;
var __publicField = (obj, key, value) => __defNormalProp(obj, typeof key !== "symbol" ? key + "" : key, value);
var __accessCheck = (obj, member, msg) => member.has(obj) || __typeError("Cannot " + msg);
var __privateAdd = (obj, member, value) => member.has(obj) ? __typeError("Cannot add the same private member more than once") : member instanceof WeakSet ? member.add(obj) : member.set(obj, value);
var __privateMethod = (obj, member, method) => (__accessCheck(obj, member, "access private method"), method);

// modules/vector/Vec4.ts
var _Vec4_instances, add_fn, sub_fn, mul_fn, div_fn;
var _Vec4 = class _Vec4 {
  constructor(x, y, z, w) {
    __privateAdd(this, _Vec4_instances);
    __publicField(this, "x");
    __publicField(this, "y");
    __publicField(this, "z");
    __publicField(this, "w");
    if (typeof x === "number" && typeof y !== "number") {
      this.x = x;
      this.y = x;
      this.z = x;
      this.w = x;
    } else if (x instanceof Vector4f) {
      this.x = x.x();
      this.y = x.y();
      this.z = x.z();
      this.w = x.w();
    } else {
      this.x = x;
      this.y = y;
      this.z = z;
      this.w = w;
    }
  }
  xyzw() {
    return [this.x, this.y, this.z, this.w];
  }
  clone() {
    return new (this.constructor(...this.xyzw()))();
  }
  toVector4f() {
    return new Vector4f(...this.xyzw());
  }
  negate() {
    this.x = -this.x;
    this.y = -this.y;
    this.z = -this.z;
    this.w = -this.w;
    return this;
  }
  add(x, y, z, w) {
    return typeof x === "number" ? __privateMethod(this, _Vec4_instances, add_fn).call(this, x, y, z, w) : __privateMethod(this, _Vec4_instances, add_fn).call(this, x.x, x.y, x.z, x.w);
  }
  sub(x, y, z, w) {
    return typeof x === "number" ? __privateMethod(this, _Vec4_instances, sub_fn).call(this, x, y, z, w) : __privateMethod(this, _Vec4_instances, sub_fn).call(this, x.x, x.y, x.z, x.w);
  }
  mul(x, y, z, w) {
    return typeof x === "number" ? __privateMethod(this, _Vec4_instances, mul_fn).call(this, x, y, z, w) : __privateMethod(this, _Vec4_instances, mul_fn).call(this, x.x, x.y, x.z, x.w);
  }
  scale(v) {
    return __privateMethod(this, _Vec4_instances, mul_fn).call(this, v, v, v, v);
  }
  div(x, y, z, w) {
    return typeof x === "number" ? __privateMethod(this, _Vec4_instances, div_fn).call(this, x, y, z, w) : __privateMethod(this, _Vec4_instances, div_fn).call(this, x.x, x.y, x.z, x.w);
  }
  floor() {
    this.x = Math.floor(this.x);
    this.y = Math.floor(this.y);
    this.z = Math.floor(this.z);
    this.w = Math.floor(this.w);
    return this;
  }
  ceil() {
    this.x = Math.ceil(this.x);
    this.y = Math.ceil(this.y);
    this.z = Math.ceil(this.z);
    this.w = Math.ceil(this.w);
    return this;
  }
  abs() {
    this.x = Math.abs(this.x);
    this.y = Math.abs(this.y);
    this.z = Math.abs(this.z);
    this.w = Math.abs(this.w);
    return this;
  }
  sign() {
    this.x = Math.sign(this.x);
    this.y = Math.sign(this.y);
    this.z = Math.sign(this.z);
    this.w = Math.sign(this.w);
    return this;
  }
  min(min) {
    this.x = Math.min(this.x, min.x);
    this.y = Math.min(this.y, min.y);
    this.z = Math.min(this.z, min.z);
    this.w = Math.min(this.w, min.w);
    return this;
  }
  max(max) {
    this.x = Math.max(this.x, max.x);
    this.y = Math.max(this.y, max.y);
    this.z = Math.max(this.z, max.z);
    this.w = Math.max(this.w, max.w);
    return this;
  }
  clamp(min, max) {
    this.min(max);
    this.max(min);
    return this;
  }
  lengthSquared() {
    return this.x * this.x + this.y * this.y + this.z * this.z + this.w * this.w;
  }
  length() {
    return Math.sqrt(this.lengthSquared());
  }
  normalize() {
    const len = this.length();
    if (len > 0) {
      return this.scale(1 / len);
    }
    return this;
  }
  dot(other) {
    return this.x * other.x + this.y * other.y + this.z * other.z + this.w * other.w;
  }
  distanceTo(other) {
    return this.clone().sub(other).length();
  }
};
_Vec4_instances = new WeakSet();
add_fn = function(x, y, z, w) {
  this.x += x;
  this.y += y;
  this.z += z;
  this.w += w;
  return this;
};
sub_fn = function(x, y, z, w) {
  this.x -= x;
  this.y -= y;
  this.z -= z;
  this.w -= w;
  return this;
};
mul_fn = function(x, y, z, w) {
  this.x *= x;
  this.y *= y;
  this.z *= z;
  this.w *= w;
  return this;
};
div_fn = function(x, y, z, w) {
  this.x /= x;
  this.y /= y;
  this.z /= z;
  this.w /= w;
  return this;
};
__publicField(_Vec4, "zero", new _Vec4(0));
__publicField(_Vec4, "one", new _Vec4(1));
var Vec4 = _Vec4;

// modules/vector/Vec3.ts
var _Vec3_instances, add_fn2, sub_fn2, mul_fn2, div_fn2;
var _Vec3 = class _Vec3 {
  constructor(x, y, z) {
    __privateAdd(this, _Vec3_instances);
    __publicField(this, "x");
    __publicField(this, "y");
    __publicField(this, "z");
    if (typeof x === "number" && typeof y !== "number") {
      this.x = x;
      this.y = x;
      this.z = x;
    } else if (x instanceof Vector3f) {
      this.x = x.x();
      this.y = x.y();
      this.z = x.z();
    } else {
      this.x = x;
      this.y = y;
      this.z = z;
    }
  }
  xyz() {
    return [this.x, this.y, this.z];
  }
  clone() {
    return new _Vec3(...this.xyz());
  }
  toVector3f() {
    return new Vector3f(...this.xyz());
  }
  negate() {
    this.x = -this.x;
    this.y = -this.y;
    this.z = -this.z;
    return this;
  }
  add(x, y, z) {
    return typeof x === "number" ? __privateMethod(this, _Vec3_instances, add_fn2).call(this, x, y, z) : __privateMethod(this, _Vec3_instances, add_fn2).call(this, x.x, x.y, x.z);
  }
  sub(x, y, z) {
    return typeof x === "number" ? __privateMethod(this, _Vec3_instances, sub_fn2).call(this, x, y, z) : __privateMethod(this, _Vec3_instances, sub_fn2).call(this, x.x, x.y, x.z);
  }
  mul(x, y, z) {
    return typeof x === "number" ? __privateMethod(this, _Vec3_instances, mul_fn2).call(this, x, y, z) : __privateMethod(this, _Vec3_instances, mul_fn2).call(this, x.x, x.y, x.z);
  }
  scale(v) {
    return __privateMethod(this, _Vec3_instances, mul_fn2).call(this, v, v, v);
  }
  div(x, y, z) {
    return typeof x === "number" ? __privateMethod(this, _Vec3_instances, div_fn2).call(this, x, y, z) : __privateMethod(this, _Vec3_instances, div_fn2).call(this, x.x, x.y, x.z);
  }
  floor() {
    this.x = Math.floor(this.x);
    this.y = Math.floor(this.y);
    this.z = Math.floor(this.z);
    return this;
  }
  ceil() {
    this.x = Math.ceil(this.x);
    this.y = Math.ceil(this.y);
    this.z = Math.ceil(this.z);
    return this;
  }
  abs() {
    this.x = Math.abs(this.x);
    this.y = Math.abs(this.y);
    this.z = Math.abs(this.z);
    return this;
  }
  sign() {
    this.x = Math.sign(this.x);
    this.y = Math.sign(this.y);
    this.z = Math.sign(this.z);
    return this;
  }
  min(min) {
    this.x = Math.min(this.x, min.x);
    this.y = Math.min(this.y, min.y);
    this.z = Math.min(this.z, min.z);
    return this;
  }
  max(max) {
    this.x = Math.max(this.x, max.x);
    this.y = Math.max(this.y, max.y);
    this.z = Math.max(this.z, max.z);
    return this;
  }
  clamp(min, max) {
    this.min(max);
    this.max(min);
    return this;
  }
  lengthSquared() {
    return this.x * this.x + this.y * this.y + this.z * this.z;
  }
  length() {
    return Math.sqrt(this.lengthSquared());
  }
  normalize() {
    const len = this.length();
    if (len > 0) {
      return this.scale(1 / len);
    }
    return this;
  }
  cross(other) {
    return new _Vec3(
      this.y * other.z - this.z * other.y,
      this.z * other.x - this.x * other.z,
      this.x * other.y - this.y * other.x
    );
  }
  dot(other) {
    return this.x * other.x + this.y * other.y + this.z * other.z;
  }
  distanceTo(other) {
    return this.clone().sub(other).length();
  }
  get volume() {
    return this.x * this.y * this.z;
  }
};
_Vec3_instances = new WeakSet();
add_fn2 = function(x, y, z) {
  this.x += x;
  this.y += y;
  this.z += z;
  return this;
};
sub_fn2 = function(x, y, z) {
  this.x -= x;
  this.y -= y;
  this.z -= z;
  return this;
};
mul_fn2 = function(x, y, z) {
  this.x *= x;
  this.y *= y;
  this.z *= z;
  return this;
};
div_fn2 = function(x, y, z) {
  this.x /= x;
  this.y /= y;
  this.z /= z;
  return this;
};
__publicField(_Vec3, "zero", new _Vec3(0));
__publicField(_Vec3, "one", new _Vec3(1));
var Vec3 = _Vec3;

// modules/vector/Vec2.ts
var _Vec2_instances, add_fn3, sub_fn3, mul_fn3, div_fn3;
var _Vec2 = class _Vec2 {
  constructor(x, y) {
    __privateAdd(this, _Vec2_instances);
    __publicField(this, "x");
    __publicField(this, "y");
    if (typeof x === "number" && typeof y !== "number") {
      this.x = x;
      this.y = x;
    } else if (x instanceof Vector2f) {
      this.x = x.x();
      this.y = x.y();
    } else {
      this.x = x;
      this.y = y;
    }
  }
  xy() {
    return [this.x, this.y];
  }
  clone() {
    return new (this.constructor(...this.xy()))();
  }
  toVector2f() {
    return new Vector2f(...this.xy());
  }
  negate() {
    this.x = -this.x;
    this.y = -this.y;
    return this;
  }
  add(x, y) {
    return typeof x === "number" ? __privateMethod(this, _Vec2_instances, add_fn3).call(this, x, y) : __privateMethod(this, _Vec2_instances, add_fn3).call(this, x.x, x.y);
  }
  sub(x, y) {
    return typeof x === "number" ? __privateMethod(this, _Vec2_instances, sub_fn3).call(this, x, y) : __privateMethod(this, _Vec2_instances, sub_fn3).call(this, x.x, x.y);
  }
  mul(x, y) {
    return typeof x === "number" ? __privateMethod(this, _Vec2_instances, mul_fn3).call(this, x, y) : __privateMethod(this, _Vec2_instances, mul_fn3).call(this, x.x, x.y);
  }
  scale(v) {
    return __privateMethod(this, _Vec2_instances, mul_fn3).call(this, v, v);
  }
  div(x, y) {
    return typeof x === "number" ? __privateMethod(this, _Vec2_instances, div_fn3).call(this, x, y) : __privateMethod(this, _Vec2_instances, div_fn3).call(this, x.x, x.y);
  }
  floor() {
    this.x = Math.floor(this.x);
    this.y = Math.floor(this.y);
    return this;
  }
  ceil() {
    this.x = Math.ceil(this.x);
    this.y = Math.ceil(this.y);
    return this;
  }
  abs() {
    this.x = Math.abs(this.x);
    this.y = Math.abs(this.y);
    return this;
  }
  sign() {
    this.x = Math.sign(this.x);
    this.y = Math.sign(this.y);
    return this;
  }
  min(min) {
    this.x = Math.min(this.x, min.x);
    this.y = Math.min(this.y, min.y);
    return this;
  }
  max(max) {
    this.x = Math.max(this.x, max.x);
    this.y = Math.max(this.y, max.y);
    return this;
  }
  clamp(min, max) {
    this.min(max);
    this.max(min);
    return this;
  }
  lengthSquared() {
    return this.x * this.x + this.y * this.y;
  }
  length() {
    return Math.sqrt(this.lengthSquared());
  }
  normalize() {
    const len = this.length();
    if (len > 0) {
      return this.scale(1 / len);
    }
    return this;
  }
  dot(other) {
    return this.x * other.x + this.y * other.y;
  }
  distanceTo(other) {
    return this.clone().sub(other).length();
  }
};
_Vec2_instances = new WeakSet();
add_fn3 = function(x, y) {
  this.x += x;
  this.y += y;
  return this;
};
sub_fn3 = function(x, y) {
  this.x -= x;
  this.y -= y;
  return this;
};
mul_fn3 = function(x, y) {
  this.x *= x;
  this.y *= y;
  return this;
};
div_fn3 = function(x, y) {
  this.x /= x;
  this.y /= y;
  return this;
};
__publicField(_Vec2, "zero", new _Vec2(0));
__publicField(_Vec2, "one", new _Vec2(1));
var Vec2 = _Vec2;

// modules/FixedStreamingBuffer.ts
var outputSettingValues = true;
function dumpSettings(bool) {
  outputSettingValues = bool;
}
function output(display, value) {
  if (display && outputSettingValues) {
    sendInChat(display + `: ${value}`);
  }
}
function _getIntSetting(name) {
  output(name, getIntSetting(name));
  return getIntSetting(name);
}
function _getFloatSetting(name) {
  output(name, Math.round(getFloatSetting(name) * 100) * 0.01);
  return getFloatSetting(name);
}
function _getBoolSetting(name) {
  output(name, getBoolSetting(name));
  return getBoolSetting(name);
}
function _getStringSetting(name) {
  output(name, getStringSetting(name));
  return getStringSetting(name);
}
var FixedStreamingBuffer = class {
  constructor() {
    __publicField(this, "offset", 0);
  }
  align(alignment) {
    this.offset = Math.ceil(this.offset / alignment) * alignment;
  }
  int(_) {
    this.align(4);
    this.offset += 4;
    return this;
  }
  uint(_) {
    return this.int();
  }
  float(_) {
    this.align(4);
    this.offset += 4;
    return this;
  }
  bool(_) {
    this.align(4);
    this.offset += 4;
    return this;
  }
  vec4(_) {
    this.align(16);
    this.offset += 4 * 4;
    return this;
  }
  vec3(_) {
    return this.vec4();
  }
  vec2(_) {
    this.align(8);
    this.offset += 4 * 2;
    return this;
  }
  ivec4(_) {
    return this.vec4();
    ;
  }
  ivec3(_) {
    return this.ivec4();
  }
  ivec2(_) {
    return this.vec2();
  }
  build() {
    return new FixedBuiltStreamingBuffer(this.offset);
  }
};
var _FixedBuiltStreamingBuffer = class _FixedBuiltStreamingBuffer {
  constructor(byteSize) {
    __publicField(this, "size");
    __publicField(this, "b");
    __publicField(this, "offset", 0);
    this.b = _FixedBuiltStreamingBuffer.pipeline.createStreamingBuffer(byteSize);
    this.size = byteSize;
  }
  get buffer() {
    return this.b;
  }
  static setPipeline(pipeline) {
    _FixedBuiltStreamingBuffer.pipeline = pipeline;
  }
  get byteOffset() {
    return this.offset;
  }
  align(alignment) {
    this.offset = Math.ceil(this.offset / alignment) * alignment;
  }
  end() {
    this.offset = 0;
  }
  uploadData() {
    this.b.uploadData();
  }
  int(value, display) {
    if (this.offset + 4 > this.size) throw new Error(`Cannot add value beyond FixedBuiltStreamingBuffer's size, ${this.offset + 4} > ${this.size}`);
    value = typeof value == "string" ? _getIntSetting(value) : value;
    output(display, value);
    this.align(4);
    this.b.setInt(this.offset, value);
    this.offset += 4;
    return this;
  }
  uint(value, display) {
    return this.int(value, display);
  }
  float(value, display) {
    if (this.offset + 4 > this.size) throw new Error(`Cannot add value beyond FixedBuiltStreamingBuffer's size, ${this.offset + 4} > ${this.size}`);
    value = typeof value == "string" ? _getFloatSetting(value) : value;
    output(display, value);
    this.align(4);
    this.b.setFloat(this.offset, value);
    this.offset += 4;
    return this;
  }
  bool(value, display) {
    if (this.offset + 4 > this.size) throw new Error(`Cannot add value beyond FixedBuiltStreamingBuffer's size, ${this.offset + 4} > ${this.size}`);
    value = typeof value == "string" ? _getBoolSetting(value) : value;
    output(display, value);
    this.align(4);
    this.b.setBool(this.offset, value);
    this.offset += 4;
    return this;
  }
  vec4(x, y, z, w, display) {
    output(display, `(${x}, ${y}, ${z}, ${w})`);
    this.align(16);
    this.float(x);
    this.float(y);
    this.float(z);
    this.float(w);
    return this;
  }
  vec3(x, y, z, display) {
    this.vec4(x, y, z, 0, display);
    return this;
  }
  vec2(x, y, display) {
    output(display, `(${x}, ${y})`);
    this.float(x);
    this.float(y);
    return this;
  }
  ivec4(x, y, z, w) {
    this.align(16);
    this.int(x);
    this.int(y);
    this.int(z);
    this.int(w);
    return this;
  }
  ivec3(x, y, z) {
    this.ivec4(x, y, z, 0);
    return this;
  }
  ivec2(x, y) {
    this.int(x);
    this.int(y);
    return this;
  }
};
__publicField(_FixedBuiltStreamingBuffer, "pipeline");
var FixedBuiltStreamingBuffer = _FixedBuiltStreamingBuffer;

// modules/Settings.ts
var distancePerShadowCascade = 95.5;
var _Settings = class _Settings {
  static setRendererConfig(renderConfig) {
    _Settings.renderConfig = renderConfig;
  }
  static get SunPathRotation() {
    return getIntSetting("SunPathRotation");
  }
  static get ShadowsEnabled() {
    return getBoolSetting("ShadowsEnabled");
  }
  static get ShadowSamples() {
    let t = getFloatSetting("ShadowSamples");
    if (t < 0) {
      let softness = getFloatSetting("ShadowSoftness");
      t = -t;
      t = t * Math.floor(8 * Math.pow(softness, 0.87));
      t = Math.max(t, 1);
    }
    return t;
  }
  static get ExposureSamples() {
    let exposureSamplesX = getIntSetting("ExposureSamplesX");
    let exposureSamplesY = Math.floor(exposureSamplesX * (screenHeight / screenWidth));
    return new Vec2(exposureSamplesX, exposureSamplesY);
  }
  static get ShadowCascadeCount() {
    let shadowCascadeCount = getIntSetting("ShadowCascadeCount");
    if (shadowCascadeCount <= 0) {
      shadowCascadeCount = Math.ceil(_Settings.renderConfig.shadow.distance / distancePerShadowCascade);
    }
    return shadowCascadeCount;
  }
  static get PBREnabled() {
    return getBoolSetting("PBR");
  }
  static get PBR() {
    return _Settings.PBREnabled ? getIntSetting("PBRMode") + 1 : 0;
  }
  static get ShadingEnabled() {
    return getBoolSetting("Shading");
  }
  static get AutoExposureEnabled() {
    return getIntSetting("AutoExposure") > 0;
  }
};
__publicField(_Settings, "renderConfig");
var Settings = _Settings;

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

// modules/BlockTag.ts
function autoName(name, internalName) {
  return name ? name : "TAG_" + internalName.toUpperCase();
}
var outputTags = false;
function dumpTags(bool) {
  outputTags = bool;
}
var _Tagger = class _Tagger {
  static setPipeline(pipeline) {
    _Tagger.pipeline = pipeline;
  }
  static tagNamespace(namespace, name) {
    if (this.index >= 32) {
      throw new RangeError(`Tag index is more than 32: ${this.index}`);
    }
    name = autoName(name, namespace.getNamespace());
    if (_Tagger.nameIndexMap[name]) {
      throw new Error(`Duplicate tag: ${name}`);
    }
    if (outputTags) {
      sendInChat(`${this.index} ${name}`);
    }
    addTag(this.index, namespace);
    defineGlobally(name, this.index);
    this.index++;
  }
  static tag(namespace, value, name) {
    name = autoName(name, value ? value : namespace);
    this.tagNamespace(value ? new NamespacedId(namespace, value) : new NamespacedId(namespace), name);
  }
  static tags(name, namespace, ...values) {
    name = autoName(name, namespace);
    let namespaces = [];
    for (let value of values) {
      namespaces.push(new NamespacedId(value));
    }
    this.tagNamespace(createTag(new NamespacedId(namespace), ...namespaces), name);
  }
};
__publicField(_Tagger, "pipeline");
__publicField(_Tagger, "index", 0);
__publicField(_Tagger, "nameIndexMap", []);
var Tagger = _Tagger;
var mc = "minecraft";
var sh = "shader";
var ap = "aperture";

// modules/BlockType.ts
var index = 1;
var namespacedIdData = [];
function addType(type, ...paths) {
  defineGlobally("TYPE_" + type.toUpperCase(), index);
  for (let path of paths) {
    let splits = path.split(":");
    let namespacedId = splits[0] + ":" + splits[1];
    let properties = [];
    for (let part of splits) {
      if (part.includes("=")) {
        let sepIndex = part.indexOf("=");
        let property = part.substring(0, sepIndex);
        let values = part.substring(sepIndex + 1);
        properties[property] = values.split(",");
      }
    }
    namespacedIdData[namespacedId] = { id: index, properties };
  }
  index++;
}
function getType(blockState) {
  let data = namespacedIdData[blockState.getNamespace() + ":" + blockState.getName()];
  if (data !== void 0) {
    let doesNotMatch = false;
    for (let [property, values] of data.properties.entries()) {
      if (blockState.hasState(property)) {
        for (let value in values) {
          doesNotMatch = blockState.getState(property) != value;
        }
      }
    }
    if (!doesNotMatch) {
      return data.id < 4096 ? data.id : 0;
    }
  }
  return 0;
}

// pack.ts
var DEBUG_CONFIG = {
  debug: true,
  outputToChat: true
};
var defaultComposite = "programs/template/composite.vsh";
var debugBuffer;
var settingsBuffer;
var metadataBuffer;
var autoExposureState;
function initSettings(renderConfig) {
  renderConfig.ambientOcclusionLevel = 1;
  renderConfig.mergedHandDepth = true;
  renderConfig.shadow.distance = getIntSetting("ShadowDistance");
  renderConfig.render.stars = true;
  renderConfig.render.horizon = false;
  dumpTags(getBoolSetting("_DumpTags"));
}
function setupSettings(renderConfig) {
  function requestReload(msg) {
    sendInChat(`Request Reload: ${msg}`);
  }
  if (getIntSetting("ShadowCascadeCount") == 0 && renderConfig.shadow.distance != getIntSetting("ShadowDistance")) {
    if (Math.ceil(renderConfig.shadow.distance / distancePerShadowCascade) != Math.ceil(getIntSetting("ShadowDistance") / distancePerShadowCascade)) {
      requestReload("When changing Shadow Distance and Shadow Cascade is Auto.");
    }
  }
  renderConfig.render.stars = getIntSetting("Stars") == 0;
  renderConfig.sunPathRotation = Settings.SunPathRotation;
  renderConfig.shadow.distance = getIntSetting("ShadowDistance");
  dumpSettings(getBoolSetting("_DumpUniforms"));
  const shadowBias = getFloatSetting("ShadowBias") / renderConfig.shadow.resolution;
  let LightSunrise = new Vec4(0.984, 0.702, 0.275, 15e3);
  let LightMorning = new Vec4(0.941, 0.855, 0.7, 6e4);
  let LightNoon = new Vec4(0.92, 0.898, 0.8, 88e3);
  let LightAfternoon = new Vec4(0.9625, 0.807, 0.7, 8e4);
  let LightSunset = new Vec4(0.984, 0.6235, 0.2627, 3e4);
  let LightNightStart = new Vec4(0.1451, 0.14513, 0.2314, 1e4);
  let LightMidnight = new Vec4(0.0588, 0.04706, 0.1412, 5e3);
  let LightNightEnd = new Vec4(0, 0, 0.035, 1e4);
  let LightRain = new Vec4(0.306, 0.408, 0.506, 25e3);
  let AmbientSunrise = new Vec4(0.45, 0.3, 0.2, 29500);
  let AmbientMorning = new Vec4(0.6, 0.6, 0.5, 26e3);
  let AmbientNoon = new Vec4(0.8, 0.8, 0.75, 2e4);
  let AmbientAfternoon = new Vec4(0.7, 0.65, 0.55, 26e3);
  let AmbientSunset = new Vec4(0.47, 0.3, 0.25, 29e3);
  let AmbientNightStart = new Vec4(0.15, 0.15, 0.25, 14e3);
  let AmbientMidnight = new Vec4(0.05, 0.05, 0.18, 8e3);
  let AmbientNightEnd = new Vec4(0.1, 0.1, 0.14, 14e3);
  let AmbientRain = new Vec4(0.3, 0.35, 0.4, 15e3);
  if (debugBuffer) {
    LightSunrise.w *= getFloatSetting("_ShadowLightBrightness");
    LightMorning.w *= getFloatSetting("_ShadowLightBrightness");
    LightNoon.w *= getFloatSetting("_ShadowLightBrightness");
    LightAfternoon.w *= getFloatSetting("_ShadowLightBrightness");
    LightSunset.w *= getFloatSetting("_ShadowLightBrightness");
    LightNightStart.w *= getFloatSetting("_ShadowLightBrightness");
    LightMidnight.w *= getFloatSetting("_ShadowLightBrightness");
    LightNightEnd.w *= getFloatSetting("_ShadowLightBrightness");
    LightRain.w *= getFloatSetting("_ShadowLightBrightness");
    debugBuffer.bool("_DebugEnabled").bool("_DebugStats").bool("_SliceScreen").int("_ShowDepth").int("_ShowRoughness").int("_ShowReflectance").int("_ShowPorosity").int("_ShowEmission").int("_ShowNormals").int("_ShowAmbientOcclusion").int("_ShowHeight").int("_ShowShadowMap").int("_ShowGeometryNormals").int("_ShowLightLevel").bool("_ShowShadows").bool("_ShowShadowCascades").int("_ShadowCascadeIndex").float("_DebugUIScale").bool("_DisplayAtmospheric").bool("_DisplaySunlightColors").bool("_DisplayCameraData").end();
  }
  settingsBuffer.float(0, "Rain").float(0, "Wetness").vec4(...LightSunrise.xyzw(), "LightSunrise").vec4(...LightMorning.xyzw(), "LightMorning").vec4(...LightNoon.xyzw(), "LightNoon").vec4(...LightAfternoon.xyzw(), "LightAfternoon").vec4(...LightSunset.xyzw(), "LightSunset").vec4(...LightNightStart.xyzw(), "LightNightStart").vec4(...LightMidnight.xyzw(), "LightMidnight").vec4(...LightNightEnd.xyzw(), "LightNightEnd").vec4(...LightRain.xyzw(), "LightRain").vec4(...AmbientSunrise.xyzw(), "AmbientSunrise").vec4(...AmbientMorning.xyzw(), "AmbientMorning").vec4(...AmbientNoon.xyzw(), "AmbientNoon").vec4(...AmbientAfternoon.xyzw(), "AmbientAfternoon").vec4(...AmbientSunset.xyzw(), "AmbientSunset").vec4(...AmbientNightStart.xyzw(), "AmbientNightStart").vec4(...AmbientMidnight.xyzw(), "AmbientMidnight").vec4(...AmbientNightEnd.xyzw(), "AmbientNightEnd").vec4(...AmbientRain.xyzw(), "AmbientRain").int(renderConfig.shadow.cascades, "ShadowCascadeCount").int(Settings.ShadowSamples, "ShadowSamples").int("ShadowFilter").float("ShadowDistort").float("ShadowSoftness").float(shadowBias, "Initial ShadowBias").float("ShadowThreshold").int(getPixelizationOverride("ShadingPixelization"), "ShadingPixelization").int(getPixelizationOverride("ShadowPixelization"), "ShadowPixelization").int(Settings.PBR, "PBR").int("Specular").float("NormalStrength").int("AutoExposure").float(Math.exp(getFloatSetting("ExposureMult")), "ExposureMult").float("ExposureSpeed").int("Tonemap").bool("CompareTonemaps").ivec4(getIntSetting("Tonemap1"), getIntSetting("Tonemap2"), getIntSetting("Tonemap3"), getIntSetting("Tonemap4")).int("Sky").int("Stars").float("StarAmount").bool("DisableMoonHalo").bool("IsolateCelestials").end();
}
function setupTags() {
}
function setupTypes() {
  addType("water", "minecraft:water", "minecraft:flowing_water");
}
function setup(pipeline) {
  let renderConfig = pipeline.getRendererConfig();
  Settings.setRendererConfig(renderConfig);
  Tagger.setPipeline(pipeline);
  FixedBuiltStreamingBuffer.setPipeline(pipeline);
  defineGlobally("SCENE_FORMAT", "r11f_g11f_b10f");
  let sceneTexture = pipeline.createImageTexture("sceneTex", "sceneImg").format(Format.R11F_G11F_B10F).mipmap(true).build();
  defineGlobally("DATA0_FORMAT", "r32ui");
  let dataTexture0 = pipeline.createImageTexture("dataTex0", "dataImg0").format(Format.R32UI).build();
  let gbufferTexture;
  if (Settings.PBREnabled) {
    let _gbufferTexture = pipeline.createImageTexture("gbufferTex", "gbufferImg");
    if (Settings.PBR == 1) {
      defineGlobally("GBUFFER_FORMAT", "r32ui");
      _gbufferTexture.format(Format.R32UI);
    } else if (Settings.PBR == 2) {
      defineGlobally("GBUFFER_FORMAT", "rg32ui");
      _gbufferTexture.format(Format.RG32UI);
    }
    gbufferTexture = _gbufferTexture.build();
  }
  autoExposureState = new StateReference();
  function define(shader, name, defineName) {
    if (getBoolSetting(name)) {
      shader.define(defineName != null ? defineName : name, "");
    }
    return shader;
  }
  function lightingDefines(shader) {
    define(shader, "ShadowsEnabled");
    define(shader, "PBR", "PBREnabled");
    return shader;
  }
  function terrainProgram(usage, name, programName) {
    let program = pipeline.createObjectShader(programName || name, usage);
    lightingDefines(program);
    bindSettings(program).vertex(`programs/geometry/${name}.vsh`).fragment(`programs/geometry/${name}.fsh`).target(0, sceneTexture).target(2, dataTexture0);
    if (gbufferTexture) {
      program.target(1, gbufferTexture).blendOff(1);
    }
    return program;
  }
  function bindMetadata(program) {
    return program.define("INCLUDE_METADATA", "").ssbo(0, metadataBuffer);
  }
  function bindSettings(program) {
    return bindMetadata(program).define("INCLUDE_SETTINGS", "").ubo(0, settingsBuffer.buffer);
  }
  function setupResources() {
    debugBuffer = getBoolSetting("_DebugEnabled") ? new FixedStreamingBuffer().bool().bool().bool().int().int().int().int().int().int().int().int().int().int().int().bool().bool().int().float().bool().bool().bool().build() : null;
    settingsBuffer = new FixedStreamingBuffer().float().float().vec4().vec4().vec4().vec4().vec4().vec4().vec4().vec4().vec4().vec4().vec4().vec4().vec4().vec4().vec4().vec4().vec4().vec4().int().int().int().float().float().float().float().int().int().int().int().float().int().float().float().int().bool().ivec4().int().int().float().bool().bool().build();
    metadataBuffer = pipeline.createBuffer(72, false);
  }
  function setupPrograms() {
    const init = pipeline.forStage(Stage.PRE_RENDER);
    bindMetadata(bindSettings(
      init.createCompute("init_settings").location("programs/pre_render/settings.csh").workGroups(1, 1, 1)
    )).compile();
    init.barrier(SSBO_BIT);
    bindSettings(
      init.createComposite("clear_textures").vertex(defaultComposite).fragment("programs/pre_render/clear_textures.fsh").target(0, sceneTexture)
    ).compile();
    init.end();
    terrainProgram(Usage.TERRAIN_SOLID, "geometry_main", "terrain_solid").blendOff(0).compile();
    terrainProgram(Usage.TERRAIN_CUTOUT, "geometry_main", "terrain_cutout").blendOff(0).define("CUTOUT", "").compile();
    terrainProgram(Usage.TERRAIN_TRANSLUCENT, "geometry_main", "terrain_translucent").define("FORWARD", "").compile();
    bindSettings(
      pipeline.createObjectShader("sky_textured", Usage.SKY_TEXTURES).vertex("programs/geometry/sky_textured.vsh").fragment("programs/geometry/sky_textured.fsh").target(0, sceneTexture).blendFunc(0, Func.ONE, Func.ONE, Func.ONE, Func.ONE)
    ).compile();
    bindSettings(
      pipeline.createObjectShader("sky_basic", Usage.SKYBOX).vertex("programs/geometry/sky_basic.vsh").fragment("programs/geometry/sky_basic.fsh").target(0, sceneTexture)
    ).compile();
    const preTranslucent = pipeline.forStage(Stage.PRE_TRANSLUCENT);
    lightingDefines(bindSettings(
      preTranslucent.createCompute("shade").location("programs/post_opaque/shade.csh").workGroups(Math.ceil(screenWidth / 32), Math.ceil(screenHeight / 8), 1)
    )).compile();
    preTranslucent.end();
    if (Settings.ShadowsEnabled) {
      bindSettings(
        pipeline.createObjectShader("shadow", Usage.SHADOW).vertex(`programs/geometry/shadow.vsh`).fragment(`programs/geometry/shadow.fsh`)
      ).compile();
      bindSettings(
        pipeline.createObjectShader("shadow", Usage.SHADOW_TERRAIN_CUTOUT).vertex(`programs/geometry/shadow.vsh`).fragment(`programs/geometry/shadow.fsh`).define("CUTOUT", "")
      ).compile();
      bindSettings(
        pipeline.createObjectShader("shadow", Usage.SHADOW_ENTITY_CUTOUT).vertex(`programs/geometry/shadow.vsh`).fragment(`programs/geometry/shadow.fsh`).define("CUTOUT", "")
      ).compile();
    }
    const postRender = pipeline.forStage(Stage.POST_RENDER);
    if (Settings.AutoExposureEnabled) {
      postRender.generateMips(sceneTexture);
      bindMetadata(bindSettings(
        postRender.createCompute("auto_exposure").state(autoExposureState).location("programs/post_render/auto_exposure.csh").workGroups(1, 1, 1).define("ExposureSamplesX", Settings.ExposureSamples.x.toString()).define("ExposureSamplesY", Settings.ExposureSamples.y.toString())
      )).compile();
    }
    if (debugBuffer) {
      bindMetadata(lightingDefines(bindSettings(
        postRender.createCompute("debug").location("programs/post_render/debug.csh").workGroups(Math.ceil(screenWidth / 16), Math.ceil(screenHeight / 16), 1).ubo(1, debugBuffer.buffer)
      ))).compile();
    }
    postRender.end();
    bindMetadata(bindSettings(pipeline.createCombinationPass("programs/finalize/final.fsh"))).compile();
  }
  setupTags();
  setupTypes();
  setupResources();
  setupPrograms();
  setupSettings(renderConfig);
}
function configureRenderer(renderConfig) {
  Settings.setRendererConfig(renderConfig);
  initSettings(renderConfig);
  if (Settings.ShadowsEnabled) {
    renderConfig.shadow.resolution = getIntSetting("ShadowResolution") / Settings.ShadowCascadeCount;
    renderConfig.shadow.cascades = Settings.ShadowCascadeCount;
    renderConfig.shadow.enabled = true;
  }
}
function configurePipeline(pipeline) {
  setup(pipeline);
}
function onSettingsChanged(state) {
  setupSettings(state.rendererConfig());
}
function getBlockId(block) {
  return getType(block);
}
function beginFrame(state) {
  autoExposureState.setEnabled(Settings.AutoExposureEnabled);
  settingsBuffer.uploadData();
  if (debugBuffer) {
    debugBuffer.uploadData();
    if (KeyInput.onKeyDown(Keys.E)) {
      toggleBoolSetting("_DebugEnabled");
      if (getBoolSetting("_DebugEnabled")) {
        sendInChat("Debug mode enabled, may need reload to work");
      }
    }
    if (KeyInput.onKeyDown(Keys.F)) {
      setIntSetting("PBRMode", getIntSetting("PBRMode") == 0 ? 1 : 0);
      if (getIntSetting("PBRMode") == 0) {
        sendInChat("Reduced PBR");
      } else if (getIntSetting("PBRMode") == 1) {
        sendInChat("Full PBR");
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
}
function getPixelizationOverride(name) {
  const basePixelization = getIntSetting("Pixelization");
  const pixelization = getFloatSetting(name);
  return Math.floor(pixelization < 0 ? -pixelization * basePixelization : pixelization);
}
export {
  beginFrame,
  configurePipeline,
  configureRenderer,
  getBlockId,
  onSettingsChanged
};
//# sourceMappingURL=pack.js.map
