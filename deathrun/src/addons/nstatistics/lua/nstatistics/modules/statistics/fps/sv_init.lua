NSTATISTICS.AddStatistic(
	{
		Name = "fps",
		Serverside = false,
		ForPlayers = true,
		CustomSave = function(ply, data)
			local curdate = NSTATISTICS.GetCurDate()
			local id = ply:SteamID()
			data = tonumber(data)

			if not data then
				return
			end

			NSTATISTICS.Provider.UpdateOrAddToday(
				"fps",
				ply,
				data,
				function(calculate)
					local sum = 0

					for _, v in ipairs(calculate) do
						sum = sum + v
					end

					return sum / #calculate
				end
			)
		end,
		AddIfNotExists = false,
		Collision = NSTATISTICS.Collisions.Average,
		Calculation = NSTATISTICS.Calculations.Average,
		Concatenate = NSTATISTICS.ConcatenateCalculations.Average,
		Delay = 290,
		Once = false,
		Compress = true,
		Sending = nil,
		RawDataSending = nil,
		Suspicious = function(data)
			return table.Count(data) ~= 1 or not data[1] or not (isnumber(data[1]) and data[1] >= 0 and data[1] <= 300)
		end,
		Beautifier = function(data)
			return data[1]
		end
	}
)
