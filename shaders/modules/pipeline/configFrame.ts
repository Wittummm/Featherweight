import { toggleBoolSetting } from "../HelperFuncs";
import KeyInput from "../KeyInput";
import { Settings } from "../Settings";
import { Buffers, States, Textures } from "./resources/objects";

export default function configFrame(textures: Textures, buffers: Buffers, states: States) {
    states.autoExposure.setEnabled(Settings.AutoExposureEnabled);
    states.sunrays.setEnabled(getBoolSetting("SunraysEnabled"));
    states.debug.setEnabled(getBoolSetting("_DebugEnabled"));

    buffers.settings.uploadData();
    if (buffers.debug) {
        buffers.debug.uploadData();

        if (KeyInput.onKeyDown(Keys.E)) {
            toggleBoolSetting("_DebugEnabled");
            if (getBoolSetting("_DebugEnabled")) {sendInChat("Debug mode enabled, may need reload to work");}
        }

        if (KeyInput.onKeyDown(Keys.F)) {
            setIntSetting("PBRMode", getIntSetting("PBRMode") == 0 ? 1 : 0);
            if (getIntSetting("PBRMode") == 0) {
                sendInChat("Reduced PBR");
            } else if (getIntSetting("PBRMode") == 1) {
                sendInChat("Full PBR");
            }
        }

        if (KeyInput.onKeyDown(Keys.LEFT)) {setIntSetting("SunPathRotation", getIntSetting("SunPathRotation") - 5);}
        if (KeyInput.onKeyDown(Keys.RIGHT)) {setIntSetting("SunPathRotation", getIntSetting("SunPathRotation") + 5);}

        // KeyInput.update() is NOT cheap, it is currently 0.5 ms on my machine so beware!!!
        KeyInput.update(); // Must be last
    }
}