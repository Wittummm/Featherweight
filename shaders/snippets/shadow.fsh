#if SHADOWS == 1
	const float baseSoftness = 0.002;
	const float timeBias = 0.5;

	float shadowStrength = min(((lightAngle()+timeBias)*1.5)-timeBias, 1);
	
if (shadowStrength > 0.05) {
	float zBias = Z_BIAS;
	if (renderStage == MC_RENDER_STAGE_ENTITIES) {
		zBias *= 0.7;
	}
	//CREDIT: Pixelization *inspired* by Miniature!
	vec3 roundedWorldPos = playerPos + cameraPosition;
	if (SHADOW_PIXELIZATION < 1 && SHADOW_PIXELIZATION > 0) {
		roundedWorldPos += 0.001; // Bias to fix jittering cuz floating point imprecision
		roundedWorldPos = floor(roundedWorldPos/SHADOW_PIXELIZATION)*SHADOW_PIXELIZATION;
	}
	const vec3 roundedPlayerPos = roundedWorldPos - cameraPosition;
	const vec4 shadowViewPos = shadowModelView * vec4(roundedPlayerPos, 1);
	const vec4 oldShadowClipPos = shadowProjection * shadowViewPos;
	const vec3 shadowClipPos = distortShadow(oldShadowClipPos.xyz);
	const vec3 shadowNdcPos = shadowClipPos.xyz / oldShadowClipPos.w;
	const vec3 screenPos = (shadowNdcPos + 1) * 0.5;

	if (screenPos.x < 1 && screenPos.y < 1 && screenPos.z < 1 &&
	screenPos.x > 0 && screenPos.y > 0 && screenPos.z > 0) {
		// Distorts z bias
		const float distortion = (length(oldShadowClipPos.xyz))/(length(shadowClipPos));
		zBias *= 1+(max(dot(vertNormal, lightDir), 0)); // Applies more bias on parallel surfaces
		zBias /= distortion; // Counter distorts zbias
		zBias *= 1+(pow(((length(shadowNdcPos.xyz)+1)*4)-1, 2)*0.25); // Not battle tested
		
		// TODOMAYBE: remember to distort or something, IDK
		#if SHADOW_FILTER == Linear || SHADOW_FILTER == Nearest
			float shadow = sampleShadow(screenPos, playerPos, zBias);
		#elif SHADOW_FILTER == PCF
			float shadow = sampleShadowPCF(screenPos, playerPos, zBias);
		#elif SHADOW_FILTER == FixedSamplePCSS || SHADOW_FILTER == VariableSamplePCSS
			float shadow = sampleShadowPCSS(screenPos, playerPos, zBias);
		#endif

		// shade = max(shadow*AMBIENT_STRENGTH*visiblity, shade);
 		shade = max(shadow*AMBIENT_STRENGTH, shade);
	}
}
#endif