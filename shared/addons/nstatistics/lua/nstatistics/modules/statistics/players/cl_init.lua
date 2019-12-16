local newPlayersPhrases = {
	[""] = "",
	["n"] = "New"
}

NSTATISTICS.AddStatistic(
	{
		Title = "PlayersWord",
		Name = "players",
		Beautifier = function(data)
			return data == "n" and NSTATISTICS.GetPhrase("New") or ""
		end,
		RawDataModifier = nil,
		Modifier = nil,
		ForPlayers = true,
		Display = nil,
		Legend = function(data)
			return data == "n" and NSTATISTICS.GetPhrase("New") or NSTATISTICS.GetPhrase("PlayersWord")
		end,
		ShowKey = true,
		MinChartY = nil,
		ModifyFilterRawData = function(filter)
			return filter:FindLikePhrases(newPlayersPhrases) or filter
		end
	}
)

local function Beautify(data)
	data = tonumber(data)

	local intervals = NSTATISTICS.config.TotalTimeIntervals
	local i = 0

	for k, v in pairs(intervals) do
		if v > data then
			i = k
			break
		end
	end

	-- Lower than first value
	if i == 1 then
		return "< " .. intervals[1]
	end

	-- Higher than last value
	if i == 0 then
		return "> " .. intervals[#intervals]
	end

	return intervals[i - 1] .. "-" .. intervals[i]
end

NSTATISTICS.AddStatistic(
	{
		Title = "TotalPlayTime",
		Name = "totalplaytime",
		Beautifier = function(data)
			return NSTATISTICS.GetPhrase("HoursShort", data)
		end,
		Modifier = function(data)
			for _, tbl in pairs(data) do
				local copy = table.Copy(tbl.data)
				tbl.data = {}

				for k, v in pairs(copy) do
					local bk = NSTATISTICS.GetPhrase("PlayHours", Beautify(k))

					if tbl.data[bk] then
						tbl.data[bk] = tbl.data[bk] + v
					else
						tbl.data[bk] = v
					end
				end
			end

			return data
		end,
		ForPlayers = true,
		Display = function(data)
			if data == 1 then
				return NSTATISTICS.GetPhrase("Player", data)
			else
				return NSTATISTICS.GetPhrase("Players", data)
			end
		end,
		Legend = nil,
		ShowKey = true,
		MinChartY = nil,
		ModifyFilterRawData = function(filter)
			return (filter:PhrasesFormatToFilter("HoursShort") or filter):GetNumbers()
		end
	}
)

NSTATISTICS.AddStatistic(
	{
		Title = "TimePlayed",
		Name = "timeplayed",
		Beautifier = function(data)
			return NSTATISTICS.GetPhrase("MinutesShort", data)
		end,
		Modifier = function(data)
			for _, tbl in pairs(data) do
				local new = {}

				for k, v in pairs(tbl.data) do
					if k == 0 then
						new[NSTATISTICS.GetPhrase("PlayHour", "< 1")] = v
					else
						if k == 1 then
							new[NSTATISTICS.GetPhrase("PlayHour", k)] = v
						else
							new[NSTATISTICS.GetPhrase("PlayHours", k)] = v
						end
					end
				end

				tbl.data = new
			end

			return data
		end,
		ForPlayers = true,
		Display = function(data)
			if data == 1 then
				return NSTATISTICS.GetPhrase("Player", data)
			else
				return NSTATISTICS.GetPhrase("Players", data)
			end
		end,
		Legend = nil,
		ShowKey = true,
		MinChartY = 100,
		ModifyFilterRawData = function(filter)
			return (filter:PhrasesFormatToFilter("MinutesShort") or filter):GetNumbers(true)
		end
	}
)
