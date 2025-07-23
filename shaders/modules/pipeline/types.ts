import { addType } from "../BlockType";

export default function createTypes() {
    // defineGlobally("isType(blockId, tag)", "(iris_getCustomId(blockId) == tag)"); // This doesnt seem to work currently :(

    addType("water", "minecraft:water", "minecraft:flowing_water");
}