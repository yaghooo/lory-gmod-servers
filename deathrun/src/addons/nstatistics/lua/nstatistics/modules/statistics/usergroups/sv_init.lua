NSTATISTICS.AddStatistic(
	{
		Name = "usergroups",
		Serverside = false,
		ForPlayers = true,
		CustomSave = nil,
		AddIfNotExists = true,
		Collision = NSTATISTICS.Collisions.GetFirst,
		Calculation = NSTATISTICS.Calculations.Num,
		Concatenate = NSTATISTICS.ConcatenateCalculations.Num,
		Delay = nil,
		Once = nil,
		Compress = true,
		Sending = function(func, data)
			func(NSTATISTICS.Calculations.NumToPercent(data))
		end,
		RawDataSending = nil,
		Suspicious = nil,
		Beautifier = nil
	}
)

hook.Add(
	"PlayerInitialSpawn",
	"NStatistics_UserGroups",
	function(ply)
		NSTATISTICS.Provider.CallIfPlayerDataNotExists(
			"usergroups",
			ply,
			NSTATISTICS.GetCurDate(),
			function(exists)
				NSTATISTICS.Provider.AddPlayerNote("usergroups", ply, ply:GetUserGroup())
			end
		)
	end
)
