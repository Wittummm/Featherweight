const shouldReload = true; // Works without needing to reload, but reloading is idle (default: true)

/*
Syntax notes:
- PascalCase for the setting names
- "Enabled" suffix for toggles
- "_Show" prefix for showing textures
- "_Display" prefix for displaying anything usu. non 2d
- "X_" where `X` is the type ie `Page_Shadow` for page, option values/settings do not have this only things like pages etc 
*/
function toneMapPicker(name: string, def?: number) {
    return asIntRange(name, def ?? 2, 0, 5, 1, false).name()
    .values("NONE", "Reinhard+", "AgX", "Heij", "Unreal", "Lottes")
    .desc("[NONE] is no tonemapping, not recommended.");
}
function texIsolate(name: string) {
    return asInt(name,-1,0,1,2,3,4)
    .values("Off","Full","Top Left","Top Right","Bottom Left","Bottom Right")
    .name(name.replace("_Show","Show "))
    .needsReload(false).build(-1)
}
function texIsolates(...names: string[]) {
    let objs = [];
    for (const name of names) {
        objs.push(texIsolate(name));
    }
    return objs;
}

export function setupOptions() {
    const shadowPixelization = asPixelizationOverride("ShadowPixelization").name();
    const shadingPixelization = asPixelizationOverride("ShadingPixelization").name();

    const general = new Page("Page_General").name()
    .add(asIntRange("SunPathRotation", 0, -120, 120, 1, false).name())
    .add(new Page("Page_Pixelization").name()
        .add(asInt("Pixelization", 0, 8, 16, 32, 64, 128, 256)
            .needsReload(false).build(16)
            .values("Off")
        )
        .add(shadowPixelization)
        .add(shadingPixelization)
        .build()
    )
    .build();

    const shadow = new Page("Page_Shadows").name()
    .add(asBool("ShadowsEnabled", true, true).name())
    .add(asInt("ShadowResolution", 128, 256, 512, 768, 1024, 1536, 2048, 2560, 3072, 4096, 6144, 8192, 12288, 16384)
        .needsReload(true).build(768)
        .name()
    )
    .add(asInt("ShadowDistance", 16, 32, 48, 64, 80, 96, 128, 160, 192, 240, 288, 352, 400, 448, 512, 640, 768, 896, 1024, 1280, 1536, 1792, 2048).needsReload(false).build(64).name()) // CODE: sadi1n PIN: This only needs to reload if `ShadowCascadeCount` is `Auto`, else it can be updated in real time
    .add(asInt("ShadowFilter", 0, 1, 2)
        .needsReload(false).build(1)
        .name()
        .values("Nearest", "Linear", "Uniform Soft")
    )
    // Soft shadows
    .add(putTextLabel("LabelSoftShadows","Soft Shadows"))
    .add(asFloat("ShadowSamples", -2, -1.75, -1.5, -1.25, -1, -0.75, 2,3,5,7,9,12,15,20,25,30,35,40,48,54,60,70,80,90,100,110,120,130)
        .needsReload(false).build(-1)
        .name()
    )
    .add(asFloatRange("ShadowSoftness", 0.7, 0, 6, 0.05, false).name())
    .add(new Page("Page_ShadowsExtra").name()
        .add(shadowPixelization)
        .add(asFloatRange("ShadowDistort", 3, 0, 6, 0.05, false).name().desc("Allocate more resolution closer to the player.\n When using Shadow Cascades, this value should generally be lowered."))
        .add(asIntRange("ShadowCascadeCount", 0, 0, 8, 1, true).name().values("Auto"))
        .add(asFloatRange("ShadowBias", 0.4, 0, 1, 0.025, false).name().desc("Increase to reduce shadow acne at the cost of increasing peter panning."))
        .add(asFloatRange("ShadowThreshold", 0, 0, 1, 0.05, false).name().desc("How shadowed the shadow needs to be to be considered shadowed, higher will \"shrink\" shadows."))
        .build()
    )
    .build()

    const shading = new Page("Page_Shading").name()
    .add(asBool("PBR", true, shouldReload).name())
    .add(asIntRange("PBRMode", 0, 0, 1, 1, true).name().values("Reduced PBR", "Full PBR"))
    .add(asInt("Specular", 0, 1).needsReload(false).build(1))
    .add(asFloatRange("NormalStrength", 1.0, 0.0, 1.0, 0.05, false))
    .add(shadingPixelization)
    .build()

    const atmosphere = new Page("Page_Atmosphere").name()
    .add(asIntRange("Sky", 1, 0, 1, 1, false).name().values("Vanilla", "Shader's"))
    .add(asIntRange("Stars", 2, 0, 2, 1, false).name().values("Vanilla", "Low", "Medium")) 
    .add(asFloatRange("StarAmount", 0.03, 0, 1, 0.01, false).name()) 
    .add(new Page("AtmosphereExtra")
        .add(asBool("DisableMoonHalo", false, false).name())
        .add(asBool("IsolateCelestials", false, false).name())
        .build()
    )
    .build()

    const cameraAndColors = new Page("Page_CameraAndColors").name()
    .add(new Page("Exposure")
        .add(asFloatRange("ExposureMult", 1, -2, 5, 0.05, false).name())
        .add(asFloatRange("ExposureSpeed", 5, 0, 20, 0.1, false).name())
        
        // Auto exposure
        .add(asIntRange("AutoExposure", 1, 0, 1, 1, shouldReload).name().values("Off", "Low"))
        .add(asIntRange("ExposureSamplesX", 12, 1, 32, 1, true).name())
        .build()
    )
    .add(new Page("Page_Tonemapping").name()
        .add(toneMapPicker("Tonemap"))
        .add(asBool("CompareTonemaps", false, false).name())
        .add(toneMapPicker("Tonemap1", 1))
        .add(toneMapPicker("Tonemap2", 2))
        .add(toneMapPicker("Tonemap3", 3))
        .add(toneMapPicker("Tonemap4", 4))
        .build()
    )
    .build()

    const debug = new Page("_Debug").name()
    .add(asBool("_DumpTags", false, false).name())
    .add(asBool("_DumpUniforms", false, false).name())
    .add(asBool("_DebugEnabled", false, shouldReload).name())
    .add(new Page("_Shadows").name()
        .add(asFloatRange("_ShadowLightBrightness", 1, 0, 15, 0.05, false).name())
        .add(asBool("_ShowShadows", false, false).name())
        .add(asBool("_ShowShadowCascades", false, false).name())
        .add(asIntRange("_ShadowCascadeIndex", 0, 0, 8, 1, false).name())
        .build()
    )
    .add(new Page("_ShowTextures").name()
        .add(asBool("_SliceScreen", false, false).name()) // Slice or Split screen
        .add(...texIsolates(
            "_ShowShadowMap",
            "_ShowDepth",
            "_ShowRoughness",
            "_ShowReflectance",
            "_ShowPorosity",
            "_ShowEmission",
            "_ShowNormals",
            "_ShowAmbientOcclusion",
            "_ShowHeight",
            "_ShowGeometryNormals",
            "_ShowLightLevel",
        ))
        .build()
    )
    .add(new Page("_DebugUI").name("Debug UI")
        .add(asFloatRange("_DebugUIScale", 2, 0, 8, 0.1, false).name("Debug UI Scale"))
        .add(asBool("_DebugStats", false, false).name("Debug Stats"))

        .add(putTextLabel("_LabelDisplaySettings", "Display Settings"))
        .add(asBool("_DisplayAtmospheric", false, false).name())
        .add(asBool("_DisplaySunlightColors", false, false).name())
        .add(asBool("_DisplayCameraData", false, false).name())
        .build()
    )
    .build()

    return new Page("Featherweight")
        .add(general)
        .add(shadow)
        .add(shading)
        .add(atmosphere)
        .add(cameraAndColors)
        .add(debug)
        .build();
}

/// Preset settings
function asPixelizationOverride(name: string) {
    return asFloat(name, -0.25, -0.5, -1.0, 0, 8, 16, 32, 64, 128, 256).needsReload(false).build(-1)
    .values("25 %", "50 %", "100 %");
}

/// Ranges
function asIntRange(keyName: string, defaultValue: number, valueMin: number, valueMax: number, interval: number, reload: boolean = true) {
    const values = getValueRange(valueMin, valueMax, interval);
    return asInt(keyName, ...values).needsReload(reload).build(defaultValue);
}

function asFloatRange(keyName: string, defaultValue: number, valueMin: number, valueMax: number, interval: number, reload: boolean = true) {
    const values = getValueRange(valueMin, valueMax, interval);
    return asFloat(keyName, ...values).needsReload(reload).build(defaultValue);
}

function getValueRange(valueMin: number, valueMax: number, interval: number) {
    const values: number[] = [];

    for (let value = valueMin; value <= valueMax+0.001; value += interval) {
        values.push(value);
    }

    return values;
}

// / To support lang file, comment out if generating lang file
import "../build/generateLangDummy"
// / Generate lang file, comment out if using shader
//import {EMPTY, Page, asInt, asFloat, asString, asBool, putTextLabel, putTranslationLabel, generateLang, BoolSetting, IntSetting, FloatSetting, StringSetting} from "../build/generateLang"
//setupOptions(); generateLang();
//////////////
