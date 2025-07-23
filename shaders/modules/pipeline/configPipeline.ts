import { dumpTags, Tagger } from "../BlockTag";
import { FixedBuiltStreamingBuffer } from "../FixedStreamingBuffer";
import { Settings } from "../Settings";
import createPrograms from "./programs";
import createObjects from "./resources/objects";
import configSettings from "./configSettings";
import createTags from "./tags";
import createTypes from "./types";

export default function configPipeline(pipeline: PipelineConfig) { // Initialized once on shader setup
    let renderConfig = pipeline.getRendererConfig();
    Settings.setRendererConfig(renderConfig);
    Tagger.setPipeline(pipeline);
    FixedBuiltStreamingBuffer.setPipeline(pipeline);
    
    createTags(pipeline);
    createTypes();
    const objects = createObjects(pipeline);
    const { textures, buffers, states } = objects;
    createPrograms(pipeline, textures, buffers, states);
    configSettings(renderConfig, textures, buffers, states);

    return objects;
}