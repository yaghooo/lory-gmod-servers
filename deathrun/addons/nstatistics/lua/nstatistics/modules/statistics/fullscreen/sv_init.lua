NSTATISTICS.AddStatistic(
	{
		Name = "fullscreen",
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
			if table.Count(data) ~= 1 then
				return true
			end

			return not isbool(data[1])
		end,
		Beautifier = function(data)
			return data[1] and 1 or 0
		end
	}
)
