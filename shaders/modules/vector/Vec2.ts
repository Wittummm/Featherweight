export class Vec2 {
  x: number;
  y: number;

  static zero = new Vec2(0);
  static one = new Vec2(1);

  constructor(x: Vector2f);
  constructor(x: number);
  constructor(x: number, y: number);
  constructor(x: number | Vector2f, y?: number) {
    if (typeof x === "number") {
      this.x = x; this.y = x;
    } else if (x instanceof Vector2f) {
      this.x = x.x(); this.y = x.y();
    } else {
      this.x = x; this.y = y!;
    }
  }

  xy(): [number, number] {return [this.x, this.y];}
  clone(): this { return new (this.constructor(...this.xy())); }
  toVector2f(): Vector2f {return new Vector2f(...this.xy());}

  negate(): this { this.x = -this.x; this.y = -this.y; return this; }

  add(x: number, y: number): this;
  add(other: Vec2): this;
  add(x: number | Vec2, y?: number): this { return typeof x === "number" ? this.#add(x, y!) : this.#add(x.x, x.y); }

  sub(x: number, y: number): this;
  sub(other: Vec2): this;
  sub(x: number | Vec2, y?: number): this { return typeof x === "number" ? this.#sub(x, y!) : this.#sub(x.x, x.y); }

  mul(x: number, y: number): this;
  mul(other: Vec2): this;
  mul(x: number | Vec2, y?: number): this { return typeof x === "number" ? this.#mul(x, y!) : this.#mul(x.x, x.y); }
  scale(v: number): this { return this.#mul(v,v); }

  div(x: number, y: number): this;
  div(other: Vec2): this;
  div(x: number | Vec2, y?: number): this { return typeof x === "number" ? this.#div(x, y!) : this.#div(x.x, x.y); }

  #add(x: number, y: number): this { this.x += x; this.y += y; return this; }
  #sub(x: number, y: number): this { this.x -= x; this.y -= y; return this; }
  #mul(x: number, y: number): this { this.x *= x; this.y *= y; return this; }
  #div(x: number, y: number): this { this.x /= x; this.y /= y; return this; }

  floor(): this {this.x = Math.floor(this.x); this.y = Math.floor(this.y); return this;}
  ceil(): this {this.x = Math.ceil(this.x); this.y = Math.ceil(this.y); return this;}
  abs(): this {this.x = Math.abs(this.x); this.y = Math.abs(this.y); return this;}
  sign(): this {this.x = Math.sign(this.x); this.y = Math.sign(this.y); return this;}
  min(min: Vec2): this {this.x = Math.min(this.x, min.x); this.y = Math.min(this.y, min.y); return this;}
  max(max: Vec2): this {this.x = Math.max(this.x, max.x); this.y = Math.max(this.y, max.y); return this;}
  clamp(min: Vec2, max: Vec2): this {this.min(max); this.max(min); return this;}

  lengthSquared(): number { return this.x * this.x + this.y * this.y; }
  length(): number { return Math.sqrt(this.lengthSquared()); }

  normalize(): this {
    const len = this.length();
    if (len > 0) {
      return this.scale(1 / len);
    }
    return this;
  }
  dot(other: Vec2): number { return this.x * other.x + this.y * other.y; }
  distanceTo(other: Vec2): number {return this.clone().sub(other).length();}
}