#version 460 core
layout (local_size_x = 16, local_size_y = 16) in;

#include "/includes/shared/shared.glsl"

#include "/includes/func/buffers/gbuffer.glsl"
#include "/includes/func/depthToViewPos.glsl"
#include "/includes/lib/math_lighting.glsl"
#include "/includes/func/color/srgb.glsl"
#include "/includes/func/atmosphere/calcSky.glsl"

uniform sampler2D sceneTex;
uniform usampler2D gbufferTex;
uniform sampler2D solidDepthTex;

layout(SCENE_FORMAT) uniform image2D sceneImg;
layout(rg32ui) uniform uimage2D gbufferImg;

void main() {
    if (any(greaterThanEqual(gl_GlobalInvocationID.xy, ap.game.screenSize))) return;
	ivec2 pixelPos = ivec2(gl_GlobalInvocationID.xy);
    vec2 fragCoord = vec2(gl_GlobalInvocationID.xy) / ap.game.screenSize;
    
    vec4 Color = readScene(texelFetch(sceneTex, pixelPos, 0));

	float depth = texelFetch(solidDepthTex, pixelPos, 0).r;
    vec3 viewPos = depthToViewPos(fragCoord, depth);
    bool isSky = depth >= 1;

    if (!isSky) {
		vec2 lightLevel = vec2(1); // TODONOW: implement this

		vec4 gbuffer0; vec4 gbuffer1; readGBuffer(texelFetch(gbufferTex, pixelPos, 0).rg, gbuffer0, gbuffer1);
		Material material = Mat(Color.rgb, gbuffer0, gbuffer1);

		float shadow;
		bool shouldUpdate = shade(Color, material, lightLevel, viewPos, shadow);
		if (shouldUpdate) {
			writeMaterial(material, gbuffer0, gbuffer1);
			imageStore(gbufferImg, pixelPos, writeGBuffer(gbuffer0, gbuffer1).rgrg);
		} 
	} else {
		Color.rgb += calcSky(normalize(viewPos));
	}

    imageStore(sceneImg, pixelPos, writeScene(Color));
}