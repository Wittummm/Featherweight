
import { dumpSettings } from "../FixedStreamingBuffer";
import { distPerShadowCascade, Settings } from "../Settings";
import { Vec4 } from "../Vector";
import { Buffers, States, Textures } from "./resources/objects";

function getPixelizationOverride(name: string) {
    const basePixelization = getIntSetting("Pixelization");
    const pixelization = getFloatSetting(name);

    return Math.floor((pixelization < 0) ? -pixelization*basePixelization : pixelization);
}

export default function configSettings(renderConfig: RendererConfig, textures: Textures, buffers: Buffers, states: States) {
    // CODE: sadi1n NOTE: TODOEVENTUALLY: TEMP: BELOW IS TEMPORARY, Aperture currently has strict reloading features
    function requestReload(msg) { sendInChat(`Request Reload: ${msg}`); }
    
    if (getIntSetting("ShadowCascadeCount") == 0 && renderConfig.shadow.distance != getIntSetting("ShadowDistance")) {
        if (Math.ceil(renderConfig.shadow.distance/distPerShadowCascade) != Math.ceil(getIntSetting("ShadowDistance")/distPerShadowCascade)) {
            requestReload("When changing Shadow Distance and Shadow Cascade is Auto.")
        }
    }
    ///////////
    
    renderConfig.render.stars = getIntSetting("Stars") == 0;
    renderConfig.sunPathRotation = Settings.SunPathRotation;
    renderConfig.shadow.distance = getIntSetting("ShadowDistance"); // TODOEVENTUALLY IMPROVE: should clamp to render distance

    // Non Aperture/Built in Settings
    dumpSettings(getBoolSetting("_DumpUniforms"));
    
    const shadowBias = getFloatSetting("ShadowBias") / renderConfig.shadow.resolution;
    
    // TODOEVENTUALLY: is static for now but can/should be user customizable when Aperture supports vec4/vec3 sliders
    // alpha is brightness: table from "Moving Frostbite to Physically Based Rendering 3.0"
    let LightSunrise =      new Vec4(0.984 , 0.702  , 0.275 , 15000);
    let LightMorning =      new Vec4(0.941 , 0.855  , 0.7   , 60000);
    let LightNoon =         new Vec4(0.92  , 0.898  , 0.8   , 88000);
    let LightAfternoon =    new Vec4(0.9625, 0.807  , 0.7   , 80000);
    let LightSunset =       new Vec4(0.984 , 0.6235 , 0.2627, 30000);
    let LightNightStart =   new Vec4(0.1451, 0.14513, 0.2314, 10000);
    let LightMidnight =     new Vec4(0.0588, 0.04706, 0.1412, 5000 );
    let LightNightEnd =     new Vec4(0     , 0      , 0.035 , 10000);
    let LightRain =         new Vec4(0.306 , 0.408  , 0.506 , 25000);

    let AmbientSunrise =    new Vec4(0.45, 0.3, 0.2, 29500);
    let AmbientMorning =    new Vec4(0.6, 0.6, 0.5, 26000);
    let AmbientNoon =       new Vec4(0.8, 0.8, 0.75, 20000);
    let AmbientAfternoon =  new Vec4(0.7, 0.65, 0.55, 26000);
    let AmbientSunset =     new Vec4(0.47, 0.3, 0.25, 29000);
    let AmbientNightStart = new Vec4(0.15, 0.15, 0.25, 14000);
    let AmbientMidnight =   new Vec4(0.05, 0.05, 0.18, 8000);
    let AmbientNightEnd =   new Vec4(0.1, 0.1, 0.14, 14000);
    let AmbientRain =       new Vec4(0.3, 0.35, 0.4, 15000);

    if (buffers.debug) {
        LightSunrise.w *= getFloatSetting("_ShadowLightBrightness")
        LightMorning.w *= getFloatSetting("_ShadowLightBrightness")
        LightNoon.w *= getFloatSetting("_ShadowLightBrightness")
        LightAfternoon.w *= getFloatSetting("_ShadowLightBrightness")
        LightSunset.w *= getFloatSetting("_ShadowLightBrightness")
        LightNightStart.w *= getFloatSetting("_ShadowLightBrightness")
        LightMidnight.w *= getFloatSetting("_ShadowLightBrightness")
        LightNightEnd.w *= getFloatSetting("_ShadowLightBrightness")
        LightRain.w *= getFloatSetting("_ShadowLightBrightness")

        buffers.debug
        .bool("_DebugEnabled")
        .bool("_DebugStats")
        .bool("_SliceScreen")
        .int("_ShowDepth")
        .int("_ShowRoughness")
        .int("_ShowReflectance")
        .int("_ShowPorosity")
        .int("_ShowEmission")
        .int("_ShowNormals")
        .int("_ShowAmbientOcclusion")
        .int("_ShowHeight")
        .int("_ShowShadowMap")
        .int("_ShowGeometryNormals")
        .int("_ShowLightLevel")
        .bool("_ShowShadows")
        .bool("_ShowShadowCascades")
        .int("_ShadowCascadeIndex")
        .float("_DebugUIScale")
        .bool("_DisplayAtmospheric")
        .bool("_DisplaySunlightColors")
        .bool("_DisplayCameraData")
        .end()
    }

    buffers.settings
    // Non direct settings
    .float(0, "Rain") // rain but changes based on biome
    .float(0, "Wetness") // "Slow" rain

    // Settings
    .vec4(...LightSunrise.xyzw(), "LightSunrise")
    .vec4(...LightMorning.xyzw(), "LightMorning")
    .vec4(...LightNoon.xyzw(), "LightNoon")
    .vec4(...LightAfternoon.xyzw(), "LightAfternoon")
    .vec4(...LightSunset.xyzw(), "LightSunset")
    .vec4(...LightNightStart.xyzw(), "LightNightStart")
    .vec4(...LightMidnight.xyzw(), "LightMidnight")
    .vec4(...LightNightEnd.xyzw(), "LightNightEnd")
    .vec4(...LightRain.xyzw(), "LightRain")

    .vec4(...AmbientSunrise.xyzw(), "AmbientSunrise")
    .vec4(...AmbientMorning.xyzw(), "AmbientMorning")
    .vec4(...AmbientNoon.xyzw(), "AmbientNoon")
    .vec4(...AmbientAfternoon.xyzw(), "AmbientAfternoon")
    .vec4(...AmbientSunset.xyzw(), "AmbientSunset")
    .vec4(...AmbientNightStart.xyzw(), "AmbientNightStart")
    .vec4(...AmbientMidnight.xyzw(), "AmbientMidnight")
    .vec4(...AmbientNightEnd.xyzw(), "AmbientNightEnd")
    .vec4(...AmbientRain.xyzw(), "AmbientRain")
    // Shadows
    .int(renderConfig.shadow.cascades, "ShadowCascadeCount") 
    .int(Settings.ShadowSamples, "ShadowSamples")
    .int("ShadowFilter")
    .float("ShadowDistort")
    .float("ShadowSoftness")
    .float(shadowBias, "Initial ShadowBias")
    .float("ShadowThreshold")
    // Pixelization
    .int(getPixelizationOverride("ShadingPixelization"), "ShadingPixelization")
    .int(getPixelizationOverride("ShadowPixelization"), "ShadowPixelization")
    // Shading
    .int(Settings.PBR, "PBR")
    .int("Specular")
    .float("NormalStrength")

    // Camera/Visuals
    .int("AutoExposure")
    .float(Math.exp(getFloatSetting("ExposureMult")), "ExposureMult")
    .float("ExposureSpeed")
    .int("Tonemap")
    .bool("CompareTonemaps")
    .ivec4(getIntSetting("Tonemap1"), getIntSetting("Tonemap2"), getIntSetting("Tonemap3"), getIntSetting("Tonemap4"))
    // Atmospheric
    .int("Sky")
    .int("Stars")
    .float("StarAmount")
    .bool("DisableMoonHalo")
    .bool("IsolateCelestials")
    
    .end()
}
