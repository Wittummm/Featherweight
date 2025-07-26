import configureOptions from "./modules/pipeline/configureOptions";
import createSettings from "./modules/pipeline/createOptions";

export function setupOptions() {
    return createSettings();
}
export function onSettingsChanged() {
    configureOptions();
}
