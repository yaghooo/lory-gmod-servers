-- ensure we have a data folder
if not file.Exists("config/", "DATA") then
    file.CreateDir("config")
end

local function runConfigFile(fileName)
    local content = file.Read("config/" .. fileName .. ".txt")
    if content then
        print("Loading configuration for: " .. fileName)
        content = content .. "\n"
        game.ConsoleCommand(content)
    end
end

local currentMap = game.GetMap()
local mapPrefix = string.Split(currentMap, "_")[1]

runConfigFile("global")
runConfigFile(mapPrefix)
runConfigFile(currentMap)