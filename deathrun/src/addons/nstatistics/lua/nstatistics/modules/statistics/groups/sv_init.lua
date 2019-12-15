NSTATISTICS.AddStatistic(
	{
		Name = "groupsjoined",
		Serverside = true,
		ForPlayers = true,
		CustomSave = nil,
		AddIfNotExists = true,
		Collision = NSTATISTICS.Collisions.None,
		Calculation = function(data)
			local groups = {
				num = 0
			}

			for _, tbl in pairs(data) do
				for _, v in pairs(tbl) do
					local tbl = util.JSONToTable(v)

					if tbl then
						for _, v in pairs(tbl) do
							if not groups[v] then
								groups[v] = 0
							end

							groups[v] = groups[v] + 1
						end

						groups.num = groups.num + 1
					end
				end
			end

			return groups
		end,
		Concatenate = function(data)
			local new = {}

			for _, tbl in pairs(data) do
				for k, v in pairs(tbl) do
					new[k] = (new[k] or 0) + v
				end
			end

			return new
		end,
		Delay = nil,
		Once = nil,
		Compress = true,
		Sending = function(func, data)
			if table.Count(NSTATISTICS.Groups) == 0 then
				func({})
				return
			end

			for k, tbl in pairs(data) do
				local newdata = {}

				local num = tbl.data.num
				tbl.data.num = nil

				for k, v in pairs(tbl.data) do
					local printname

					if NSTATISTICS.Groups[k] then
						printname = NSTATISTICS.Groups[k].printname
					end

					if printname then
						newdata[printname] = math.Round(v / num * 100, 2)
					end
				end

				if table.Count(newdata) > 0 then
					tbl.data = newdata
				else
					table.remove(data, k)
				end
			end

			for _, group in pairs(NSTATISTICS.Groups) do
				for _, tbl in pairs(data) do
					local finded = false

					for k, v in pairs(tbl.data) do
						if k == group.printname then
							finded = true
							break
						end
					end

					if not finded then
						tbl.data[group.printname] = 0
					end
				end
			end

			func(data)
		end,
		RawDataSending = function(func, data)
			for _, tbl in pairs(data) do
				local groups = util.JSONToTable(tbl.data)
				local newdata

				if groups then
					if table.Count(groups) == 0 then
						newdata = "nogroup_lang"
					else
						local nice = {}

						for k, v in pairs(groups) do
							if NSTATISTICS.Groups[v] then
								nice[k] = NSTATISTICS.Groups[v].printname
							end
						end

						newdata = table.concat(nice, ", ")
					end
				else
					newdata = "Corrupted JSON"
				end

				tbl.data = newdata
			end

			func(data)
		end,
		Suspicious = nil,
		Beautifier = nil,
		ModifyFilterRawData = function(filter)
			local names = {}

			for k, v in pairs(NSTATISTICS.Groups) do
				names[k] = v.printname
			end

			return filter:FindLike(names) or filter
		end
	}
)

NSTATISTICS.AddStatistic(
	{
		Name = "primarygroup",
		Serverside = true,
		ForPlayers = true,
		CustomSave = nil,
		AddIfNotExists = true,
		Collision = NSTATISTICS.Collisions.GetFirst,
		Calculation = function(data)
			local newdata = {}

			for id, tbl in pairs(data) do
				local newtbl = {}

				for k, v in pairs(tbl) do
					if v ~= "" then
						newtbl[k] = v
					end
				end

				if table.Count(newtbl) > 0 then
					newdata[id] = newtbl
				else
					newdata[id] = {"nogroup"}
				end
			end

			local num = NSTATISTICS.Calculations.Num(newdata)

			return num
		end,
		Concatenate = NSTATISTICS.ConcatenateCalculations.Num,
		Delay = nil,
		Once = nil,
		Compress = true,
		Sending = function(func, data)
			local percent = NSTATISTICS.Calculations.NumToPercent(data)

			for k, tbl in pairs(percent) do
				local newdata = {}

				for k, v in pairs(tbl.data) do
					if NSTATISTICS.Groups[k] then
						newdata[NSTATISTICS.Groups[k].printname] = v
					end
				end

				if table.Count(newdata) > 0 then
					tbl.data = newdata
				else
					table.remove(percent, k)
				end
			end

			for _, group in pairs(NSTATISTICS.Groups) do
				for _, tbl in pairs(percent) do
					local finded = false

					for k, v in pairs(tbl.data) do
						if k == group.printname then
							finded = true
							break
						end
					end

					if not finded then
						tbl.data[group.printname] = 0
					end
				end
			end

			func(percent)
		end,
		RawDataSending = function(func, data)
			for _, tbl in pairs(data) do
				if NSTATISTICS.Groups[tbl.data] then
					tbl.data = NSTATISTICS.Groups[tbl.data].printname
				end
			end

			func(data)
		end,
		Suspicious = nil,
		Beautifier = nil,
		ModifyFilterRawData = function(filter)
			local names = {}

			for k, v in pairs(NSTATISTICS.Groups) do
				names[k] = v.printname
			end

			return filter:FindLike(names) or filter
		end
	}
)

NSTATISTICS.Groups = NSTATISTICS.Groups or {}
local queue = {}

local function PrintErrorMessage(url, err)
	NSTATISTICS.PrintConsole("Error has occurred while loading page " .. url .. "  (" .. err .. ")")
end

local function checker(ply)
	-- If player has groupsjoined - then he, probably, has primarygroup
	NSTATISTICS.Provider.CallIfPlayerDataNotExists(
		"groupsjoined",
		ply,
		NSTATISTICS.GetCurDate(),
		function(exists)
			local id = ply:SteamID64()

			local profile = "http://steamcommunity.com/profiles/" .. id .. "/?xml=1"

			http.Fetch(
				profile,
				function(body)
					local joined = {}

					local IsPrimaryPattern = '<group isPrimary="(%d)">'
					local IdPattern = "<groupID64>(%d+)</groupID64>"

					local primary

					local ps, pe
					local ids, ide = nil, 0

					-- Shitty code
					repeat
						ps, pe = string.find(body, IsPrimaryPattern, ide + 1)
						ids, ide = string.find(body, IdPattern, ide + 1)

						if ps and pe and ids and ide then
							local primarysub = string.match(string.sub(body, ps, pe), IsPrimaryPattern)
							local id = string.match(string.sub(body, ids, ide), IdPattern)

							if primarysub and id then
								id = id .. " "

								if NSTATISTICS.Groups[id] then
									joined[id] = true

									if primarysub == "1" then
										primary = id
									end
								end
							end
						end
					until not ps or not pe or not ids or not ide

					local toadd = {}

					for k, v in pairs(joined) do
						table.insert(toadd, k)
					end

					NSTATISTICS.Provider.AddPlayerNote("groupsjoined", ply, util.TableToJSON(toadd))
					NSTATISTICS.Provider.AddPlayerNote("primarygroup", ply, primary or "")
				end,
				function(err)
					PrintErrorMessage(profile, err)
				end
			)
		end
	)
end

hook.Add(
	"PlayerInitialSpawn",
	"NStatistics_CheckPlayerGroups",
	function(ply)
		if NSTATISTICS.Groups and table.Count(NSTATISTICS.Groups) > 0 then
			checker(ply)
		else
			table.insert(queue, ply)
		end
	end
)

timer.Simple(
	5,
	function()
		for _, v in pairs(queue) do
			if IsValid(v) then
				checker(v)
			end
		end

		table.Empty(queue)
	end
)

hook.Add(
	"NStatistics_ConfigLoaded",
	"NStatistics_UpdateGroupsList",
	function(IsUpdated)
		NSTATISTICS.Groups = {}

		for _, v in pairs(NSTATISTICS.config.SteamGroups) do
			local url = v .. "/memberslistxml/?xml=1"

			http.Fetch(
				url,
				function(body)
					local id = string.match(body, "<groupID64>(%d+)</groupID64>")
					local name = string.match(body, "<groupName><!%[CDATA%[(.*)%]%]></groupName>")

					if id and name then
						NSTATISTICS.Groups[id .. " "] = {
							url = v,
							printname = name
						}
					end
				end,
				function(err)
					PrintErrorMessage(url, err)
				end
			)
		end
	end
)
