/*
Potential issue: I dont think this supports handling the same block with different properties
*/

let index = 1; // 0 reserved for undefined type
const namespacedIdData: [
    string?: {
        id: number,
        properties: string[][],
    }
] = [];

export function addType(type: string, ...paths: string[]) {
    defineGlobally("TYPE_"+type.toUpperCase(), index);

    for (let path of paths) {
        let splits = path.split(":")
        let namespacedId = splits[0]+":"+splits[1];

        let properties = [];
        for (let part of splits) {
            if (part.includes("=")) {
                let sepIndex = part.indexOf("=");
                let property = part.substring(0, sepIndex);
                let values = part.substring(sepIndex+1);

                properties[property] = values.split(",");
            }
        }

        namespacedIdData[namespacedId] = {id: index, properties: properties};
    }
    index++;
}

export function getType(blockState: BlockState) {
    let data = namespacedIdData[blockState.getNamespace()+":"+blockState.getName()];
    
    if (data !== undefined) {
        let doesNotMatch = false;
        for (let [property, values] of data.properties.entries()) {
            if (blockState.hasState(property)) {
                for (let value in values) {
                    doesNotMatch = (blockState.getState(property) != value);
                }
            }
        }

        if (!doesNotMatch) {
            return data.id < 4096 ? data.id : 0; // Limited to 2^12, because i doubt anyone would have more
        }
    }
    return 0;
}
