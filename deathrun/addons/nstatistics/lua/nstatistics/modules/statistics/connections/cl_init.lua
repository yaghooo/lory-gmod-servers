NSTATISTICS.AddStatistic(
	{
		Title = "ConnectionAborted",
		Name = "connection_aborted",
		Beautifier = function(data)
			return ""
		end,
		RawDataModifier = nil,
		Modifier = nil,
		ForPlayers = true,
		Display = function(data)
			if data == 1 then
				return NSTATISTICS.GetPhrase("Player", data)
			else
				return NSTATISTICS.GetPhrase("Players", data)
			end
		end,
		Legend = nil,
		ShowKey = false,
		MinChartY = nil,
		ModifyFilterRawData = function(filter)
			return filter:DisableFilter()
		end
	}
)

NSTATISTICS.AddStatistic(
	{
		Title = "ConnectingTime",
		Name = "connecting_time",
		Beautifier = function(data)
			return NSTATISTICS.GetPhrase("SecondsShort", data)
		end,
		RawDataModifier = nil,
		Modifier = nil,
		ForPlayers = true,
		Display = function(data)
			return NSTATISTICS.GetPhrase("SecondsShort", data)
		end,
		Legend = nil,
		ShowKey = false,
		MinChartY = nil,
		ModifyFilterRawData = function(filter)
			return (filter:PhrasesFormatToFilter("SecondsShort") or filter):GetNumbers()
		end
	}
)
