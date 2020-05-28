-- ensure we have a data folder
if not file.Exists("config/", "DATA") then
    file.CreateDir("config")
end

local function runConfigFile(fileName)
    local content = file.Read("config/" .. fileName .. ".txt")
    local loaded = false

    if content then
        content = content .. "\n"
        game.ConsoleCommand(content)
        loaded = true
    end

    print("Loading configuration for '" .. fileName .. "': " .. tostring(loaded))
end

local currentMap = game.GetMap()
local mapPrefix = string.Split(currentMap, "_")[1]
runConfigFile("global")
runConfigFile(mapPrefix)
runConfigFile(currentMap)