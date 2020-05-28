THEME = {}
THEME.Component = {}
THEME.Color = {}
THEME.Font = {}

if SERVER then
    AddCSLuaFile("theme/colors.lua")
    AddCSLuaFile("theme/fonts.lua")
    AddCSLuaFile("theme/utils.lua")
else
    include("theme/colors.lua")
    include("theme/fonts.lua")
    include("theme/utils.lua")
end

local files, _ = file.Find("theme/components/*.lua", "LUA")
for _, name in pairs(files) do
    if SERVER then
        AddCSLuaFile("theme/components/" .. name)
    else
        include("theme/components/" .. name)
    end
end