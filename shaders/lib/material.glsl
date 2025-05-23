#include "/lib/pbr.glsl"

struct Material {
    float roughness;
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
Material Mat(vec3 albedo, vec4 gbuffer0, vec4 gbuffer1) {
    float roughness = roughnessRead(gbuffer0.r);
    float reflectance = gbuffer0.g;
    bool isPorosity = false;
    float porosity = porosityRead(gbuffer0.b, isPorosity);
    float emission = emissionRead(gbuffer0.a);
    // Cannot `eyePlayerSpace -> viewSpace` have to `eyePlayerSpace -> playerSpace -> viewSpace`
    vec3 normals = mat3(gbufferModelView) * normalsRead(gbuffer1.rg);

    return Material(roughness, normals, isPorosity ? porosity : -1, !isPorosity ? porosity : -1, emission,0,0.0, reflectanceRead(reflectance, albedo), getMetallic(reflectance));
}