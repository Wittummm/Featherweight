export class Vec4 {
  x: number;
  y: number;
  z: number;
  w: number;

  static zero = new Vec4(0);
  static one = new Vec4(1);

  constructor(x: Vector4f);
  constructor(x: number);
  constructor(x: number, y: number, z: number, w: number);
  constructor(x: number | Vector4f, y?: number, z?: number, w?: number) {
    if (typeof x === "number" && typeof y !== "number") {
      this.x = x; this.y = x; this.z = x; this.w = x;
    } else if (x instanceof Vector4f) {
      this.x = x.x(); this.y = x.y(); this.z = x.z(); this.w = x.w();
    } else {
      this.x = x; this.y = y!; this.z = z!; this.w = w!;
    }
  }

  xyzw(): [number, number, number, number] {return [this.x, this.y, this.z, this.w];}
  clone(): this { return new (this.constructor(...this.xyzw())); }
  toVector4f(): Vector4f {return new Vector4f(...this.xyzw());}

  negate(): this { this.x = -this.x; this.y = -this.y; this.z = -this.z; this.w = -this.w; return this; }

  add(x: number, y: number, z: number, w: number): this;
  add(other: Vec4): this;
  add(x: number | Vec4, y?: number, z?: number, w?: number): this { return typeof x === "number" ? this.#add(x, y!, z!, w!) : this.#add(x.x, x.y, x.z, x.w); }

  sub(x: number, y: number, z: number, w: number): this;
  sub(other: Vec4): this;
  sub(x: number | Vec4, y?: number, z?: number, w?: number): this { return typeof x === "number" ? this.#sub(x, y!, z!, w!) : this.#sub(x.x, x.y, x.z, x.w); }

  mul(x: number, y: number, z: number, w: number): this;
  mul(other: Vec4): this;
  mul(x: number | Vec4, y?: number, z?: number, w?: number): this { return typeof x === "number" ? this.#mul(x, y!, z!, w!) : this.#mul(x.x, x.y, x.z, x.w); }
  scale(v: number): this { return this.#mul(v,v,v,v); }

  div(x: number, y: number, z: number, w: number): this;
  div(other: Vec4): this;
  div(x: number | Vec4, y?: number, z?: number, w?: number): this { return typeof x === "number" ? this.#div(x, y!, z!, w!) : this.#div(x.x, x.y, x.z, x.w); }

  #add(x: number, y: number, z: number, w: number): this { this.x += x; this.y += y; this.z += z; this.w += w; return this; }
  #sub(x: number, y: number, z: number, w: number): this { this.x -= x; this.y -= y; this.z -= z; this.w -= w; return this; }
  #mul(x: number, y: number, z: number, w: number): this { this.x *= x; this.y *= y; this.z *= z; this.w *= w; return this; }
  #div(x: number, y: number, z: number, w: number): this { this.x /= x; this.y /= y; this.z /= z; this.w /= w; return this; }

  floor(): this {this.x = Math.floor(this.x); this.y = Math.floor(this.y); this.z = Math.floor(this.z); this.w = Math.floor(this.w); return this;}
  ceil(): this {this.x = Math.ceil(this.x); this.y = Math.ceil(this.y); this.z = Math.ceil(this.z); this.w = Math.ceil(this.w); return this;}
  abs(): this {this.x = Math.abs(this.x); this.y = Math.abs(this.y); this.z = Math.abs(this.z); this.w = Math.abs(this.w); return this;}
  sign(): this {this.x = Math.sign(this.x); this.y = Math.sign(this.y); this.z = Math.sign(this.z); this.w = Math.sign(this.w); return this;}
  min(min: Vec4): this {this.x = Math.min(this.x, min.x); this.y = Math.min(this.y, min.y); this.z = Math.min(this.z, min.z); this.w = Math.min(this.w, min.w); return this;}
  max(max: Vec4): this {this.x = Math.max(this.x, max.x); this.y = Math.max(this.y, max.y); this.z = Math.max(this.z, max.z); this.w = Math.max(this.w, max.w); return this;}
  clamp(min: Vec4, max: Vec4): this {this.min(max); this.max(min); return this;}

  lengthSquared(): number { return this.x * this.x + this.y * this.y + this.z * this.z + this.w * this.w; }
  length(): number { return Math.sqrt(this.lengthSquared()); }

  normalize(): this {
    const len = this.length();
    if (len > 0) {
      return this.scale(1 / len);
    }
    return this;
  }
  dot(other: Vec4): number { return this.x * other.x + this.y * other.y + this.z * other.z + this.w * other.w; }
  distanceTo(other: Vec4): number {return this.clone().sub(other).length();}
}