import { Vec4, Vec3, Vec2 } from './Vector';

export const distancePerShadowCascade = 95.5;

export class Settings {
    private constructor() {}
    static get SunPathRotation() {
        return getIntSetting("SunPathRotation");
    }
    static get ShadowsEnabled() {
        return getBoolSetting("ShadowsEnabled");
    }
    static get ShadowSamples() {
        let t = getFloatSetting("ShadowSamples");
        if (t < 0) {
            let softness = getFloatSetting("ShadowSoftness");
            // Generated via manually plotting softness&sample correlation
            t = -t;
            t = t * Math.floor(8 * Math.pow(softness, 0.87));
            t = Math.max(t, 1);
        }

        return t;
    }
    static get ExposureSamples() {
        let exposureSamplesX = getIntSetting("ExposureSamplesX");
        let exposureSamplesY = Math.floor(exposureSamplesX * (screenHeight/screenWidth));
        
        return new Vec2(exposureSamplesX, exposureSamplesY);
    }
    static get ShadowCascadeCount() {
        let shadowCascadeCount = getIntSetting("ShadowCascadeCount");
        if (shadowCascadeCount <= 0) {
            shadowCascadeCount = Math.ceil(worldSettings.shadow.distance/distancePerShadowCascade); 
        }
        return shadowCascadeCount;
    }
    static get PBREnabled() {
        return getBoolSetting("PBR");
    }
    static get PBR() {
        return Settings.PBREnabled ? getIntSetting("PBRMode") + 1 : 0;
    }
    static get ShadingEnabled() {
        return getBoolSetting("Shading");
    }
}