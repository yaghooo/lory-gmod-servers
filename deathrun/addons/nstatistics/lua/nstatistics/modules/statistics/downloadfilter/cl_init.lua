local filters = {
	"all",
	"nosounds",
	"mapsonly",
	"none"
}

local phrases = {
	"DLAllFiles",
	"DLNoSounds",
	"DLOnlyMap",
	"DLNothing"
}

NSTATISTICS.AddStatistic(
	{
		Title = "DownloadFilter",
		Name = "downloadfilter",
		Beautifier = function(data)
			return NSTATISTICS.GetPhrase(phrases[tonumber(data)])
		end,
		RawDataModifier = nil,
		Modifier = nil,
		ForPlayers = true,
		Display = "%.2f%%",
		Legend = function(data)
			return NSTATISTICS.GetPhrase(phrases[tonumber(data)])
		end,
		ShowKey = true,
		MinChartY = 100,
		ModifyFilterRawData = function(filter)
			return filter:FindLikePhrases(phrases) or filter
		end
	}
)

NSTATISTICS.AddInitialSpawnCallback(
	function()
		local filter = GetConVar("cl_downloadfilter"):GetString()
		local key

		for k, v in pairs(filters) do
			if v == filter then
				key = k
				break
			end
		end

		if key then
			NSTATISTICS.SendStatisticToServer("downloadfilter", {key})
		end
	end
)
