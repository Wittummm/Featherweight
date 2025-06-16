/*
    Emulates Aperture's setting builder but adds lang file support
*/
const formattedSettings: (BoolSetting | IntSetting | FloatSetting | StringSetting)[] = [];

export class FormattedSetting {
    settingName: string
    nameDisplay?: string // option.[this.name] = nameDisplay
    valueDisplay: string[] = [] // value.[this.name].[index] = valueDisplay[index]
    valuePrefix?: string // prefix.[this.name]
    valueSuffix?: string // suffix.[this.name]
    description?: string // option.[this.name].comment

    name(displayName: string): this {this.nameDisplay = displayName; return this;};
    values(...displayValues: string[]): this {this.valueDisplay = displayValues; return this;};
    prefix(prefix: string): this {this.valuePrefix = prefix; return this;};
    suffix(suffix: string): this {this.valueSuffix = suffix; return this;};
    desc(desc: string): this {this.description = desc; return this;};
}

export class BoolSetting extends FormattedSetting {
    constructor(name: string, defaultValue: boolean, needsReload: boolean) {
        super();
        this.settingName = name;
        this.value = defaultValue;
        this.reload = needsReload;

        formattedSettings.push(this);
    }
    private value: boolean;
    _values = [false, true]
    reload: boolean = true;

    // Bool has no value display
    override values() {return this};
    override prefix() {return this};
    override suffix() {return this};
}
export class IntSetting extends FormattedSetting  {
    constructor(name: string, values: number[]) {
        super();
        this.settingName = name;
        this._values = values;
        formattedSettings.push(this);
    }
    private value: number;
    _values: number[]
    reload: boolean = true;

    needsReload(reload: boolean): IntSetting { this.reload = reload; return this; }
    build(defaultValue: number): BuiltSetting { this.value = defaultValue; return this; }
}
export class FloatSetting extends FormattedSetting  {
    constructor(name: string, values: number[]) {
        super();
        this.settingName = name;
        this._values = values;
        formattedSettings.push(this);
    }
    private value: number;
    _values: number[]
    reload: boolean = true;

    needsReload(reload: boolean): FloatSetting { this.reload = reload; return this; }
    build(defaultValue: number): BuiltSetting { this.value = defaultValue; return this; }
}
export class StringSetting extends FormattedSetting  {
    constructor(name: string, values: string[]) {
        super();
        this.settingName = name;
        this._values = values;
        formattedSettings.push(this);
    }
    private value: string;
    _values: string[]
    reload: boolean = true;

    needsReload(reload: boolean): StringSetting { this.reload = reload; return this; }
    build(defaultValue: string): BuiltSetting { this.value = defaultValue; return this; }
}
export class BuiltSetting { }

export class Page {
    constructor(name: string) { }

    add(...settings): Page { return this; };
    build(): BuiltPage { return this; };
}
export class BuiltPage { }

export function asInt(name: string, ...values: number[]): IntSetting {return new IntSetting(name, values)};
export function asFloat(name: string, ...values: number[]): FloatSetting {return new FloatSetting(name, values)};
export function putTextLabel(id: string, text: string): void {};
export function putTranslationLabel(id: string, text: string): void {};
export function asString(name: string, ...values: string[]): StringSetting {return new StringSetting(name, values)};
export function asBool(name: string, defaultValue: boolean, reload: boolean): BoolSetting {return new BoolSetting(name, defaultValue, reload)};

export var EMPTY: BuiltPage = null;

// Generate lang file here //

import * as fs from "fs";
import * as path from 'path';

export function generateLang() {
    let generated = "# Auto generated using `/build/generateLang.ts` (Featherweight)\n\n";

    for (let setting of formattedSettings) {
        const settingName = setting.settingName;
        let edited = false;

        if (setting.nameDisplay) {
            let displayName = setting.reload ? `§o${setting.nameDisplay}§r`: setting.nameDisplay; // Italic

            generated += `option.${settingName} = ${displayName}\n`; 
            edited = true;
        }
        if (setting.description) {generated += `option.${settingName}.comment = ${setting.description}\n`; edited = true;}
        if (setting.valuePrefix) {generated += `prefix.${settingName} = ${setting.valuePrefix}\n`; edited = true;}
        if (setting.valueSuffix) {generated += `suffix.${settingName} = ${setting.valueSuffix}\n`; edited = true;}

        for (let i = 0; i < setting.valueDisplay.length; i++) {
            generated += `value.${settingName}.${setting._values[i]} = ${setting.valueDisplay[i]}\n`
            edited = true;
        }

        if (edited) {generated += "\n";}
    }

    fs.writeFileSync(path.join(__dirname, '..') + '/shaders/lang/en_us.lang', generated);
    
    console.log("Generated the Lang file.")
}
