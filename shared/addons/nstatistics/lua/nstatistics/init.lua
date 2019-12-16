-- SHARED

local shdir = "nstatistics/shared/"
local shfiles = file.Find(shdir .. "*.lua", "LUA")

for _, v in pairs(shfiles) do
	local path = shdir .. v

	AddCSLuaFile(path)
	include(path)
end

-- CLIENT

local cldir = "nstatistics/client/"
local clfiles = file.Find(cldir .. "*.lua", "LUA")

for _, v in pairs(clfiles) do
	AddCSLuaFile(cldir .. v)
end

local function AddAllClientModule(dir)
	local fulldir = "nstatistics/modules/" .. dir
	local files = file.Find(fulldir .. "/*.lua", "LUA")

	for _, file in pairs(files) do
		AddCSLuaFile(fulldir .. "/" .. file)
	end
end

AddAllClientModule("languages")
AddAllClientModule("display")
AddAllClientModule("vgui")

AddCSLuaFile("nstatistics/modules/statistics/cl_manager.lua")

local _, StatisticDirs = file.Find("nstatistics/modules/statistics/*", "LUA")

for _, v in pairs(StatisticDirs) do
	local init = "nstatistics/modules/statistics/" .. v .. "/cl_init.lua"

	if file.Exists(init, "LUA") then
		AddCSLuaFile(init)
	end
end

-- SERVER

local svdir = "nstatistics/server/"
local svfiles = file.Find(svdir .. "*.lua", "LUA")

for _, v in pairs(svfiles) do
	include(svdir .. v)
end

local ProviderPath = "nstatistics/modules/providers/" .. NSTATISTICS.config.Provider .. ".lua"

NSTATISTICS.Provider = {}
include("nstatistics/modules/providers/base.lua")

if not file.Exists(ProviderPath, "LUA") then
	NSTATISTICS.CurrentProvider = "base"
	ErrorNoHalt("Unknown provider: " .. NSTATISTICS.config.Provider .. ". Statistics will not be saved until you fix it")
else
	NSTATISTICS.CurrentProvider = NSTATISTICS.config.Provider
	include(ProviderPath)
end

include("updaters.lua")

include("nstatistics/modules/statistics/sv_manager.lua")

for _, v in pairs(StatisticDirs) do
	local init = "nstatistics/modules/statistics/" .. v .. "/sv_init.lua"

	if file.Exists(init, "LUA") then
		include(init)
	end
end

local curdate
local curhour
local called

hook.Add(
	"Think",
	"NStatistics_CheckDayChanging",
	function()
		local hour = tonumber(os.date("%H", os.time()))
		local minutes = tonumber(os.date("%M", os.time()))

		if not curhour then
			curhour = hour
		end

		if curhour ~= hour then
			hook.Call("NStatistics_HourChanged")
			curhour = hour
		end

		local date = NSTATISTICS.GetCurDate()
		local str = NSTATISTICS.DateToStr(date.year, date.month, date.day)

		if not curdate then
			curdate = str
			return
		end

		if curdate ~= str then
			hook.Call("NStatistics_DayChanged")
			curdate = str
			called = false
		end

		if not called and hour >= 23 and minutes >= 59 then
			hook.Call("NStatistics_DayIsAboutToChange")
			called = true
		end
	end
)
