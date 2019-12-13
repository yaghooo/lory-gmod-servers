NSTATISTICS.AddStatistic(
	{
		Title = "OperatingSystem",
		Name = "system",
		Beautifier = nil,
		RawDataModifier = nil,
		Modifier = nil,
		ForPlayers = true,
		Display = "%.2f%%",
		Legend = nil,
		ShowKey = true,
		MinChartY = 100,
		ModifyFilterRawData = nil
	}
)

NSTATISTICS.AddInitialSpawnCallback(
	function()
		local cases = {
			"Windows",
			"Linux",
			"OSX",
			"BSD",
			"POSIX",
			"Other"
		}

		local system = jit.os

		if system and not table.HasValue(cases, system) then
			system = "Other"
		end

		NSTATISTICS.SendStatisticToServer("system", {system})
	end
)
