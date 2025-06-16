#ifndef pbr_glsl
#define pbr_glsl

///////////////////////////////////////

// Roughness
float roughnessRead(float smoothness) {
    return pow(1.0 - smoothness, 2.0);
}
float roughnessWrite(float roughness) {
    return 1.0 - sqrt(roughness);
}

/// Emission
float emissionRead(float emission) {
    return emission < 1 ? emission : 0;
}

bool isPorosity(float porosity) {
    return porosity < 0.25098039215686274;
}

// Porosity/SSS
float porosityRead(float porosity, out bool _isPorosity) {
    _isPorosity = isPorosity(porosity);

    return _isPorosity ? porosity*3.984375 : (porosity-0.25098039215686274)*1.3350785340314135;
}

#include "/includes/func/packing/encodeNormals.glsl"

float getMetallic(float reflectance) {
    return reflectance > 0.9 ? 1 : 0;
}

// Reflectance
vec3 reflectanceRead(float reflectance, vec3 albedo, int medium) {
    if (reflectance < 0.9) { // is non metal
        return vec3(reflectance) * 1.10869565218;
    } else {
        int value = int(reflectance * 255 + 0.5);

        // Precomputed values using N and K
        switch(medium) {
        case 0: // Air IOR: 1
            switch(value) {
            case 230: // Iron
                return vec3(0.5312288403511047, 0.512357234954834, 0.4958285689353943);
            case 231: // Gold
                return vec3(0.9442299604415894, 0.7761021256446838, 0.3734020590782165);
            case 232: // Aluminium
                return vec3(0.9122980237007141, 0.9138506054878235, 0.9196805953979492);
            case 233: // Chrome
                return vec3(0.5555968284606934, 0.5545371174812317, 0.5547794103622437);
            case 234: // Copper
                return vec3(0.9259521961212158, 0.7209016680717468, 0.5041542053222656);
            case 235: // Lead
                return vec3(0.6324838399887085, 0.6259370446205139, 0.6414788961410522);
            case 236: // Platinum
                return vec3(0.6788492202758789, 0.6424005627632141, 0.5884096026420593);
            case 237: // Silver
                return vec3(0.9620000123977661, 0.9494680762290955, 0.922115683555603);
            case 238: // Titanium
                return vec3(0.6116827726364136, 0.548520565032959, 0.5741969347000122);
            case 239: // Brass
                return vec3(0.8771779537200928, 0.49339383840560913, 0.7472696304321289);
            default:
                return albedo*reflectance;
            }
        case 1: // Water IOR: 1.333
            switch(value) {
            case 230: // Iron
                return vec3(0.4367085099220276, 0.4161258339881897, 0.4009260833263397);
            case 231: // Gold
                return vec3(0.9304231405258179, 0.7383231520652771, 0.2998349070549011);
            case 232: // Aluminium
                return vec3(0.8861957788467407, 0.8886891007423401, 0.8969180583953857);
            case 233: // Chrome
                return vec3(0.46233054995536804, 0.4608496129512787, 0.46598532795906067);
            case 234: // Copper
                return vec3(0.9073523879051208, 0.6697537302970886, 0.42809250950813293);
            case 235: // Lead
                return vec3(0.5540546774864197, 0.5475188493728638, 0.5686939358711243);
            case 236: // Platinum
                return vec3(0.6035163998603821, 0.5638218522071838, 0.5065435171127319);
            case 237: // Silver
                return vec3(0.9518781900405884, 0.9374012351036072, 0.9076853394508362);
            case 238: // Titanium
                return vec3(0.526247501373291, 0.4593830704689026, 0.48603615164756775);
            case 239: // Brass
                return vec3(0.8475667834281921, 0.4316805899143219, 0.7012713551521301);
            default:
                return albedo*reflectance*0.7501875468867217; // Nerf by 1/1.333(Arbitrary)
            }
        }
    }
}
vec3 reflectanceRead(float reflectance, vec3 albedo) {
    return reflectanceRead(reflectance, albedo, 0);
}
float reflectanceWriteFromF0(float f0) {
    return f0*0.8980392156862745;
}


#endif