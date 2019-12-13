NSTATISTICS.Statistics = {}

function NSTATISTICS.AddStatistic(params)
	if params.Name then
		NSTATISTICS.Statistics[params.Name] = params
		NSTATISTICS.Statistics[params.Name].Disabled = table.HasValue(NSTATISTICS.config.DisabledStatistics, params.Name)

		return NSTATISTICS.Statistics[params.Name].Disabled
	end
end

function NSTATISTICS.GetStatisticsDisplayText(display, str)
	if isfunction(display) then
		return display(str)
	elseif isstring(display) then
		return string.format(display, str)
	end

	return str
end

local callbacks = {}

function NSTATISTICS.AddInitialSpawnCallback(callback)
	if callbacks then
		table.insert(callbacks, callback)
	end
end

hook.Add(
	"InitPostEntity",
	"NStatistics_InitializeStatistics",
	function()
		if callbacks then
			for _, v in pairs(callbacks) do
				v()
			end

			callbacks = nil
		end
	end
)

concommand.Add(
	"nstatistics_list",
	function(ply)
		if NSTATISTICS.IsPlayerHaveMenuAccess(ply) then
			NSTATISTICS.PrintConsole("Statistics list:")

			for k, v in pairs(NSTATISTICS.Statistics) do
				NSTATISTICS.PrintConsole(k .. " - " .. NSTATISTICS.GetPhrase(v.Title))
			end
		end
	end
)
