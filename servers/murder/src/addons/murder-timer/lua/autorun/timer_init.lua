AddCSLuaFile("timer/sh_timer.lua")
AddCSLuaFile("timer/cl_timer.lua")

include("timer/sh_timer.lua")

if CLIENT then
    include("timer/cl_timer.lua")
else
    include("timer/sv_timer.lua")
end