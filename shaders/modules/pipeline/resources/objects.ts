// Any misc objects that doesnt deserve its own file

import createBuffers from "./buffers";
import createTextures from "./textures";

function createStates(pipeline: PipelineConfig) {
    return {
        ["autoExposure"]: new StateReference(),
        ["sunrays"]: new StateReference(),
        ["debug"]: new StateReference(),
    };
}

export default function createObjects(pipeline: PipelineConfig) {
    return {
        ["states"]: createStates(pipeline),
        ["buffers"]: createBuffers(pipeline),
        ["textures"]: createTextures(pipeline),
    }
}

export type Textures = ReturnType<typeof createObjects>["textures"];
export type Buffers = ReturnType<typeof createObjects>["buffers"];
export type States = ReturnType<typeof createObjects>["states"];