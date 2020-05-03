AddCSLuaFile("bomdia/cl_bomdia.lua")

if CLIENT then
    include("bomdia/cl_bomdia.lua")
else
    CreateConVar("bomdia_cabuloso_rate", 0.85, FCVAR_NONE, "Rate of bom dia cabuloso")
    CreateConVar("bomdia_cabuloso_points", 200, FCVAR_NONE, "Points that a bom dia cabuloso should give")
    CreateConVar("bomdia_interval_time", 300, FCVAR_NONE, "Interval between bom dias")
    include("bomdia/sv_bomdia.lua")
end
