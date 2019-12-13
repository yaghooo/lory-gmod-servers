local cldir = "nstatistics/client/"
local clfiles = file.Find(cldir .. "*.lua", "LUA")

for _, v in pairs(clfiles) do
	include(cldir .. v)
end

local shdir = "nstatistics/shared/"
local shfiles = file.Find(shdir .. "*.lua", "LUA")

for _, v in pairs(shfiles) do
	include(shdir .. v)
end

NSTATISTICS.Languages = {}

local LanguageFiles = file.Find("nstatistics/modules/languages/*.lua", "LUA")

for _, file in pairs(LanguageFiles) do
	if file ~= "cl_manager.lua" then
		NSTATISTICS_LANGUAGE = {}

		include("nstatistics/modules/languages/" .. file)

		if NSTATISTICS_LANGUAGE.Short then
			NSTATISTICS.Languages[NSTATISTICS_LANGUAGE.Short] = NSTATISTICS_LANGUAGE
		end

		NSTATISTICS_LANGUAGE = nil
	end
end

include("nstatistics/modules/languages/cl_manager.lua")

include("nstatistics/modules/display/cl_manager.lua")

local DisplayFiles = file.Find("nstatistics/modules/display/*.lua", "LUA")

for _, file in pairs(DisplayFiles) do
	if file ~= "cl_manager.lua" then
		include("nstatistics/modules/display/" .. file)
	end
end

local VGUIFiles = file.Find("nstatistics/modules/vgui/*.lua", "LUA")

for _, file in pairs(VGUIFiles) do
	include("nstatistics/modules/vgui/" .. file)
end

include("nstatistics/modules/statistics/cl_manager.lua")

local _, StatisticDirs = file.Find("nstatistics/modules/statistics/*", "LUA")

for _, v in pairs(StatisticDirs) do
	local init = "nstatistics/modules/statistics/" .. v .. "/cl_init.lua"

	if file.Exists(init, "LUA") then
		include(init)
	end
end
