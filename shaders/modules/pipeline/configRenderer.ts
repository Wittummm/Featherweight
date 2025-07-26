import { dumpTags } from "../BlockTag";
import { Settings } from "../Settings";

export default function configRenderer(renderConfig: RendererConfig) { // Initialized once on shader setup
    Settings.setRendererConfig(renderConfig);
    
    renderConfig.ambientOcclusionLevel = 1.0;
    renderConfig.mergedHandDepth = true; 
    renderConfig.shadow.distance = getIntSetting("ShadowDistance");
    renderConfig.render.stars = true;
    renderConfig.render.horizon = false;
    renderConfig.render.clouds = false;

    if (Settings.ShadowsEnabled) {
        renderConfig.shadow.resolution = getIntSetting("ShadowResolution")/Settings.ShadowCascadeCount;
        renderConfig.shadow.cascades = Settings.ShadowCascadeCount;
        renderConfig.shadow.enabled = true;
    }

    dumpTags(getBoolSetting("_DumpTags"));
    
}