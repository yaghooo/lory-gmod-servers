NSTATISTICS.AddStatistic(
	{
		Title = "GroupsJoined",
		Name = "groupsjoined",
		Beautifier = function(data)
			if data == "nogroup_lang" then
				return NSTATISTICS.GetPhrase("NoGroup")
			end

			return data
		end,
		RawDataModifier = nil,
		Modifier = nil,
		ForPlayers = true,
		Display = "%.2f%%",
		Legend = nil,
		ShowKey = true,
		MinChartY = 100,
		ModifyFilterRawData = function(filter)
			local new = filter:FindLikePhrases {["[]"] = "NoGroup"}

			if new then
				filter = filter:Merge(new)
			end

			return filter
		end
	}
)

NSTATISTICS.AddStatistic(
	{
		Title = "PrimaryGroup",
		Name = "primarygroup",
		Beautifier = function(data)
			if data == "" then
				return NSTATISTICS.GetPhrase("NoPrimaryGroup")
			end

			return data
		end,
		RawDataModifier = nil,
		Modifier = nil,
		ForPlayers = true,
		Display = "%.2f%%",
		Legend = nil,
		ShowKey = true,
		MinChartY = 100,
		ModifyFilterRawData = function(filter)
			local new = filter:FindLikePhrases {[""] = "NoPrimaryGroup"}

			if new then
				filter = filter:Merge(new)
			end

			return filter
		end
	}
)
