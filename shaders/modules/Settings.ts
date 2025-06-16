import { Vec4, Vec3, Vec2 } from './Vector';

export class Settings {
    private constructor() {}
    static get sunPathRotation(): number {
        return getIntSetting("SunPathRotation");
    }
}