import { Vec4, Vec3, Vec2 } from './modules/Vector';
import { FixedBuiltStreamingBuffer, FixedStreamingBuffer, dumpSettings } from './modules/FixedStreamingBuffer';
import { distancePerShadowCascade, Settings } from './modules/Settings';
import { KeyInput } from './modules/KeyInput';
import { toggleBoolSetting } from './modules/HelperFuncs';
import { dumpTags, Tagger, mc, sh, ap } from './modules/BlockTag';
import { addType, getType } from './modules/BlockType';

// Consts
const DEBUG_CONFIG = {
    debug: true,
    outputToChat: true,
}
const defaultComposite = "programs/template/composite.vsh"
// Variables
let debugBuffer: FixedBuiltStreamingBuffer | null;
let settingsBuffer: FixedBuiltStreamingBuffer;
let metadataBuffer: BuiltGPUBuffer;
//// Helper Funcs ////
function initSettings(state?: WorldState) { // Settings initialized once on shader setup
    worldSettings.ambientOcclusionLevel = 1.0;
    worldSettings.mergedHandDepth = true; 
    worldSettings.shadow.distance = getIntSetting("ShadowDistance");
    worldSettings.render.stars = true;
    worldSettings.render.horizon = false;

    dumpTags(getBoolSetting("_DumpTags"));
}
function setupSettings(state?: WorldState) {
    // CODE: sadi1n NOTE: TODOEVENTUALLY: TEMP: BELOW IS TEMPORARY, Aperture currently has strict reloading features
    function requestReload(msg) { sendInChat(`Request Reload: ${msg}`); }
    
    if (getIntSetting("ShadowCascadeCount") == 0 && worldSettings.shadow.distance != getIntSetting("ShadowDistance")) {
        if (Math.ceil(worldSettings.shadow.distance/distancePerShadowCascade) != Math.ceil(getIntSetting("ShadowDistance")/distancePerShadowCascade)) {
            requestReload("When changing Shadow Distance and Shadow Cascade is Auto.")
        }
    }
    ///////////

    worldSettings.render.stars = getIntSetting("Stars") == 0;
    worldSettings.sunPathRotation = Settings.SunPathRotation;
    worldSettings.shadow.distance = getIntSetting("ShadowDistance"); // TODOEVENTUALLY IMPROVE: should clamp to render distance

    // Non Aperture/Built in Settings
    dumpSettings(getBoolSetting("_DumpUniforms"));

    const shadowBias = getFloatSetting("ShadowBias") / worldSettings.shadow.resolution;
    
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
    
    settingsBuffer
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
    .int(worldSettings.shadow.cascades, "ShadowCascadeCount") 
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
    .int(Settings.PBR)
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
function setupTags() {
    // This needs to run before registering programs
}

function setupTypes() {
    // defineGlobally("isType(blockId, tag)", "(iris_getCustomId(blockId) == tag)"); // This doesnt seem to work currently :(

    addType("water", "minecraft:water", "minecraft:flowing_water");
}

function setup() {    
    //// Declarations
    defineGlobally("SCENE_FORMAT", "r11f_g11f_b10f");
    let sceneTexture = new Texture("sceneTex").imageName("sceneImg").format(Format.R11F_G11F_B10F).mipmap(true).build();
    defineGlobally("GBUFFER_FORMAT", "rg32ui");
    let gbufferTexture: BuiltTexture|null = Settings.PBREnabled ? new Texture("gbufferTex").imageName("gbufferImg").format(Format.RG32UI).build() : null;
    defineGlobally("DATA0_FORMAT", "r32ui");
    let dataTexture0 = new Texture("dataTex0").imageName("dataImg0").format(Format.R32UI).build();

    /////// Helper Funcs ///////////
    function define<T>(shader: Shader<T>, name: string, defineName?: string): T {
        if (getBoolSetting(name)) {
            shader.define(defineName ?? name, "");
        }
        return shader as T;
    }
    function lightingDefines<T>(shader: Shader<T>): T {
        define(shader, "ShadowsEnabled");
        define(shader, "PBR", "PBREnabled"); // PBR cannot be enabled without shading

        return shader as T;
    }
    function terrainProgram(usage: ProgramUsage, name: string, programName?: string): ObjectShader {
        let program = new ObjectShader(programName || name, usage);
        lightingDefines(program);
        
        bindSettings(program)
        .vertex(`programs/geometry/${name}.vsh`)
        .fragment(`programs/geometry/${name}.fsh`)
        .target(0, sceneTexture)
        .target(2, dataTexture0)
        if (gbufferTexture) {program.target(1, gbufferTexture).blendOff(1);}

        return program;
    }
    function bindSettings<T>(program: Shader<T>): T {
        program.define("INCLUDE_SETTINGS", "");
        return (bindMetadata(program) as Shader<T>).ubo(0, settingsBuffer.buffer);
    }
    function bindMetadata<T>(program: Shader<T>): T {
        program.define("INCLUDE_METADATA", "");
        return program.ssbo(0, metadataBuffer);
    }
    function generateMipmap(stage: ProgramStage, ...textures: BuiltTexture[]) {
        registerShader(stage, new GenerateMips(...textures));
    }
    /////// Actual Functions ////////
    function setupResources() { 
        // Only use for forward declared/global scope resources
        debugBuffer = getBoolSetting("_DebugEnabled") ? new FixedStreamingBuffer().bool().bool().bool().int().int().int().int().int().int().int().int().int().int().int().bool().bool().int().float().bool().bool().bool().build() : null;
        settingsBuffer = new FixedStreamingBuffer().float().float() .vec4().vec4().vec4().vec4().vec4().vec4().vec4().vec4().vec4().vec4().vec4().vec4().vec4().vec4().vec4().vec4().vec4().vec4() .int().int().int().float().float().float().float() .int().int() .int().int().float() .int().float().float().int().bool().ivec4() .int().int().float().bool().bool().build();
        metadataBuffer = new GPUBuffer(72).build();
    }
    function setupPrograms() {
        registerShader(Stage.PRE_RENDER, bindSettings(new Compute("init_settings"))
            .location("programs/pre_render/settings.csh").workGroups(1,1,1).build()
        ); 

        registerShader(Stage.PRE_RENDER, bindSettings(new Composite("clear_textures"))
            .vertex(defaultComposite)
            .fragment("programs/pre_render/clear_textures.fsh")
            .target(0, sceneTexture)
            .build()
        ); 

        // Terraain
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

        // Sky
        registerShader(bindMetadata(new ObjectShader("sky_textured", Usage.SKY_TEXTURES))
            .vertex("programs/geometry/sky_textured.vsh")
            .fragment("programs/geometry/sky_textured.fsh")
            .target(0, sceneTexture)
            .blendFunc(0, Func.ONE, Func.ONE, Func.ONE, Func.ONE)
            .build()
        );

        registerShader(bindSettings(new ObjectShader("sky_basic", Usage.SKYBOX))
            .vertex("programs/geometry/sky_basic.vsh")
            .fragment("programs/geometry/sky_basic.fsh")
            .target(0, sceneTexture)
            // .blendFunc(0, Func.ONE, Func.ONE, Func.ONE, Func.ONE)
            .build()
        );

        // Deferred
        registerShader(Stage.PRE_TRANSLUCENT, bindSettings(lightingDefines(new Compute("shade")))
            .location("programs/post_opaque/shade.csh")
            .workGroups(Math.ceil(screenWidth/16), Math.ceil(screenHeight/16), 1).build()
        ); 

        // / Shadows
        if (Settings.ShadowsEnabled) {
            worldSettings.shadow.resolution = getIntSetting("ShadowResolution")/Settings.ShadowCascadeCount;
            worldSettings.shadow.cascades = Settings.ShadowCascadeCount;
            worldSettings.shadow.enable();
            registerShader(bindSettings(new ObjectShader("shadow", Usage.SHADOW)) // TODOEVENTUALLY: separate for cutout to early z check
                .vertex(`programs/geometry/shadow.vsh`)
                .fragment(`programs/geometry/shadow.fsh`)
                .build()
            )
            registerShader(bindSettings(new ObjectShader("shadow", Usage.SHADOW_TERRAIN_CUTOUT)) // TODOEVENTUALLY: separate for cutout to early z check
                .vertex(`programs/geometry/shadow.vsh`)
                .fragment(`programs/geometry/shadow.fsh`)
                .define("CUTOUT", "")
                .build()
            )
            registerShader(bindSettings(new ObjectShader("shadow", Usage.SHADOW_ENTITY_CUTOUT)) // TODOEVENTUALLY: separate for cutout to early z check
                .vertex(`programs/geometry/shadow.vsh`)
                .fragment(`programs/geometry/shadow.fsh`)
                .define("CUTOUT", "")
                .build()
            )
        }

        /// Auto Exposure ///
        if (getIntSetting("AutoExposure") > 0) {
            generateMipmap(Stage.POST_RENDER, sceneTexture);
            registerShader(Stage.POST_RENDER, bindSettings(new Compute("auto_exposure"))
                .location("programs/post_render/auto_exposure.csh")
                .workGroups(1, 1, 1)
                .define("ExposureSamplesX", Settings.ExposureSamples.x.toString())
                .define("ExposureSamplesY", Settings.ExposureSamples.y.toString())
                .build()
            );
        }

        if (debugBuffer) {
            registerShader(Stage.POST_RENDER, lightingDefines(bindSettings(new Compute("debug")))
                .location("programs/post_render/debug.csh")
                .workGroups(Math.ceil(screenWidth/16), Math.ceil(screenHeight/16), 1)
                .ubo(0, debugBuffer.buffer).build()
            ); 
        }
        /////////////////////

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

    // setHidden("Tonemap1", getBoolSetting("CompareTonemaps"));
    // setHidden("Tonemap2", getBoolSetting("CompareTonemaps"));
    // setHidden("Tonemap3", getBoolSetting("CompareTonemaps"));
    // setHidden("Tonemap4", getBoolSetting("CompareTonemaps"));
}

export function setupShader(dimension: NamespacedId) {
    setup()
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