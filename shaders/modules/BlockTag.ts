function autoName(name: string|null, internalName: string) {
    return name ? name : ("TAG_"+internalName.toUpperCase());
}

let outputTags = false;

export function dumpTags(bool: boolean) {
    outputTags = bool;
}

export class Tagger {
    private static index: number = 0;
    private static nameIndexMap: [string?: number] = [];

    static tagNamespace(namespace: NamespacedId, name?: string) {
        if (this.index >= 32) {throw new RangeError(`Tag index is more than 32: ${this.index}`)}
        name = autoName(name, namespace.getNamespace());
        if (Tagger.nameIndexMap[name]) {throw new Error(`Duplicate tag: ${name}`)}
        if (outputTags) {sendInChat(`${this.index} ${name}`);}

        addTag(this.index, namespace);
        defineGlobally(name, this.index);
        this.index++;
    }
    static tag(namespace: string, value?: string, name?: string) {
        name = autoName(name, value ? value : namespace);
        this.tagNamespace(value ? new NamespacedId(namespace, value) : new NamespacedId(namespace), name);
    }
    static tags(name: string|null, namespace: string, ...values: string[]) {
        name = autoName(name, namespace);

        let namespaces = [];
        for (let value of values) {
            namespaces.push(new NamespacedId(value));
        }

        this.tagNamespace(createTag(new NamespacedId(namespace), ...namespaces), name);
    }
}

export const mc = "minecraft";
export const sh = "shader";
export const ap = "aperture";