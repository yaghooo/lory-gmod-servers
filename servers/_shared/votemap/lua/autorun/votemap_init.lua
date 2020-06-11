AddCSLuaFile("votemap/sh_votemap.lua")
AddCSLuaFile("votemap/cl_votemap.lua")
include("votemap/sh_votemap.lua")

if CLIENT then
    include("votemap/cl_votemap.lua")
else
    -- ensure we have a data folder
    if not file.Exists("votemap/", "DATA") then
        file.CreateDir("votemap")
    end

    include("votemap/sv_state.lua")
    include("votemap/sv_votemap.lua")
    include("votemap/sv_maps.lua")
    include("votemap/sv_nominate.lua")
end