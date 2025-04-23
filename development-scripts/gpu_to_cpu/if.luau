local source = [[
        if (biome == BIOME_OCEAN) {
			0.6
		} else if (biome == BIOME_FROZEN_OCEAN) {
            0.66
		} else if (biome == BIOME_WARM_OCEAN || biome == BIOME_LUKEWARM_OCEAN || biome == BIOME_COLD_OCEAN) {
			0.4
		} else if (biome == BIOME_DEEP_OCEAN || biome == BIOME_DEEP_LUKEWARM_OCEAN || biome == BIOME_DEEP_COLD_OCEAN) {
			0.8
		} else if (biome == BIOME_DEEP_FROZEN_OCEAN) {
			1.1
		} else if (biome == BIOME_RIVER) {
            0.4
		} else if (biome == BIOME_SWAMP) {
			0.3
		} else if (biome == BIOME_MANGROVE_SWAMP) {
			0.35
		} else if (biome == BIOME_BEACH || biome == BIOME_SNOWY_BEACH) {
            0.5
		} else if (biome == BIOME_STONY_SHORE) {
            0.55
		}
]]

local conditionPattern = "[%w%s=_-|&+]*"
local result = ""
local cursor = 1
local ifCount = 0
while cursor < #source do
    local ifPos, length = string.find(source, "if", cursor)

    if not ifPos then
        local elsePos = string.find(source, "else", cursor)
        cursor = elsePos
        local value = string.match(source, "{%s*([%w%.]+)%s*}", cursor)
        result ..= `{value}{string.rep(")", ifCount)}`
        break
    else
        ifCount += 1
        cursor = ifPos+1
        local condition = string.match(source, `%(%s*({conditionPattern})%s*%)`, cursor)
        local value = string.match(source, "{%s*([%w%.]+)%s*}", cursor)

        -- local optimizedCondition = ""
        -- local leftHandAnchor
        -- local rightHandAnchor
        -- local invalid = false
        -- local localCursor = 1
        -- for i = 1, 7 do
        --     if string.find(condition, "&&", localCursor) then invalid = true break end

        --     local orPos, length, leftHand, rightHand = string.find(condition, "([%w_-]*)%s*==%s*([%w_-]*)%s*||", localCursor)
        --     print(condition)
        --     print(rightHand)
        --     if orPos then
        --         localCursor = orPos
        --         if not leftHandAnchor then
        --             leftHandAnchor = leftHand
        --             optimizedCondition = "in(" .. leftHandAnchor
        --         end
        --         if not rightHandAnchor then
        --             rightHandAnchor = rightHand
        --         end
        --         if (leftHand == leftHandAnchor or leftHand == rightHandAnchor) and (rightHand == leftHandAnchor or rightHand == rightHandAnchor) then
        --             optimizedCondition ..= `, {rightHand}`
        --         else
        --             invalid = true
        --             break
        --         end
        --     else
        --         if localCursor == 1 then
        --             invalid = true
        --         end
        --         break
        --     end
        -- end
        -- if not invalid then
        --     optimizedCondition ..= ")"
        --     condition = optimizedCondition
        -- end

        result ..= `if({condition}, {value}, \\\n`
    end
end

print(result)