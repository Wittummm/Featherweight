import { Vec4, Vec3, Vec2 } from './modules/Vector';
import { FixedBuiltStreamingBuffer, FixedStreamingBuffer, dumpSettings } from './modules/FixedStreamingBuffer';
import { distancePerShadowCascade, Settings } from './modules/Settings';
import KeyInput from './modules/KeyInput';
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
let autoExposureState: StateReference;
//// Helper Funcs ////
function initSettings(renderConfig: RendererConfig) { // Settings initialized once on shader setup
    renderConfig.ambientOcclusionLevel = 1.0;
    renderConfig.mergedHandDepth = true; 
    renderConfig.shadow.distance = getIntSetting("ShadowDistance");
    renderConfig.render.stars = true;
    renderConfig.render.horizon = false;

    dumpTags(getBoolSetting("_DumpTags"));
}
function setupSettings(renderConfig: RendererConfig) {
    // CODE: sadi1n NOTE: TODOEVENTUALLY: TEMP: BELOW IS TEMPORARY, Aperture currently has strict reloading features
    function requestReload(msg) { sendInChat(`Request Reload: ${msg}`); }
    
    if (getIntSetting("ShadowCascadeCount") == 0 && renderConfig.shadow.distance != getIntSetting("ShadowDistance")) {
        if (Math.ceil(renderConfig.shadow.distance/distancePerShadowCascade) != Math.ceil(getIntSetting("ShadowDistance")/distancePerShadowCascade)) {
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
function setupTags() {
    // This needs to run before registering programs
}

function setupTypes() {
    // defineGlobally("isType(blockId, tag)", "(iris_getCustomId(blockId) == tag)"); // This doesnt seem to work currently :(

    addType("water", "minecraft:water", "minecraft:flowing_water");
}

function setup(pipeline: PipelineConfig) {    
    let renderConfig = pipeline.getRendererConfig();
    Settings.setRendererConfig(renderConfig);
    Tagger.setPipeline(pipeline);
    FixedBuiltStreamingBuffer.setPipeline(pipeline);
    //// Declarations
    /// Textures ///
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
    /// States ///
    autoExposureState = new StateReference();
    /////////////////////

    /////// Helper Funcs ///////////
    function define<T extends Shader<any, any>>(shader: T, name: string, defineName?: string): T {
        if (getBoolSetting(name)) {
            shader.define(defineName ?? name, "");
        }
        return shader as T;
    }
    function lightingDefines<T extends Shader<any, any>>(shader: T): T {
        define(shader, "ShadowsEnabled");
        define(shader, "PBR", "PBREnabled"); // PBR cannot be enabled without shading

        return shader as T;
    }
    function terrainProgram(usage: ProgramUsage, name: string, programName?: string): ObjectShader {
        let program = pipeline.createObjectShader(programName || name, usage);
        lightingDefines(program);
        
        bindSettings(program)
        .vertex(`programs/geometry/${name}.vsh`)
        .fragment(`programs/geometry/${name}.fsh`)
        .target(0, sceneTexture)
        .target(2, dataTexture0)
        if (gbufferTexture) {program.target(1, gbufferTexture).blendOff(1);}

        return program;
    }
    function bindMetadata<T extends Shader<any, any>>(program: T): T {
        return program.define("INCLUDE_METADATA", "").ssbo(0, metadataBuffer);
    }
    function bindSettings<T extends Shader<any, any>>(program: T): T {
        return bindMetadata(program).define("INCLUDE_SETTINGS", "").ubo(0, settingsBuffer.buffer);
    }
    /////// Actual Functions ////////
    function setupResources() { 
        // Only use for forward declared/global scope resources
        debugBuffer = getBoolSetting("_DebugEnabled") ? new FixedStreamingBuffer().bool().bool().bool().int().int().int().int().int().int().int().int().int().int().int().bool().bool().int().float().bool().bool().bool().build() : null;
        settingsBuffer = new FixedStreamingBuffer().float().float() .vec4().vec4().vec4().vec4().vec4().vec4().vec4().vec4().vec4().vec4().vec4().vec4().vec4().vec4().vec4().vec4().vec4().vec4() .int().int().int().float().float().float().float() .int().int() .int().int().float() .int().float().float().int().bool().ivec4() .int().int().float().bool().bool().build();
        metadataBuffer = pipeline.createBuffer(72, false);
    }
    function setupPrograms() {
        const init = pipeline.forStage(Stage.PRE_RENDER);
        bindMetadata(bindSettings(
            init.createCompute("init_settings")
            .location("programs/pre_render/settings.csh").workGroups(1,1,1)
        )).compile(); 
        init.barrier(SSBO_BIT);
        
        bindSettings(
            init.createComposite("clear_textures")
            .vertex(defaultComposite)
            .fragment("programs/pre_render/clear_textures.fsh")
            .target(0, sceneTexture)
        ).compile(); 
        init.end();

        // Terrain
        terrainProgram(Usage.TERRAIN_SOLID, "geometry_main", "terrain_solid")
        .blendOff(0).compile()

        terrainProgram(Usage.TERRAIN_CUTOUT, "geometry_main", "terrain_cutout")
        .blendOff(0)
        .define("CUTOUT", "").compile()

        terrainProgram(Usage.TERRAIN_TRANSLUCENT, "geometry_main", "terrain_translucent")
        .define("FORWARD", "").compile()

        // Sky
        bindSettings(
            pipeline.createObjectShader("sky_textured", Usage.SKY_TEXTURES)
            .vertex("programs/geometry/sky_textured.vsh")
            .fragment("programs/geometry/sky_textured.fsh")
            .target(0, sceneTexture)
            .blendFunc(0, Func.ONE, Func.ONE, Func.ONE, Func.ONE)
        ).compile();


        bindSettings(
            pipeline.createObjectShader("sky_basic", Usage.SKYBOX)
            .vertex("programs/geometry/sky_basic.vsh")
            .fragment("programs/geometry/sky_basic.fsh")
            .target(0, sceneTexture)
        ).compile();

        // Deferred
        const preTranslucent = pipeline.forStage(Stage.PRE_TRANSLUCENT);
        lightingDefines(bindSettings(
            preTranslucent.createCompute("shade")
            .location("programs/post_opaque/shade.csh")
            .workGroups(Math.ceil(screenWidth/32), Math.ceil(screenHeight/8), 1)
        )).compile();
        preTranslucent.end();

        // / Shadows
        if (Settings.ShadowsEnabled) {
            bindSettings(
                pipeline.createObjectShader("shadow", Usage.SHADOW)
                .vertex(`programs/geometry/shadow.vsh`)
                .fragment(`programs/geometry/shadow.fsh`)
            ).compile()

            bindSettings(
                pipeline.createObjectShader("shadow", Usage.SHADOW_TERRAIN_CUTOUT)
                .vertex(`programs/geometry/shadow.vsh`)
                .fragment(`programs/geometry/shadow.fsh`)
                .define("CUTOUT", "")
            ).compile()

            bindSettings(
                pipeline.createObjectShader("shadow", Usage.SHADOW_ENTITY_CUTOUT)
                .vertex(`programs/geometry/shadow.vsh`)
                .fragment(`programs/geometry/shadow.fsh`)
                .define("CUTOUT", "")
            ).compile()
        }

        const postRender = pipeline.forStage(Stage.POST_RENDER);
        /// Auto Exposure ///
        if (Settings.AutoExposureEnabled) {
            postRender.generateMips(sceneTexture);

            bindMetadata(bindSettings(
                postRender.createCompute("auto_exposure")
                .state(autoExposureState)
                .location("programs/post_render/auto_exposure.csh")
                .workGroups(1, 1, 1)
                .define("ExposureSamplesX", Settings.ExposureSamples.x.toString())
                .define("ExposureSamplesY", Settings.ExposureSamples.y.toString())
            )).compile();
        }

        if (debugBuffer) {
            bindMetadata(lightingDefines(bindSettings(
                postRender.createCompute("debug")
                .location("programs/post_render/debug.csh")
                .workGroups(Math.ceil(screenWidth/16), Math.ceil(screenHeight/16), 1)
                .ubo(1, debugBuffer.buffer)
            ))).compile(); 
        }
        postRender.end();
        /////////////////////

        bindMetadata(bindSettings(pipeline.createCombinationPass("programs/finalize/final.fsh"))).compile();
    }


    setupTags();
    setupTypes();
    setupResources();
    setupPrograms();
    setupSettings(renderConfig);
}

/////// Aperture Pipeline ///////
export function configureRenderer(renderConfig: RendererConfig) {
    Settings.setRendererConfig(renderConfig);
    
    initSettings(renderConfig);

    if (Settings.ShadowsEnabled) {
        renderConfig.shadow.resolution = getIntSetting("ShadowResolution")/Settings.ShadowCascadeCount;
        renderConfig.shadow.cascades = Settings.ShadowCascadeCount;
        renderConfig.shadow.enabled = true;
    }
}
export function configurePipeline(pipeline: PipelineConfig) {
    setup(pipeline);
}

export function onSettingsChanged(state: WorldState) {
    setupSettings(state.rendererConfig());
}

export function getBlockId(block: BlockState): number {
    // This runs in runtime when block changes, so it should be optimized
    return getType(block);
}

export function beginFrame(state: WorldState) {
    autoExposureState.setEnabled(Settings.AutoExposureEnabled);

    settingsBuffer.uploadData();
    if (debugBuffer) {
        debugBuffer.uploadData();

        if (KeyInput.onKeyDown(Keys.E)) {
            toggleBoolSetting("_DebugEnabled");
            if (getBoolSetting("_DebugEnabled")) {sendInChat("Debug mode enabled, may need reload to work");}
        }

        if (KeyInput.onKeyDown(Keys.F)) {
            setIntSetting("PBRMode", getIntSetting("PBRMode") == 0 ? 1 : 0);
            if (getIntSetting("PBRMode") == 0) {
                sendInChat("Reduced PBR");
            } else if (getIntSetting("PBRMode") == 1) {
                sendInChat("Full PBR");
            }
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