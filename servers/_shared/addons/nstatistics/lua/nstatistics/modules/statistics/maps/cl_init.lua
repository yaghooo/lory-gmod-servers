NSTATISTICS.AddStatistic(
	{
		Title = "Maps",
		Name = "maps",
		Beautifier = nil,
		RawDataModifier = function(data, size)
			return NSTATISTICS.SplitJSONRawData(data), size
		end,
		RawDataModifier = nil,
		Modifier = nil,
		ForPlayers = false,
		Display = function(data)
			return NSTATISTICS.GetPhrase("MinutesShort", data)
		end,
		Legend = nil,
		ShowKey = true,
		MinChartY = nil,
		ModifyFilter = function(filter)
			-- Stored in JSON
			return filter:NotExact()
		end
	}
)
