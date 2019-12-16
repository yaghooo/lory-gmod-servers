AddCSLuaFile("crosshair/cl_crosshair.lua")

if CLIENT then
    include("crosshair/cl_crosshair.lua")
else
    include("crosshair/sv_crosshair.lua")
end