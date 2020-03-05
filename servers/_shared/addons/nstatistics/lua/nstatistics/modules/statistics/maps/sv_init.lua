NSTATISTICS.AddStatistic(
	{
		Name = "maps",
		Serverside = true,
		ForPlayers = false,
		CustomSave = nil,
		AddIfNotExists = false,
		Collision = NSTATISTICS.Collisions.None,
		Calculation = NSTATISTICS.Calculations.NumValue,
		Concatenate = NSTATISTICS.ConcatenateCalculations.Num,
		Delay = nil,
		Once = nil,
		Compress = true,
		Sending = nil,
		RawDataSending = nil,
		Suspicious = nil,
		Beautifier = nil
	}
)

local time = nil
local exists

local function LoadTime()
	local cur = NSTATISTICS.GetCurDateWithHours()
	local map = game.GetMap()

	NSTATISTICS.Provider.ReadRawSharedData(
		"maps",
		{NSTATISTICS.config.ThisServer},
		cur,
		cur,
		function(data)
			time = {}
			exists = table.Count(data) > 0

			for _, tbl in pairs(data) do
				for _, json in pairs(tbl) do
					for k, v in pairs(util.JSONToTable(json) or {}) do
						local numv = tonumber(v) or 0

						if time[k] then
							time[k] = time[k] + numv
						else
							time[k] = numv
						end
					end
				end
			end
		end
	)
end

LoadTime()

local LastSaving = CurTime()

local function SaveMapTime()
	if time then
		local map = game.GetMap()

		time[map] = (time[map] or 0) + math.Round((CurTime() - LastSaving) / 60)

		if exists then
			NSTATISTICS.Provider.UpdateData("maps", util.TableToJSON(time), NSTATISTICS.GetCurDateWithHours())
		else
			NSTATISTICS.Provider.AddNote("maps", util.TableToJSON(time))

			exists = true
		end

		LastSaving = CurTime()
	end
end

hook.Add(
	"NStatistics_HourChanged",
	"NStatistics_SaveMapsTime",
	function()
		time = {}
	end
)

timer.Create(
	"NStatistics_SaveMapsTime",
	600,
	0,
	function()
		SaveMapTime()
	end
)
