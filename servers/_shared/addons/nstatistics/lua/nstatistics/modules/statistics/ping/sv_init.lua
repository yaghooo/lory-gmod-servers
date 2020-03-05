NSTATISTICS.AddStatistic(
	{
		Name = "ping",
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

local pings = {}

hook.Add(
	"Think",
	"NStatistics_GetPing",
	function()
		for _, v in pairs(player.GetHumans()) do
			local id = v:SteamID()

			if not pings[id] then
				pings[id] = {
					sum = 0,
					times = 0,
					ply = v
				}
			end

			pings[id].sum = pings[id].sum + v:Ping()
			pings[id].times = pings[id].times + 1
		end
	end
)

timer.Create(
	"NStatistics_SavePing",
	300,
	0,
	function()
		for k, v in pairs(pings) do
			local curdate = NSTATISTICS.GetCurDate()
			local data = math.Clamp(v.sum / v.times, 0, 500)

			if data ~= 0 then
				NSTATISTICS.Provider.UpdateOrAddToday(
					"ping",
					k,
					data,
					function(calculate)
						local sum = 0

						for _, v in ipairs(calculate) do
							sum = sum + v
						end

						return sum / #calculate
					end
				)

				if not IsValid(v.ply) then
					pings[k] = nil
				end
			end
		end

		pings = {}
	end
)
