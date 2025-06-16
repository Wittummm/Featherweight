export function toggleBoolSetting(name: string) {
    setBoolSetting(name, !getBoolSetting(name));
}