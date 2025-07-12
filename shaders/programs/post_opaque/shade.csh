#version 460 core
layout (local_size_x = 16, local_size_y = 16) in;

#include "/includes/shared/shared.glsl"

#include "/includes/func/buffers/gbuffer.glsl"
#include "/includes/func/buffers/data0.glsl"
#include "/includes/func/depthToViewPos.glsl"
#include "/includes/lib/math_lighting.glsl"
#include "/includes/func/color/srgb.glsl"
#include "/includes/func/atmosphere/calcSky.glsl"

uniform sampler2D solidDepthTex;
uniform usampler2D dataTex0;

layout(SCENE_FORMAT) uniform image2D sceneImg;
#ifdef PBREnabled
layout(GBUFFER_FORMAT) uniform uimage2D gbufferImg;
#endif

void main() {
	ivec2 pixelPos = ivec2(gl_GlobalInvocationID.xy);
    if (any(greaterThanEqual(pixelPos, ivec2(ap.game.screenSize)))) return;
    vec2 fragCoord = vec2(pixelPos) / ap.game.screenSize;
    
	vec4 Color = readScene(imageLoad(sceneImg, pixelPos));

	float depth = texelFetch(solidDepthTex, pixelPos, 0).r;
    vec3 viewPos = depthToViewPos(fragCoord, depth);
    bool isSky = depth >= 1;

    if (!isSky) {
		vec3 normals; vec2 lightLevel = vec2(0);
		readData0(texelFetch(dataTex0, pixelPos, 0), normals, lightLevel);

		vec4 gbuffer0 = gbuffer0Default; vec4 gbuffer1 = gbuffer1Default; 
		#ifdef PBREnabled
		if (PBR != 0) readGBuffer(imageLoad(gbufferImg, pixelPos), gbuffer0, gbuffer1);
		#endif
		Material material = Mat(Color.rgb, normals, gbuffer0, gbuffer1);

		float shadow;
		bool shouldUpdate = shade(Color, material, lightLevel, viewPos, shadow);
		#ifdef PBREnabled
		if (shouldUpdate) {
			writeMaterial(material, gbuffer0, gbuffer1);
			imageStore(gbufferImg, pixelPos, writeGBuffer(gbuffer0, gbuffer1).rgrg);
		} 
		
		#endif
	} else {
		/* POINTs:
		Both sky basic and sky textured writes as non hdr
		(but does compensate for hdr, specifclly sky textured does)

		We make it hdr here
		*/

		// TEMP HDR_REALISTIC_VALUES:
		Color.rgb += calcSky(normalize(viewPos), Color.rgb*0.5); // 0.5 looks better for vanilla sky
		Color.rgb *= AmbientColor.a;
	}

    imageStore(sceneImg, pixelPos, writeScene(Color));
}