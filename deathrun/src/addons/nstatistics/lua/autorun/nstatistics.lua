NSTATISTICS = NSTATISTICS or {}

include("nstatistics/config/sh_config.lua")

if SERVER then
	include("nstatistics/config/config.lua")

	AddCSLuaFile()
	AddCSLuaFile("nstatistics/config/sh_config.lua")
	AddCSLuaFile("nstatistics/cl_init.lua")

	include("nstatistics/init.lua")
else
	include("nstatistics/cl_init.lua")
end

NSTATISTICS.Loaded = true
