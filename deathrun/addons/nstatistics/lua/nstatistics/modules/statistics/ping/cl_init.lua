NSTATISTICS.AddStatistic(
	{
		Title = "Ping",
		Name = "ping",
		Beautifier = nil,
		RawDataModifier = nil,
		Modifier = nil,
		ForPlayers = true,
		Display = "%.2f",
		Legend = nil,
		ShowKey = false,
		MinChartY = nil,
		ModifyFilterRawData = function(filter)
			return filter:GetNumbers():NotExact()
		end
	}
)
