import { FixedStreamingBuffer } from "../../FixedStreamingBuffer";

export default function createBuffers(pipeline: PipelineConfig) {
    let debugBuffer = getBoolSetting("_DebugEnabled") ? new FixedStreamingBuffer().bool().bool().bool().int().int().int().int().int().int().int().int().int().int().int().bool().bool().int().float().bool().bool().bool().build() : null;
    let settingsBuffer = new FixedStreamingBuffer().float().float() .vec4().vec4().vec4().vec4().vec4().vec4().vec4().vec4().vec4().vec4().vec4().vec4().vec4().vec4().vec4().vec4().vec4().vec4() .int().int().int().float().float().float().float() .int().int() .int().int().float() .int().float().float().int().bool().ivec4() .int().int().float().bool().bool().build();
    let metadataBuffer = pipeline.createBuffer(72, false);
    
    return {
        ["debug"]: debugBuffer,
        ["settings"]: settingsBuffer,
        ["metadata"]: metadataBuffer,
    };
}