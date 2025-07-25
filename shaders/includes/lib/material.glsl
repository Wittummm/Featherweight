#include "/includes/lib/pbr.glsl"

struct Material {
    vec3 albedo;
    float roughness;
    vec3 baseNormals; // NOTE!: This is in viewSpace where as gbuffers store normals in playerSpace
    vec3 normals; // NOTE!: This is in viewSpace where as gbuffers store normals in playerSpace
    float porosity; // Not physically based
    float sss; // Currently unimplemented
    float emission;
    float ao; // Currently unsupported
    float height; // Currently unsupported
    vec3 f0;
    float metallic;
};

// PIN: This parses the gbuffers into actual useable data
Material Mat(vec3 albedo, vec3 baseNormals, vec4 gbuffer0, vec4 gbuffer1) {
    float roughness = roughnessRead(gbuffer0.r);
    float reflectance = gbuffer0.g;
    bool isPorosity = false;
    float porosity = porosityRead(gbuffer0.b, isPorosity);
    float emission = emissionRead(gbuffer0.a);
    vec3 normals = mat3(ap.camera.view) * (gbuffer1.r <= -1 ? baseNormals : normalsRead(gbuffer1.rg));

    return Material(albedo, roughness, mat3(ap.camera.view)*baseNormals, normals, isPorosity ? porosity : -1, !isPorosity ? porosity : -1, emission,0,0.0, reflectanceRead(reflectance, albedo), getMetallic(reflectance));
}

#ifdef PBREnabled
#ifdef INCLUDE_READ_GBUFFER
Material Mat(vec3 albedo, vec3 baseNormals, uvec4 gbuffer) {
    vec4 gbuffer0; vec4 gbuffer1; readGBuffer(gbuffer, gbuffer0, gbuffer1);
    return Mat(albedo, baseNormals, gbuffer0, gbuffer1);
}
#endif
#endif