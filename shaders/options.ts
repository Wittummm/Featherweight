
/*
4 Tiers of reloading
- Need Reload(true)
- Can reload(canReload)
- Should reload(shouldReload)
- Does not need Reload(false)
*/
// These are "comment" variables where the names describe a comment and not what the variable actually is/does
const canReload = false; // Works without needing to reload, but reloading is possible (default: false)
const shouldReload = true; // Works without needing to reload, but reloading is idle (default: true)

/*
Syntax notes:
- PascalCase for the setting names
- "Enabled" suffix for toggles
- "_Show" prefix for internal/debug
*/
function texIsolate(name: string) {
    return asInt(name,-1,0,1,2,3,4)
    .values("Off","Full","Top Left","Top Right","Bottom Left","Bottom Right")
    .name(name.replace("_",""))
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
    const general = new Page("General")
    .add(asIntRange("SunPathRotation", 0, -90, 90, 5, false))
    .add(asFloat("Pixelization", 8, 16, 32, 64, 128, 256).needsReload(false).build(16))
    .build();

    const shadow = new Page("Shadows")
    .add(asFloatRange("ShadowDistort", 0.7, 0, 1, 0.05, false))
    .add(asIntRange("ShadowSamples", 3, 2, 128, 1, false))
    .add(asInt("ShadowFilter", 0, 1, 2)
        .values("Nearest", "Linear", "Uniform Soft")
        .needsReload(canReload).build(1)) // Nearest Linear PCF
    .add(asBool("PresetPatternsPCF", true, canReload))
    .build()

    const debug = new Page("Debug")
    .add(asBool("_DebugEnabled", false, shouldReload).name("Enable Debug"))
    .add(asBool("_DebugStats", false, false).name("Debug Stats")) // TODONOW: CONFIGTODO:
    .add(asBool("_SliceScreen", false, false).name("Slice Screen")) // Slice or Split screen
    .add(asBool("_ShowShadows", false, false).name("Isolate Shadows"))
    .add(EMPTY)
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
    ))
    .build()

    const UNSORTED = new Page("UNSORTED")
    .add(asInt("Specular", 0, 1).needsReload(false).build(1))
    .build()

    return new Page("Featherweight")
        .add(general)
        .add(shadow)
        .add(UNSORTED)
        .add(debug)
        .build();
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

    for (let value = valueMin; value <= valueMax; value += interval) {
        values.push(value);
    }

    return values;
}

// / To support lang file, comment out if generating lang file
import "../build/generateLangDummy"
// / Generate lang file, comment out if using shader
// import {EMPTY, Page, asInt, asFloat, asString, asBool, putTextLabel, putTranslationLabel, generateLang, IntSetting} from "../build/generateLang"
// setupOptions();
// generateLang();
//////////////