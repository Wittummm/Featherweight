import { Vec4, Vec3, Vec2 } from './modules/Vector';
import { FixedBuiltStreamingBuffer, FixedStreamingBuffer } from './modules/FixedBuiltStreamingBuffer';
import { Settings } from './modules/Settings';
import { KeyInput } from './modules/KeyInput';
import { toggleBoolSetting } from './modules/HelperFuncs';

// Consts
const DEBUG_CONFIG = {
    debug: true,
    outputToChat: true,
}
// Variables
let debugBuffer: FixedBuiltStreamingBuffer | null;
let settingsBuffer: FixedBuiltStreamingBuffer;

//// Helper Funcs ////
function setupSettings(state?: WorldState) {
    worldSettings.sunPathRotation = Settings.sunPathRotation;
    worldSettings.ambientOcclusionLevel = 1.0;
    worldSettings.mergedHandDepth = true; 
    worldSettings.shadowMapDistance = 64;

    settingsBuffer
    .vec3(1, 1, 1) // TODONOW: maybe allow tinting of these
    .vec4(1, 1, 1, 1) // TODONOW: maybe allow tinting of these
    .int("ShadowSamples")
    .int("ShadowFilter")
    .bool("PresetPatternsPCF")
    .float("ShadowDistort")
    .float("Pixelization")
    .int("Specular")
    .end()

    if (debugBuffer) {
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
        .end()
    }
}

function setup() {    
    //// Declarations
    let sceneTexture = new Texture("sceneTex").imageName("sceneImg").format(Format.RGBA16F).build();
    let gbufferTexture = new Texture("gbufferTex").imageName("gbufferImg").format(Format.RG32UI).build();

    /////// Helper Funcs ///////////
    function terrainProgram(usage: ProgramUsage, name: string, programName?: string): ObjectShader {
        return new ObjectShader(programName || name, usage)
        .vertex(`programs/geometry/${name}.vsh`)
        .fragment(`programs/geometry/${name}.fsh`)
        .target(0, sceneTexture)
        .target(1, gbufferTexture).blendOff(1)
    }
    function bindSettings<T>(program: T): T {
        return program.ssbo(0, settingsBuffer.buffer);
    }
    /////// Actual Functions ////////
    function setupResources() {
        debugBuffer = getBoolSetting("_DebugEnabled") ? new FixedStreamingBuffer().bool().bool().bool().int().int().int().int().int().int().int().int().int().bool().build() : null;
        settingsBuffer = new FixedStreamingBuffer().vec3().vec4().int().int().bool().float().float().int().build();
    }
    function setupPrograms() {
        // TODONOW: register init here(settings.csh)
        registerShader(Stage.POST_RENDER, bindSettings(new Compute("init_settings"))
            .location("programs/init/settings.csh").workGroups(1,1,1).build()); 

        registerShader(terrainProgram(Usage.TERRAIN_SOLID, "geometry_main", "terrain_solid")
            .blendOff(0).build()
        );
        registerShader(terrainProgram(Usage.TERRAIN_CUTOUT, "geometry_main", "terrain_cutout")
            .blendOff(0)
            .define("CUTOUT", "1").build()
        );
        registerShader(terrainProgram(Usage.TERRAIN_TRANSLUCENT, "geometry_main", "terrain_translucent")
            .define("TRANSLUCENT", "1").build()
        );
        registerShader(Stage.POST_RENDER, bindSettings(new Compute("shade"))
            .location("programs/post_render/shade.csh")
            .workGroups(Math.ceil(screenWidth/16), Math.ceil(screenHeight/16), 1).build()
        ); 

        enableShadows(512, 1)
        registerShader(bindSettings(new ObjectShader("shadow", Usage.SHADOW)) // TODONOW: separate for cutout to early z check
            .vertex(`programs/geometry/shadow.vsh`)
            .fragment(`programs/geometry/shadow.fsh`)
            .define("CUTOUT", "")
            .build()
        )

        if (debugBuffer) {
            registerShader(Stage.POST_RENDER, bindSettings(new Compute("debug"))
                .location("programs/post_render/debug.csh")
                .workGroups(Math.ceil(screenWidth/16), Math.ceil(screenHeight/16), 1)
                .ubo(0, debugBuffer.buffer).build()
            ); 
        }
    }

    setupResources();
    setupPrograms();
    setupSettings();
}

/////// Aperture Pipeline ///////
export function onSettingsChanged(state: WorldState) {
    setupSettings(state);
}

export function setupShader(dimension: NamespacedId) {
    setup()
    setCombinationPass(new CombinationPass("programs/finalize/final.fsh").build());
    ///////////////////////////

    if (DEBUG_CONFIG.debug) {
        function dumpDebugInfo(chat: boolean = false) {
            let output = chat ? sendInChat : print;
            // output("Hellow World");
        }

        dumpDebugInfo(DEBUG_CONFIG.outputToChat);
    }
}

export function setupFrame(state: WorldState) {
    settingsBuffer.uploadData();
    if (debugBuffer) {
        debugBuffer.uploadData();
    }


    if (KeyInput.onKeyDown(Keys.E)) {
        toggleBoolSetting("_DebugEnabled");
        if (getBoolSetting("_DebugEnabled")) {sendInChat("Debug mode enabled, may need reload to work");}
    }

    if (KeyInput.onKeyDown(Keys.LEFT)) {setIntSetting("SunPathRotation", getIntSetting("SunPathRotation") - 5);}
    if (KeyInput.onKeyDown(Keys.RIGHT)) {setIntSetting("SunPathRotation", getIntSetting("SunPathRotation") + 5);}

    KeyInput.update(); // Must be last
}

// export function getBlockId(block: BlockState) {
//     // Idk what this does, but aperture has it
// }
