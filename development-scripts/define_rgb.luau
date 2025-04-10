-- Converts a vec3 define to RGB config

local DEFAULT_INTERVAL = 16
local inputs = {
    "SUNRAYS_SUNRISE",
    "SUNRAYS_MORNING",
    "SUNRAYS_NOON",
    "SUNRAYS_AFTERNOON",
    "SUNRAYS_SUNSET",
    "SUNRAYS_MIDNIGHT",
    "SUNRAYS_RAIN",
}

function formatDefine(param, start, goal, interval)
    local result = `#define {param} 0 // [`
    for value = start, goal-1, interval do
        result ..= `{value} `
    end

    return result .. `{goal}]`
end

function formatRGBDefine(object)
    local param = object.Parameter
    local start = object.Start or 0
    local goal = object.End or 255
    local interval = object.Interval or DEFAULT_INTERVAL or 10

    return formatDefine(`{param}_R`, start, goal, interval) .. "\n" ..
    formatDefine(`{param}_G`, start, goal, interval) .. "\n" ..
    formatDefine(`{param}_B`, start, goal, interval)
end

for _, object in inputs do
    if type(object) == "string" then
        object = {Parameter = object,}
    end
    print(formatRGBDefine(object))
end