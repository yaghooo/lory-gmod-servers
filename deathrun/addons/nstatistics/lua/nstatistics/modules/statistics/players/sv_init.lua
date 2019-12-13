NSTATISTICS.AddStatistic(
	{
		Name = "players",
		Serverside = true,
		ForPlayers = true,
		CustomSave = nil,
		AddIfNotExists = true,
		Collision = NSTATISTICS.Collisions.GetFirst,
		Calculation = function(data)
			local counts = {}

			for _, tbl in pairs(data) do
				for _, v in pairs(tbl) do
					if v == "n" then
						counts["n"] = (counts["n"] or 0) + 1
						counts["o"] = (counts["o"] or 0) + 1
					else
						counts["o"] = (counts["o"] or 0) + 1
					end
				end
			end

			return counts
		end,
		Concatenate = NSTATISTICS.ConcatenateCalculations.Num,
		Delay = nil,
		Once = nil,
		Compress = true,
		Sending = nil,
		RawDataSending = nil,
		Suspicious = nil,
		Beautifier = nil
	}
)

NSTATISTICS.AddStatistic(
	{
		Name = "totalplaytime",
		Serverside = true,
		ForPlayers = true,
		CustomSave = nil,
		AddIfNotExists = true,
		Collision = NSTATISTICS.Collisions.GetFirst,
		Calculation = NSTATISTICS.Calculations.Num,
		Concatenate = NSTATISTICS.ConcatenateCalculations.Num,
		Delay = nil,
		Once = nil,
		Compress = true,
		Sending = nil,
		RawDataSending = nil,
		Suspicious = nil,
		Beautifier = nil
	}
)

NSTATISTICS.AddStatistic(
	{
		Name = "timeplayed",
		Serverside = true,
		ForPlayers = true,
		CustomSave = nil,
		AddIfNotExists = false,
		Collision = NSTATISTICS.Collisions.Sum,
		Calculation = function(data)
			for _, tbl in pairs(data) do
				for k, v in pairs(tbl) do
					tbl[k] = math.Round(v / 60)
				end
			end

			return NSTATISTICS.Calculations.Num(data)
		end,
		Concatenate = NSTATISTICS.ConcatenateCalculations.Num,
		Delay = nil,
		Once = nil,
		Compress = true,
		Sending = nil,
		RawDataSending = nil,
		Suspicious = nil,
		Beautifier = nil
	}
)

local function SetTotalPlayTime(ply)
	ply:SetPData("NStatistics_Time", math.Round(ply.ns_time + CurTime() - ply.ns_timesaved))
end

local function SavePlayTime(ply)
	NSTATISTICS.Provider.UpdateOrAddToday(
		"timeplayed",
		ply,
		math.Round((CurTime() - ply.ns_timesaved) / 60),
		function(calculate)
			local sum = 0

			for _, v in ipairs(calculate) do
				sum = sum + v
			end

			return sum
		end
	)

	SetTotalPlayTime(ply)

	ply.ns_time = tonumber(ply:GetPData("NStatistics_Time", 0)) or 0
	ply.ns_timesaved = CurTime()
end

local PlayersTime = {}

timer.Create(
	"NStatistics_UpdatePlayersTime",
	30,
	0,
	function()
		for k, v in pairs(player.GetHumans()) do
			SetTotalPlayTime(v)

			PlayersTime[v:SteamID()] = math.floor(v:GetPData("NStatistics_Time", 0) / 3600)
		end
	end
)

hook.Add(
	"PlayerInitialSpawn",
	"NStatistics_PlayerJoinTime",
	function(ply)
		if not ply:IsBot() then
			ply.ns_time = tonumber(ply:GetPData("NStatistics_Time", 0)) or 0
			ply.ns_timesaved = CurTime()

			local time = tonumber(ply:GetPData("NStatistics_Time", 0)) or 0

			NSTATISTICS.Provider.CallIfPlayerDataNotExists(
				"players",
				ply,
				NSTATISTICS.GetCurDate(),
				function(exists)
					if time == 0 then
						NSTATISTICS.Provider.AddPlayerNote("players", ply, "n")
						ply:SetPData("NStatistics_Time", 1)
					else
						NSTATISTICS.Provider.AddPlayerNote("players", ply, "o")
					end
				end
			)

			NSTATISTICS.Provider.CallIfPlayerDataNotExists(
				"totalplaytime",
				ply,
				NSTATISTICS.GetCurDate(),
				function(exists)
					NSTATISTICS.Provider.AddPlayerNote("totalplaytime", ply, math.Round(ply.ns_time / 3600))
				end
			)
		end
	end
)

hook.Add(
	"PlayerDisconnected",
	"NStatistics_PlayTime",
	function(ply)
		if not ply:IsBot() then
			SetTotalPlayTime(ply)
			SavePlayTime(ply)
		end
	end
)

hook.Add(
	"NStatistics_DayChanged",
	"NStatistics_PlayTime",
	function()
		for k, v in pairs(player.GetHumans()) do
			SavePlayTime(v)
		end
	end
)
