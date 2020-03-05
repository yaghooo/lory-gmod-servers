local template = {
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
	Sending = function(func, data)
		func(NSTATISTICS.Calculations.NumToPercent(data))
	end,
	RawDataSending = nil,
	Suspicious = nil,
	Beautifier = nil
}

local statistics = {
	["country"] = "country_name",
	["region"] = "region_name",
	["city"] = "city"
}

for k, v in pairs(statistics) do
	local copy = table.Copy(template)
	copy.Name = k

	NSTATISTICS.AddStatistic(copy)
end

hook.Add(
	"PlayerInitialSpawn",
	"NStatistics_IPInformation",
	function(ply)
		local ip = ply:IPAddress()
		ip = string.gsub(ip, ":%d*", "")

		-- Bots and host
		if not string.find(ip, "^%d+%.%d+%.%d+%.%d+") then
			return
		end

		local address = "http://ip-api.com/json/" .. ip

		http.Fetch(
			address,
			function(json)
				local tbl = util.JSONToTable(json)

				if not tbl then
					NSTATISTICS.PrintConsole("Can't convert JSON from " .. address .. ": " .. json)
					return
				end

				for k, v in pairs(statistics) do
					tbl[v] = tbl[v] and string.Trim(tbl[v])

					if tbl[v] and tbl[v] ~= "" and tbl[v] ~= "_1_" then
						NSTATISTICS.Provider.CallIfPlayerDataNotExists(
							k,
							ply,
							NSTATISTICS.GetCurDate(),
							function(exists)
								NSTATISTICS.Provider.AddPlayerNote(k, ply, tbl[v])
							end
						)
					end
				end
			end,
			function(err)
				NSTATISTICS.PrintConsole("Error connecting to " .. address)
			end
		)
	end
)
