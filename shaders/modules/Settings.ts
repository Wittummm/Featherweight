import { Vec4, Vec3, Vec2 } from './Vector';

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
}