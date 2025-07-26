export default function configureOptions() {
    setHidden("_ShowShadowMap", getBool("ShadowsEnabled"));
    setHidden("LabelSoftShadows", getInt("ShadowFilter") != 2);
    setHidden("ShadowSoftness", getInt("ShadowFilter") != 2);
    setHidden("ShadowSamples", getInt("ShadowFilter") != 2);

    setHidden("Tonemap1", !getBool("CompareTonemaps"));
    setHidden("Tonemap2", !getBool("CompareTonemaps"));
    setHidden("Tonemap3", !getBool("CompareTonemaps"));
    setHidden("Tonemap4", !getBool("CompareTonemaps"));

    setHidden("StarAmount", getInt("Stars") == 0);
    setHidden("AtmosphereExtra", getInt("Sky") == 0);

    setHidden("ExposureSpeed", getInt("AutoExposure") == 0);
    setHidden("ExposureSamplesX", getInt("AutoExposure") == 0);

    setHidden("SunraysSamples", getInt("SunraysSamplesOverride") != -1);
    setHidden("SunraysFakeSamples", getInt("SunraysSamplesOverride") != -1);
}