NSTATISTICS.AddStatistic(
	{
		Name = "connection_aborted",
		Serverside = true,
		ForPlayers = true,
		CustomSave = nil,
		AddIfNotExists = false,
		Collision = NSTATISTICS.Collisions.GetFirst,
		Calculation = NSTATISTICS.Calculations.Count,
		Concatenate = NSTATISTICS.ConcatenateCalculations.Count,
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
		Name = "connecting_time",
		Serverside = true,
		ForPlayers = true,
		CustomSave = nil,
		AddIfNotExists = false,
		Collision = NSTATISTICS.Collisions.Average,
		Calculation = NSTATISTICS.Calculations.Average,
		Concatenate = NSTATISTICS.ConcatenateCalculations.Average,
		Delay = nil,
		Once = nil,
		Compress = true,
		Sending = nil,
		RawDataSending = nil,
		Suspicious = nil,
		Beautifier = nil
	}
)

gameevent.Listen("player_connect")
gameevent.Listen("player_disconnect")

local connecting = {}

hook.Add(
	"player_connect",
	"NStatistics_Connect",
	function(data)
		if data.bot == 0 then
			connecting[data.networkid] = CurTime()
		end
	end
)

hook.Add(
	"PlayerInitialSpawn",
	"NStatistics_PlayerConnected",
	function(ply)
		NSTATISTICS.Provider.CallIfPlayerDataNotExists(
			"connecting_time",
			ply,
			NSTATISTICS.GetCurDate(),
			function(exists)
				local id = ply:SteamID()

				if connecting[id] then
					NSTATISTICS.Provider.AddPlayerNote("connecting_time", id, math.Round(CurTime() - connecting[id]))
				end

				connecting[id] = nil
			end
		)
	end
)

hook.Add(
	"player_disconnect",
	"NStatistics_Disconnect",
	function(data)
		if data.bot == 0 then
			NSTATISTICS.Provider.CallIfPlayerDataNotExists(
				"connecting_time",
				data.networkid,
				NSTATISTICS.GetCurDate(),
				function(exists)
					if connecting[data.networkid] then
						NSTATISTICS.Provider.AddPlayerNote("connection_aborted", data.networkid, "")
						connecting[data.networkid] = nil
					end
				end
			)
		end
	end
)
