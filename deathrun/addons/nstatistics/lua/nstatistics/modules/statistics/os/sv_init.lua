local cases = {
	"Windows",
	"Linux",
	"OSX",
	"BSD",
	"POSIX",
	"Other"
}

NSTATISTICS.AddStatistic(
	{
		Name = "system",
		Serverside = false,
		ForPlayers = true,
		CustomSave = nil,
		AddIfNotExists = true,
		Collision = NSTATISTICS.Collisions.GetFirst,
		Calculation = NSTATISTICS.Calculations.Num,
		Concatenate = NSTATISTICS.ConcatenateCalculations.Num,
		Delay = nil,
		Once = true,
		Compress = true,
		Sending = function(func, data)
			func(NSTATISTICS.Calculations.NumToPercent(data))
		end,
		RawDataSending = nil,
		Suspicious = function(data)
			if table.Count(data) ~= 1 or not data[1] then
				return true
			end

			return not table.HasValue(cases, data[1])
		end,
		Beautifier = function(data)
			return data[1]
		end
	}
)
