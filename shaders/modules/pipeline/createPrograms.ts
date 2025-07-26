import { Settings } from "../Settings";
import { Buffers, States, Textures } from "./resources/objects";

const defaultComposite = "programs/template/composite.vsh"

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

export default function createPrograms(pipeline: PipelineConfig, textures: Textures, buffers: Buffers, states: States) {
    const init = pipeline.forStage(Stage.PRE_RENDER);
    bindMetadata(bindSettings(
        init.createCompute("init_settings")
            .location("programs/pre_render/settings.csh").workGroups(1, 1, 1)
    )).compile();
    init.barrier(SSBO_BIT);

    bindSettings(
        init.createComposite("clear_textures")
            .vertex(defaultComposite)
            .fragment("programs/pre_render/clear_textures.fsh")
            .target(0, textures.scene)
    ).compile();
    init.end();

    // Terrain
    gbuffersProgram(Usage.TERRAIN_SOLID, "geometry_main", "terrain_solid")
        .define("TERRAIN", "")
        .blendOff(0).compile()

    gbuffersProgram(Usage.TERRAIN_CUTOUT, "geometry_main", "terrain_cutout")
        .define("TERRAIN", "")
        .blendOff(0)
        .define("CUTOUT", "").compile()

    gbuffersProgram(Usage.TERRAIN_TRANSLUCENT, "geometry_main", "terrain_translucent")
        .define("TERRAIN", "")
        .define("FORWARD", "").compile()

    // Entities
    gbuffersProgram(Usage.ENTITY_SOLID, "geometry_main", "entity_solid")
        .blendOff(0).compile()

    gbuffersProgram(Usage.ENTITY_CUTOUT, "geometry_main", "entity_cutout")
        .blendOff(0)
        .define("CUTOUT", "").compile()

    gbuffersProgram(Usage.ENTITY_TRANSLUCENT, "geometry_main", "entity_translucent")
        .define("FORWARD", "").compile()

    // Sky
    bindSettings(
        pipeline.createObjectShader("sky_textured", Usage.SKY_TEXTURES)
            .vertex("programs/geometry/sky_textured.vsh")
            .fragment("programs/geometry/sky_textured.fsh")
            .target(0, textures.scene)
            .blendFunc(0, Func.ONE, Func.ONE, Func.ONE, Func.ONE)
    ).compile();


    bindSettings(
        pipeline.createObjectShader("sky_basic", Usage.SKYBOX)
            .vertex("programs/geometry/sky_basic.vsh")
            .fragment("programs/geometry/sky_basic.fsh")
            .target(0, textures.scene)
    ).compile();

    // Deferred
    const preTranslucent = pipeline.forStage(Stage.PRE_TRANSLUCENT);
    lightingDefines(bindSettings(
        preTranslucent.createCompute("shade")
            .location("programs/post_opaque/shade.csh")
            .workGroups(Math.ceil(screenWidth / 32), Math.ceil(screenHeight / 8), 1)
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

    if (getBoolSetting("SunraysEnabled")) {
        bindMetadata(bindSettings(
            postRender.createCompute("sunrays").state(states.sunrays)
                .location("programs/post_render/sunrays.csh")
                .workGroups(Math.ceil(screenWidth / 32), Math.ceil(screenHeight / 8), 1)
        )).compile();
    }

    /// Auto Exposure ///
    if (Settings.AutoExposureEnabled) {
        postRender.generateMips(textures.scene);

        bindMetadata(bindSettings(
            postRender.createCompute("auto_exposure")
                .state(states.autoExposure)
                .location("programs/post_render/auto_exposure.csh")
                .workGroups(1, 1, 1)
                .define("ExposureSamplesX", Settings.ExposureSamples.x.toString())
                .define("ExposureSamplesY", Settings.ExposureSamples.y.toString())
        )).compile();
    }

    if (buffers.debug) {
        bindMetadata(lightingDefines(bindSettings(
            postRender.createCompute("debug").state(states.debug)
                .location("programs/post_render/debug.csh")
                .workGroups(Math.ceil(screenWidth / 16), Math.ceil(screenHeight / 16), 1)
                .ubo(1, buffers.debug.buffer)
        ))).compile();
    }
    postRender.end();
    /////////////////////

    bindMetadata(bindSettings(pipeline.createCombinationPass("programs/finalize/final.fsh"))).compile();

    /// Helper Functions ///

    function gbuffersProgram(usage: ProgramUsage, name: string, programName?: string): ObjectShader {
        let program = pipeline.createObjectShader(programName || name, usage);
        lightingDefines(program);

        bindSettings(program)
            .vertex(`programs/geometry/${name}.vsh`)
            .fragment(`programs/geometry/${name}.fsh`)
            .target(0, textures.scene)
            .target(2, textures.data0)
        if (textures.gbuffer) { program.target(1, textures.gbuffer).blendOff(1); }

        return program;
    }

    function bindMetadata<T extends Shader<any, any>>(program: T): T {
        return program.define("INCLUDE_METADATA", "").ssbo(0, buffers.metadata);
    }
    function bindSettings<T extends Shader<any, any>>(program: T): T {
        return bindMetadata(program).define("INCLUDE_SETTINGS", "").ubo(0, buffers.settings.buffer);
    }



}