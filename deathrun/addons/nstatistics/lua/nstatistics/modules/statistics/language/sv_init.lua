NSTATISTICS.AddStatistic(
	{
		Name = "language",
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
			return table.Count(data) ~= 1 or not data[1]
		end,
		Beautifier = function(data)
			return data[1]
		end
	}
)
