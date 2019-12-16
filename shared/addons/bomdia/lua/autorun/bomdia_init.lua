AddCSLuaFile("bomdia/cl_bomdia.lua")

if CLIENT then
    include("bomdia/cl_bomdia.lua")
else
    include("bomdia/sv_bomdia.lua")
end

local defaultFlags = FCVAR_SERVER_CAN_EXECUTE + FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE
CreateConVar("bomdia_cabuloso_rate", 0.85, defaultFlags, "Rate of bom dia cabuloso")
CreateConVar("bomdia_cabuloso_points", 200, defaultFlags, "Points that a bom dia cabuloso should give")
CreateConVar("bomdia_interval_time", 300, defaultFlags, "Interval between bom dias")