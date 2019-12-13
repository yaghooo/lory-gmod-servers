NSTATISTICS.Statistics = {}

function NSTATISTICS.AddStatistic(params)
	if params.Name then
		NSTATISTICS.Statistics[params.Name] = params
		NSTATISTICS.Statistics[params.Name].Disabled = table.HasValue(NSTATISTICS.config.DisabledStatistics, params.Name)

		return NSTATISTICS.Statistics[params.Name].Disabled
	end
end
