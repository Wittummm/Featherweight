export class Vec3 {
  x: number;
  y: number;
  z: number;

  static zero = new Vec3(0);
  static one = new Vec3(1);

  constructor(x: Vector3f);
  constructor(x: number);
  constructor(x: number, y: number, z: number);
  constructor(x: number | Vector3f, y?: number, z?: number) {
    if (typeof x === "number") {
      this.x = x; this.y = x; this.z = x;
    } else if (x instanceof Vector3f) {
      this.x = x.x(); this.y = x.y(); this.z = x.z();
    } else {
      this.x = x; this.y = y!; this.z = z!;
    }
  }

  xyz(): [number, number, number] {return [this.x, this.y, this.z];}
  clone(): Vec3 { return new Vec3(...this.xyz()); }
  toVector3f(): Vector3f {return new Vector3f(...this.xyz());}

  negate(): this { this.x = -this.x; this.y = -this.y; this.z = -this.z; return this; }

  add(x: number, y: number, z: number): this;
  add(other: Vec3): this;
  add(x: number | Vec3, y?: number, z?: number): this { return typeof x === "number" ? this.#add(x, y!, z!) : this.#add(x.x, x.y, x.z); }

  sub(x: number, y: number, z: number): this;
  sub(other: Vec3): this;
  sub(x: number | Vec3, y?: number, z?: number): this { return typeof x === "number" ? this.#sub(x, y!, z!) : this.#sub(x.x, x.y, x.z); }

  mul(x: number, y: number, z: number): this;
  mul(other: Vec3): this;
  mul(x: number | Vec3, y?: number, z?: number): this { return typeof x === "number" ? this.#mul(x, y!, z!) : this.#mul(x.x, x.y, x.z); }
  scale(v: number): this { return this.#mul(v,v,v); }

  div(x: number, y: number, z: number): this;
  div(other: Vec3): this;
  div(x: number | Vec3, y?: number, z?: number): this { return typeof x === "number" ? this.#div(x, y!, z!) : this.#div(x.x, x.y, x.z); }

  #add(x: number, y: number, z: number): this { this.x += x; this.y += y; this.z += z; return this; }
  #sub(x: number, y: number, z: number): this { this.x -= x; this.y -= y; this.z -= z; return this; }
  #mul(x: number, y: number, z: number): this { this.x *= x; this.y *= y; this.z *= z; return this; }
  #div(x: number, y: number, z: number): this { this.x /= x; this.y /= y; this.z /= z; return this; }

  floor(): this {this.x = Math.floor(this.x); this.y = Math.floor(this.y); this.z = Math.floor(this.z); return this;}
  ceil(): this {this.x = Math.ceil(this.x); this.y = Math.ceil(this.y); this.z = Math.ceil(this.z); return this;}
  abs(): this {this.x = Math.abs(this.x); this.y = Math.abs(this.y); this.z = Math.abs(this.z); return this;}
  sign(): this {this.x = Math.sign(this.x); this.y = Math.sign(this.y); this.z = Math.sign(this.z); return this;}
  min(min: Vec3): this {this.x = Math.min(this.x, min.x); this.y = Math.min(this.y, min.y); this.z = Math.min(this.z, min.z); return this;}
  max(max: Vec3): this {this.x = Math.max(this.x, max.x); this.y = Math.max(this.y, max.y); this.z = Math.max(this.z, max.z); return this;}
  clamp(min: Vec3, max: Vec3): this {this.min(max); this.max(min); return this;}

  lengthSquared(): number { return this.x * this.x + this.y * this.y + this.z * this.z; }
  length(): number { return Math.sqrt(this.lengthSquared()); }

  normalize(): this {
    const len = this.length();
    if (len > 0) {
      return this.scale(1 / len);
    }
    return this;
  }
  cross(other: Vec3): Vec3 {
    return new Vec3(
      this.y * other.z - this.z * other.y,
      this.z * other.x - this.x * other.z,
      this.x * other.y - this.y * other.x
    );
  }
  dot(other: Vec3): number { return this.x * other.x + this.y * other.y + this.z * other.z; }
  distanceTo(other: Vec3): number {return this.clone().sub(other).length();}

  get volume(): number { return this.x * this.y * this.z; }
}