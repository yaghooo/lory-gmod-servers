AddCSLuaFile("votemap/sh_votemap.lua")
AddCSLuaFile("votemap/cl_votemap.lua")

include("votemap/sh_votemap.lua")

if CLIENT then
    include("votemap/cl_votemap.lua")
else
    include("votemap/sv_votemap.lua")
    include("votemap/sv_nominate.lua")
end