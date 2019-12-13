local phrases = {
	[0] = "Windowed",
	[1] = "Fullscreen"
}

NSTATISTICS.AddStatistic(
	{
		Title = "Fullscreen",
		Name = "fullscreen",
		Beautifier = function(data)
			return tonumber(data) == 1 and NSTATISTICS.GetPhrase("Fullscreen") or NSTATISTICS.GetPhrase("Windowed")
		end,
		RawDataModifier = nil,
		Modifier = function(data)
			for _, tbl in pairs(data) do
				local newdata = {}

				for k, v in pairs(tbl.data) do
					newdata[tonumber(k) == 1 and NSTATISTICS.GetPhrase("Fullscreen") or NSTATISTICS.GetPhrase("Windowed")] = v
				end

				tbl.data = newdata
			end

			return data
		end,
		ForPlayers = true,
		Display = "%.2f%%",
		Legend = nil,
		ShowKey = true,
		MinChartY = 100,
		ModifyFilterRawData = function(filter)
			return filter:FindLikePhrases(phrases) or filter
		end
	}
)

NSTATISTICS.AddInitialSpawnCallback(
	function()
		NSTATISTICS.SendStatisticToServer("fullscreen", {not system.IsWindowed()})
	end
)
