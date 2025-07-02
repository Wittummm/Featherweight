// Fixed layout buffer

let outputSettingValues = true;

export function setOutputSettingValues(bool: boolean) {
    outputSettingValues = bool;
}

function output(display?: string, value?: any) {
    if (display && outputSettingValues) {sendInChat(display + `: ${value}`);}
}

function _getIntSetting(name : string) {
    output(name, getIntSetting(name));
    return getIntSetting(name);
}
function _getFloatSetting(name : string) {
    output(name, Math.round(getFloatSetting(name)*100)*0.01);
    return getFloatSetting(name);
}
function _getBoolSetting(name : string) {
    output(name, getBoolSetting(name));
    return getBoolSetting(name);
}
function _getStringSetting(name : string) {
    output(name, getStringSetting(name));
    return getStringSetting(name);
}
export class FixedStreamingBuffer {
    private offset: number = 0;
    private align(alignment: number) { this.offset = Math.ceil(this.offset/alignment)*alignment; }

    int(_?: any): FixedStreamingBuffer {this.align(4); this.offset += 4; return this;}
    float(_?: any): FixedStreamingBuffer {this.align(4); this.offset += 4; return this;}
    bool(_?: any): FixedStreamingBuffer {this.align(4); this.offset += 4; return this;}

    vec4(_?: any): FixedStreamingBuffer {this.align(16); this.offset += 4*4; return this;}
    vec3(_?: any): FixedStreamingBuffer {return this.vec4();}
    vec2(_?: any): FixedStreamingBuffer {this.align(8); this.offset += 4*2; return this;}

    build() { return new FixedBuiltStreamingBuffer(this.offset);}
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
    private align(alignment: number) { this.offset = Math.ceil(this.offset/alignment)*alignment; }

    end(): void {this.offset = 0;}
    uploadData(): void {this.b.uploadData();}
 
    int(value: number | string, display?: string) {
        if (this.offset + 4 > this.size) throw new Error(`Cannot add value beyond FixedBuiltStreamingBuffer's size, ${this.offset + 4} > ${this.size}`);
        value = typeof value == "string" ? _getIntSetting(value) : value;
        output(display, value);

        this.align(4);
        this.b.setInt(this.offset, value);
        this.offset += 4;
        return this;
    }
    float(value: number | string, display?: string) {
        if (this.offset + 4 > this.size) throw new Error(`Cannot add value beyond FixedBuiltStreamingBuffer's size, ${this.offset + 4} > ${this.size}`);
        value = typeof value == "string" ? _getFloatSetting(value) : value;
        output(display, value);

        this.align(4);
        this.b.setFloat(this.offset, value);
        this.offset += 4;
        return this;
    }
    bool(value: boolean | string, display?: string) {
        if (this.offset + 4 > this.size) throw new Error(`Cannot add value beyond FixedBuiltStreamingBuffer's size, ${this.offset + 4} > ${this.size}`);
        value = typeof value == "string" ? _getBoolSetting(value) : value;
        output(display, value);

        this.align(4);
        this.b.setBool(this.offset, value);
        this.offset += 4;
        return this;
    }

    vec4(x: number, y: number, z: number, w: number, display?: string) {
        output(display, `(${x}, ${y}, ${z}, ${w})`);

        this.align(16);
        this.float(x); this.float(y); 
        this.float(z); this.float(w);
        return this;
    }
    vec3(x: number, y: number, z: number, display?: string) {
        this.vec4(x, y, z, 0, display);
        return this;
    }
    vec2(x: number, y: number, display?: string) {
        output(display, `(${x}, ${y})`);

        this.float(x); this.float(y); 
        return this;
    }

    ivec4(x: number, y: number, z: number, w: number) {
        this.align(16);
        this.int(x); this.int(y); 
        this.int(z); this.int(w);
        return this;
    }
    ivec3(x: number, y: number, z: number) {
        this.ivec4(x, y, z, 0);
        return this;
    }
    ivec2(x: number, y: number) {
        this.int(x); this.int(y); 
        return this;
    }
}