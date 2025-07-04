import { Vec4, Vec3, Vec2 } from './modules/Vector';
import { FixedBuiltStreamingBuffer, FixedStreamingBuffer, dumpSettings } from './modules/FixedBuiltStreamingBuffer';
import { Settings } from './modules/Settings';
import { KeyInput } from './modules/KeyInput';
import { toggleBoolSetting } from './modules/HelperFuncs';
import { dumpTags, Tagger, mc, sh, ap } from './modules/BlockTag';
import { addType, getType } from './modules/BlockType';

// Consts
const DEBUG_CONFIG = {
    debug: true,
    outputToChat: true,
}
const distancePerCascade = 96;
// Variables
let debugBuffer: FixedBuiltStreamingBuffer | null;
let settingsBuffer: FixedBuiltStreamingBuffer;
let shadowCascadeCount: number = -1;
//// Helper Funcs ////
function initSettings(state?: WorldState) { // Settings initialized once on shader setup
    worldSettings.ambientOcclusionLevel = 1.0;
    worldSettings.mergedHandDepth = true; 
    worldSettings.shadowMapDistance = getIntSetting("ShadowDistance");

    dumpTags(getBoolSetting("_DumpTags"));
}
function setupSettings(state?: WorldState) {
    // CODE: sadi1n NOTE: TODOEVENTUALLY: TEMP: BELOW IS TEMPORARY, Aperture currently has strict reloading features
    function requestReload(msg) { sendInChat(`Request Reload: ${msg}`); }
    
    if (getIntSetting("ShadowCascadeCount") == 0 && worldSettings.shadowMapDistance != getIntSetting("ShadowDistance")) {
        if (Math.ceil(worldSettings.shadowMapDistance/distancePerCascade) != Math.ceil(getIntSetting("ShadowDistance")/distancePerCascade)) {
            requestReload("When changing Shadow Distance and Shadow Cascade is Auto.")
        }
    }
    ///////////


    worldSettings.sunPathRotation = Settings.SunPathRotation;
    worldSettings.shadowMapDistance = getIntSetting("ShadowDistance"); // TODOEVENTUALLY IMPROVE: should clamp to render distance
    if (shadowCascadeCount == 1) { // NOTE: AP_BUG: TODOEVENTUALLY: This is presumbly a bug in Aperture as Arc 2 also does this workaround
        worldSettings.shadowNearPlane = 1.5*-worldSettings.shadowMapDistance; 
        worldSettings.shadowFarPlane = 1.5*worldSettings.shadowMapDistance; 

        // Closer to Aperture's default while not being broken, but has worse shadow acne
        // worldSettings.shadowNearPlane = -worldSettings.shadowMapDistance; 
        // worldSettings.shadowFarPlane = 256-worldSettings.shadowMapDistance; 
    }

    // Non Aperture/Built in Settings
    dumpSettings(getBoolSetting("_DumpUniforms"));

    const shadowBias = getFloatSetting("ShadowBias") / worldSettings.shadowMapResolution;

    // TODOEVENTUALLY: is static for now but can/should be user customizable when Aperture supports vec4/vec3 sliders
    let LightSunrise =      new Vec4(0.984, 0.702, 0.275, 0.9);
    let LightMorning =      new Vec4(0.941, 0.855, 0.7, 1);
    let LightNoon =         new Vec4(0.92, 0.898, 0.8, 1.15); // temp
    let LightAfternoon =    new Vec4(0.9625, 0.807, 0.7, 1);
    let LightSunset =       new Vec4(0.984, 0.6235, 0.2627, 0.9);
    let LightNightStart =   new Vec4(0.1451, 0.14513, 0.23137, 0.8);
    let LightMidnight =     new Vec4(0.0588, 0.04706, 0.1412, 0.75);
    let LightNightEnd =     new Vec4(0, 0, 0.035, 0.8);
    let LightRain =         new Vec4(0.306, 0.408, 0.506, 0.8);

    if (debugBuffer) {
        LightSunrise.w *= getFloatSetting("_ShadowLightBrightness")
        LightMorning.w *= getFloatSetting("_ShadowLightBrightness")
        LightNoon.w *= getFloatSetting("_ShadowLightBrightness")
        LightAfternoon.w *= getFloatSetting("_ShadowLightBrightness")
        LightSunset.w *= getFloatSetting("_ShadowLightBrightness")
        LightNightStart.w *= getFloatSetting("_ShadowLightBrightness")
        LightMidnight.w *= getFloatSetting("_ShadowLightBrightness")
        LightNightEnd.w *= getFloatSetting("_ShadowLightBrightness")
        LightRain.w *= getFloatSetting("_ShadowLightBrightness")

        debugBuffer
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
        .bool("_ShowShadows")
        .bool("_ShowShadowCascades")
        .int("_ShadowCascadeIndex")
        .float("_DebugUIScale")
        .bool("_DisplayAtmospheric")
        .bool("_DisplaySunlightColors")
        .end()
    }
    
    settingsBuffer
    // Reserved(Computed on gpu)
    .uint(0)
    // Atmospheric
    .vec3(1, 0, 0, "AmbientColor")
    .vec4(0, 1, 0, 1, "SunlightColor")
    .float(0, "Rain")
    .float(0, "Wetness")

    .vec4(...LightSunrise.xyzw(), "LightSunrise")
    .vec4(...LightMorning.xyzw(), "LightMorning")
    .vec4(...LightNoon.xyzw(), "LightNoon")
    .vec4(...LightAfternoon.xyzw(), "LightAfternoon")
    .vec4(...LightSunset.xyzw(), "LightSunset")
    .vec4(...LightNightStart.xyzw(), "LightNightStart")
    .vec4(...LightMidnight.xyzw(), "LightMidnight")
    .vec4(...LightNightEnd.xyzw(), "LightNightEnd")
    .vec4(...LightRain.xyzw(), "LightRain")
    // Shadows
    .int(shadowCascadeCount, "ShadowCascadeCount") 
    .int(Settings.ShadowSamples, "ShadowSamples")
    .int("ShadowFilter")
    .float("ShadowDistort")
    .float("ShadowSoftness")
    .float(shadowBias, "Initial ShadowBias")
    // Pixelization
    .int(getPixelizationOverride("ShadingPixelization"), "ShadingPixelization")
    .int(getPixelizationOverride("ShadowPixelization"), "ShadowPixelization")
    // Shading
    .int("Specular")
    .float("NormalStrength")

    // Camera/Visuals
    .float(Math.exp(getFloatSetting("Exposure")), "Exposure")
    .int("Tonemap")
    .bool("CompareTonemaps")
    .ivec4(getIntSetting("Tonemap1"), getIntSetting("Tonemap2"), getIntSetting("Tonemap3"), getIntSetting("Tonemap4"))
    .end()
}
function setupTags() {
    // This needs to run before registering programs;
    
}

function setupTypes() {
    // defineGlobally("isType(blockId, tag)", "(iris_getCustomId(blockId) == tag)"); // This doesnt seem to work currently :(

    addType("water", "minecraft:water", "minecraft:flowing_water");
}

function setup() {    
    //// Declarations
    defineGlobally("SCENE_FORMAT", "r11f_g11f_b10f");
    let sceneTexture = new Texture("sceneTex").imageName("sceneImg").format(Format.R11F_G11F_B10F).build();
    let gbufferTexture = new Texture("gbufferTex").imageName("gbufferImg").format(Format.RG32UI).build();

    /////// Helper Funcs ///////////
    function terrainProgram(usage: ProgramUsage, name: string, programName?: string): ObjectShader {
        return bindSettings(new ObjectShader(programName || name, usage))
        .vertex(`programs/geometry/${name}.vsh`)
        .fragment(`programs/geometry/${name}.fsh`)
        .target(0, sceneTexture)
        .target(1, gbufferTexture).blendOff(1)
    }
    function define<T>(shader: T, name: string) {
        if (getBoolSetting(name)) {
            shader.define(name, "");
        }
    }
    function bindSettings<T>(program: T): T {
        define(program, "ShadowsEnabled");

        return program.ssbo(0, settingsBuffer.buffer);
    }
    /////// Actual Functions ////////
    function setupResources() {
        debugBuffer = getBoolSetting("_DebugEnabled") ? new FixedStreamingBuffer().bool().bool().bool().int().int().int().int().int().int().int().int().int().bool().bool().int().float().bool().bool().build() : null;
        settingsBuffer = new FixedStreamingBuffer().uint().vec3().vec4().float().float().vec4().vec4().vec4().vec4().vec4().vec4().vec4().vec4().vec4().int().int().int().float().float().float().int().int().int().float().float().int().bool().ivec4().build();
    }
    function setupPrograms() {
        registerShader(Stage.PRE_RENDER, bindSettings(new Compute("init_settings"))
            .location("programs/init/settings.csh").workGroups(1,1,1).build()); 

        registerShader(terrainProgram(Usage.TERRAIN_SOLID, "geometry_main", "terrain_solid")
            .blendOff(0).build()
        );
        registerShader(terrainProgram(Usage.TERRAIN_CUTOUT, "geometry_main", "terrain_cutout")
            .blendOff(0)
            .define("CUTOUT", "").build()
        );
        registerShader(terrainProgram(Usage.TERRAIN_TRANSLUCENT, "geometry_main", "terrain_translucent")
            .define("FORWARD", "").build()
        );
        registerShader(Stage.PRE_TRANSLUCENT, bindSettings(new Compute("shade"))
            .location("programs/post_opaque/shade.csh")
            .workGroups(Math.ceil(screenWidth/16), Math.ceil(screenHeight/16), 1).build()
        ); 

        // / Shadows
        if (Settings.ShadowsEnabled) {
            shadowCascadeCount = getIntSetting("ShadowCascadeCount");
            if (shadowCascadeCount <= 0) {
                shadowCascadeCount = Math.ceil(worldSettings.shadowMapDistance/distancePerCascade); 
            }
        
            enableShadows(Math.floor(getIntSetting("ShadowResolution")/shadowCascadeCount), shadowCascadeCount)
            registerShader(bindSettings(new ObjectShader("shadow", Usage.SHADOW)) // TODOEVENTUALLY: separate for cutout to early z check
                .vertex(`programs/geometry/shadow.vsh`)
                .fragment(`programs/geometry/shadow.fsh`)
                .define("CUTOUT", "")
                .build()
            )
        }

        if (debugBuffer) {
            registerShader(Stage.POST_RENDER, bindSettings(new Compute("debug"))
                .location("programs/post_render/debug.csh")
                .workGroups(Math.ceil(screenWidth/16), Math.ceil(screenHeight/16), 1)
                .ubo(0, debugBuffer.buffer).build()
            ); 
        }

        setCombinationPass(bindSettings(new CombinationPass("programs/finalize/final.fsh")).build());
    }

    initSettings();
    setupTags();
    setupTypes();
    setupResources();
    setupPrograms();
    setupSettings();
}

/////// Aperture Pipeline ///////
export function onSettingsChanged(state: WorldState) {
    setupSettings(state);

    // Crashes for some reason idk
    // setHidden("_ShowShadowMap", false);
    // setHidden("ShadowSoftness", getIntSetting("ShadowFilter") == 2);
    // setHidden("ShadowSamples", getIntSetting("ShadowFilter") == 2);
}

export function setupShader(dimension: NamespacedId) {
    setup()
    ///////////////////////////

    if (DEBUG_CONFIG.debug) {
        function dumpDebugInfo(chat: boolean = false) {
            let output = chat ? sendInChat : print;
        }

        dumpDebugInfo(DEBUG_CONFIG.outputToChat);
    }
}

export function getBlockId(block: BlockState): number {
    // This runs in runtime when block changes, so it should be optimized
    return getType(block);
}

export function setupFrame(state: WorldState) {
    settingsBuffer.uploadData();
    if (debugBuffer) {
        debugBuffer.uploadData();

        if (KeyInput.onKeyDown(Keys.E)) {
            toggleBoolSetting("_DebugEnabled");
            if (getBoolSetting("_DebugEnabled")) {sendInChat("Debug mode enabled, may need reload to work");}
        }

        if (KeyInput.onKeyDown(Keys.LEFT)) {setIntSetting("SunPathRotation", getIntSetting("SunPathRotation") - 5);}
        if (KeyInput.onKeyDown(Keys.RIGHT)) {setIntSetting("SunPathRotation", getIntSetting("SunPathRotation") + 5);}

        // KeyInput.update() is NOT cheap, it is currently 0.5 ms on my machine so beware!!!
        KeyInput.update(); // Must be last
    }
}

////Misc Helpers//////

function getPixelizationOverride(name: string) {
    const basePixelization = getIntSetting("Pixelization");
    const pixelization = getFloatSetting(name);

    return Math.floor((pixelization < 0) ? -pixelization*basePixelization : pixelization);
}