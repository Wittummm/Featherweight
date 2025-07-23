import { getType } from './modules/BlockType';
import configRenderer from './modules/pipeline/configRenderer';
import configPipeline from './modules/pipeline/configPipeline';
import configSettings from './modules/pipeline/configSettings';
import configFrame from './modules/pipeline/configFrame';
///////////////////////////////////////

let textures, buffers, states;

// Runs once on shader setup
export function configureRenderer(renderConfig: RendererConfig) {
    configRenderer(renderConfig);
}
// Runs after `configureRenderer` on shader setup
export function configurePipeline(pipeline: PipelineConfig) {
    ({ textures, buffers, states } = configPipeline(pipeline));
}

export function beginFrame(state: WorldState) {
    configFrame(textures, buffers, states);
}
export function onSettingsChanged(state: WorldState) {
    configSettings(state.rendererConfig(), textures, buffers, states);
}

export function getBlockId(block: BlockState): number {
    // This runs in runtime when block changes, so it should be optimized
    return getType(block);
}