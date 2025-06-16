// Fixed layout buffer

export class FixedStreamingBuffer {
    private byteSize: number = 0;

    int(): FixedStreamingBuffer {this.byteSize += 4; return this;}
    float(): FixedStreamingBuffer {this.byteSize += 4; return this;}
    bool(): FixedStreamingBuffer {this.byteSize += 4; return this;}

    vec4(): FixedStreamingBuffer {this.byteSize += 4*4; return this;}
    vec3(): FixedStreamingBuffer {return this.vec4();}
    vec2(): FixedStreamingBuffer {this.byteSize += 4*2; return this;}

    build() { return new FixedBuiltStreamingBuffer(this.byteSize);}
}

export class FixedBuiltStreamingBuffer {
    constructor(byteSize: number) {
        this.b = new StreamingBuffer(byteSize).build();
        this.size = byteSize;
    }
    private size: number
    private b: BuiltStreamingBuffer;
    private offset: number = 0;
    get buffer() {return this.b;}

    get byteOffset(): number {
        return this.offset;
    }
    end(): void {this.offset = 0;}
    uploadData(): void {this.b.uploadData();}
 
    int(value: number | string) {
        if (this.offset + 4 > this.size) throw new Error(`Cannot add value beyond FixedBuiltStreamingBuffer's size, ${this.offset + 4} > ${this.size}`);
        value = typeof value == "string" ? getIntSetting(value) : value;
        this.b.setInt(this.offset, value);
        this.offset += 4;
        return this;
    }
    float(value: number | string) {
        if (this.offset + 4 > this.size) throw new Error(`Cannot add value beyond FixedBuiltStreamingBuffer's size, ${this.offset + 4} > ${this.size}`);
        value = typeof value == "string" ? getFloatSetting(value) : value;
        this.b.setFloat(this.offset, value);
        this.offset += 4;
        return this;
    }
    bool(value: boolean | string) {
        if (this.offset + 4 > this.size) throw new Error(`Cannot add value beyond FixedBuiltStreamingBuffer's size, ${this.offset + 4} > ${this.size}`);
        value = typeof value == "string" ? getBoolSetting(value) : value;
        this.b.setBool(this.offset, value);
        this.offset += 4;
        return this;
    }

    vec4(x: number, y: number, z: number, w: number) {
        this.float(x); this.float(y); 
        this.float(z); this.float(w);
        return this;
    }
    vec3(x: number, y: number, z: number) {
        this.vec4(x, y, z, 0);
        return this;
    }
    vec2(x: number, y: number) {
        this.float(x); this.float(y); 
        return this;
    }
}