NSTATISTICS.AddStatistic(
	{
		Name = "timezone",
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
			local utc = data[1]

			if not isstring(utc) then
				return true
			end

			local hours = string.match(utc, "^[%+%-]%d%d")
			local minutes

			if hours then
				minutes = string.match(utc, "%d%d$", #hours + 1)
			end

			hours = tonumber(hours)
			minutes = tonumber(minutes)

			if not hours or not minutes then
				return false, true
			end

			return hours < -12 or hours > 14 or minutes < 0 or minutes > 60
		end,
		Beautifier = function(data)
			return data[1] .. " "
		end
	}
)
