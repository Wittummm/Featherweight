import { Settings } from "../../Settings";

export default function createTextures(pipeline: PipelineConfig) {
    defineGlobally("SCENE_FORMAT", "r11f_g11f_b10f");
    let sceneTexture = pipeline.createImageTexture("sceneTex", "sceneImg").format(Format.R11F_G11F_B10F).mipmap(true).build();

    defineGlobally("DATA0_FORMAT", "r32ui");
    let dataTexture0 = pipeline.createImageTexture("dataTex0", "dataImg0").format(Format.R32UI).build();

    let gbufferTexture: BuiltTexture|null
    if (Settings.PBREnabled) {
        let _gbufferTexture = pipeline.createImageTexture("gbufferTex", "gbufferImg");

        if (Settings.PBR == 1) {
            defineGlobally("GBUFFER_FORMAT", "r32ui"); _gbufferTexture.format(Format.R32UI);
        } else if (Settings.PBR == 2) {
            defineGlobally("GBUFFER_FORMAT", "rg32ui"); _gbufferTexture.format(Format.RG32UI);
        }

        gbufferTexture = _gbufferTexture.build();
    }

    return {
        ["scene"]: sceneTexture,
        ["data0"]: dataTexture0,
        ["gbuffer"]: gbufferTexture,
    };
}

