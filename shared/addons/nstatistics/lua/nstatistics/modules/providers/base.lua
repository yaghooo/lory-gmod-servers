function NSTATISTICS.Provider.ReadRawInfo(isplayer, type, servers, startdate, enddate, callback)
	if isplayer then
		return NSTATISTICS.Provider.ReadRawPlayerData(type, servers, startdate, enddate, nil, callback)
	else
		return NSTATISTICS.Provider.ReadRawSharedData(type, servers, startdate, enddate, callback)
	end
end

function NSTATISTICS.Provider.ReadInfoInterval(
	isplayer,
	type,
	servers,
	from,
	to,
	startdate,
	enddate,
	requesting,
	reload,
	steamid,
	filter,
	callback)
	if isplayer then
		return NSTATISTICS.Provider.ReadPlayerDataInterval(
			type,
			servers,
			from,
			to,
			startdate,
			enddate,
			requesting,
			reload,
			steamid,
			filter,
			callback
		)
	else
		return NSTATISTICS.Provider.ReadSharedDataInterval(
			type,
			servers,
			from,
			to,
			startdate,
			enddate,
			requesting,
			reload,
			filter,
			callback
		)
	end
end

function NSTATISTICS.Provider.RemoveObsoleteRawData(callback)
	local time = os.time() - NSTATISTICS.StrToTime(NSTATISTICS.config.RemoveRawData)

	local date = NSTATISTICS.GetDateWithHours(time)
	date.hour = 0

	NSTATISTICS.Provider.RemoveRawData(nil, date, callback)
end

function NSTATISTICS.Provider.CallIfPlayerDataNotExists(type, ply, date, callback)
	NSTATISTICS.Provider.IsPlayerDataExists(
		type,
		ply,
		date,
		function(exists)
			if not exists then
				callback()
			end
		end
	)
end

local cache = {}

-- For debug
function NSTATISTICS.Provider.GetUpdateDataCache()
	return cache
end

function NSTATISTICS.Provider.UpdateOrAddToday(type, ply, data, calculate, callback)
	if not cache[type] then
		cache[type] = {}
	end

	local curdate = NSTATISTICS.GetCurDate()
	ply = NSTATISTICS.ToSteamID(ply)

	if cache[type][ply] then
		local newdata = calculate({data, cache[type][ply]})
		cache[type][ply] = newdata

		NSTATISTICS.Provider.UpdatePlayerData(type, ply, newdata, curdate)

		if callback then
			callback(true, ply, newdata)
		end
	else
		NSTATISTICS.Provider.IsPlayerDataExists(
			type,
			ply,
			curdate,
			function(exists)
				if not cache[type] then
					cache[type] = {}
				end

				if exists then
					local startdate, enddate = NSTATISTICS.GetDayEnds(curdate)

					NSTATISTICS.Provider.ReadRawPlayerData(
						type,
						{NSTATISTICS.config.ThisServer},
						startdate,
						enddate,
						nil,
						function(old)
							if old[ply] then
								table.insert(old[ply], data)

								local newdata = calculate(old[ply])
								cache[type][ply] = newdata

								NSTATISTICS.Provider.UpdatePlayerData(type, ply, newdata, curdate)

								if callback then
									callback(true, ply, newdata)
								end
							end
						end
					)
				else
					cache[type][ply] = data

					NSTATISTICS.Provider.AddPlayerNote(type, ply, data)

					if callback then
						callback(false, ply, data)
					end
				end
			end
		)
	end

	if not IsValid(player.GetBySteamID(ply)) then
		cache[type][ply] = nil
	end
end

local readedRawData = 0

function NSTATISTICS.Provider.ReadRawSharedDataWithDates(type, servers, startdate, enddate, callback)
	local reading = readedRawData

	NSTATISTICS.Provider.GetRawDataDates(
		type,
		function(dates)
			if reading ~= readedRawData then
				return
			end

			local info = {}
			local tocall = {}

			for _, date in pairs(dates) do
				if NSTATISTICS.IsDateBetween(date, startdate, enddate) then
					table.insert(tocall, date)
				end
			end

			for k, v in pairs(tocall) do
				NSTATISTICS.Provider.ReadRawSharedData(
					type,
					servers,
					v,
					v,
					function(data)
						if curexported ~= exported then
							return
						end

						if table.Count(data) > 0 then
							table.insert(
								info,
								{
									Date = v,
									Data = data
								}
							)
						end

						tocall[k] = nil

						if table.Count(tocall) == 0 then
							callback(info)
						end
					end
				)
			end
		end
	)
end

local readedPlayerData = 0

function NSTATISTICS.Provider.ReadRawPlayerDataWithDates(type, servers, startdate, enddate, callback)
	local reading = readedPlayerData

	NSTATISTICS.Provider.GetRawDataDates(
		type,
		function(dates)
			if reading ~= readedPlayerData then
				return
			end

			local info = {}
			local tocall = {}

			for _, date in pairs(dates) do
				if NSTATISTICS.IsDateBetween(date, startdate, enddate) then
					table.insert(tocall, date)
				end
			end

			-- If we have nothing to read
			if table.Count(tocall) == 0 then
				callback({})
				return
			end

			for k, v in pairs(tocall) do
				NSTATISTICS.Provider.ReadRawPlayerData(
					type,
					servers,
					v,
					v,
					nil,
					function(data)
						if curexported ~= exported then
							return
						end

						if table.Count(data) > 0 then
							table.insert(
								info,
								{
									Date = v,
									Data = data
								}
							)
						end

						tocall[k] = nil

						if table.Count(tocall) == 0 then
							callback(info)
						end
					end
				)
			end
		end
	)
end

function NSTATISTICS.Provider.ReadRawDataWithDates(isplayer, type, servers, startdate, enddate, callback)
	if isplayer then
		NSTATISTICS.Provider.ReadRawPlayerDataWithDates(type, servers, startdate, enddate, callback)
	else
		NSTATISTICS.Provider.ReadRawSharedDataWithDates(type, servers, startdate, enddate, callback)
	end
end

function NSTATISTICS.Provider.PrepareRawData(data)
	local toadd = {}

	NSTATISTICS.PrintConsole("Preparing raw data to import...")

	for _, typed in pairs(data) do
		if not typed.Type then
			NSTATISTICS.PrintConsole("Type isn't specified, skipping: " .. util.TableToJSON(typed))
		elseif not typed.Data then
			NSTATISTICS.PrintConsole("Data isn't specified, skipping: " .. util.TableToJSON(typed))
		else
			toadd[typed.Type] = {}
			local ins = toadd[typed.Type]

			if not NSTATISTICS.Statistics[typed.Type] then
				NSTATISTICS.PrintConsole("Unknown statistic '" .. typed.Type .. "', skipping")
			else
				local forPlayers = NSTATISTICS.Statistics[typed.Type].ForPlayers

				for _, v in pairs(typed.Data) do
					if not ins[v.Date] then
						ins[v.Date] = {}
					end

					if forPlayers then
						for k, toinsertTable in pairs(v.Data) do
							if not ins[v.Date][k] then
								ins[v.Date][k] = {}
							end

							for _, toinsert in pairs(toinsertTable) do
								table.insert(ins[v.Date][k], toinsert)
							end
						end
					else
						for _, toinsertTable in pairs(v.Data) do
							for _, toinsert in pairs(toinsertTable) do
								table.insert(ins[v.Date], toinsert)
							end
						end
					end
				end
			end
		end
	end

	return toadd
end

function NSTATISTICS.Provider.PrepareStatistics(data)
	local toadd = {}

	NSTATISTICS.PrintConsole("Preparing statistics to import...")

	for _, typed in pairs(data) do
		if not typed.Type then
			NSTATISTICS.PrintConsole("Type isn't specified, skipping: " .. util.TableToJSON(typed))
		elseif not typed.Data then
			NSTATISTICS.PrintConsole("Data isn't specified, skipping: " .. util.TableToJSON(typed))
		else
			toadd[typed.Type] = {}
			local ins = toadd[typed.Type]

			if not NSTATISTICS.Statistics[typed.Type] then
				NSTATISTICS.PrintConsole("Unknown statistic '" .. typed.Type .. "', skipping")
			else
				for _, tbl in pairs(typed.Data) do
					if not tbl.data then
						NSTATISTICS.PrintConsole("Data isn't specified, skipping: " .. util.TableToJSON(tbl))
					elseif not tbl.date then
						NSTATISTICS.PrintConsole("Date isn't specified, skipping: " .. util.TableToJSON(tbl))
					else
						ins[tbl.date] = tbl.data
					end
				end
			end
		end
	end

	return toadd
end

hook.Add(
	"NStatistics_DayChanged",
	"NStatistics_RemoveUpdateDataCache",
	function()
		cache = {}
	end
)

hook.Add(
	"PlayerDisconnected",
	"NStatistics_RemoveUpdateDataCache",
	function(ply)
		local ToRemoveID = ply:SteamID()

		for _, plys in pairs(cache) do
			for id, data in pairs(plys) do
				if id == ToRemoveID then
					plys[id] = nil
				end
			end
		end
	end
)

-- We don't want to fill up console with our messages
local spammed = {}

local function stub(func)
	if NSTATISTICS.ProviderFreezed then
		return
	end

	if not spammed[func] then
		local provider = NSTATISTICS.config.Provider
		ErrorNoHalt(
			"Called provider stub function for: " ..
				func .. ", current provider is: " .. provider .. ". Please, check provider settings or open a support ticket\n"
		)
		debug.Trace()
		spammed[func] = true
	end
end

-- Functions that should be implemented in the providers

local function loadStubs()
	function NSTATISTICS.Provider.AddNote(type, value, callback)
		stub("AddNote")
	end

	function NSTATISTICS.Provider.AddPlayerNote(type, ply, value, callback)
		stub("AddPlayerNote")
	end

	function NSTATISTICS.Provider.ReadRawSharedData(type, servers, startdate, enddate, callback)
		stub("ReadRawSharedData")
	end

	function NSTATISTICS.Provider.ReadRawPlayerData(type, servers, startdate, enddate, steamid, callback)
		stub("ReadRawPlayerData")
	end

	function NSTATISTICS.Provider.ReadSharedDataInterval(
		type,
		servers,
		from,
		to,
		startdate,
		enddate,
		requesting,
		reload,
		callback)
		stub("ReadSharedDataInterval")
	end

	function NSTATISTICS.Provider.ReadPlayerDataInterval(
		type,
		servers,
		from,
		to,
		startdate,
		enddate,
		requesting,
		reload,
		steamid,
		callback)
		stub("ReadPlayerDataInterval")
	end

	function NSTATISTICS.Provider.GetRawDataDates(type, callback)
		stub("GetRawDataDates")
	end

	function NSTATISTICS.Provider.WriteCalculatedData(type, data, year, month, day, callback)
		stub("WriteCalculatedData")
	end

	function NSTATISTICS.Provider.ReadCalculatedData(type, servers, startdate, enddate, callback)
		stub("ReadCalculatedData")
	end

	function NSTATISTICS.Provider.IsPlayerDataExists(type, ply, date, callback)
		stub("IsPlayerDataExists")
	end

	function NSTATISTICS.Provider.IsCalculated(type, year, month, day, callback)
		stub("IsCalculated")
	end

	function NSTATISTICS.Provider.UpdateData(type, data, date, callback)
		stub("UpdateData")
	end

	function NSTATISTICS.Provider.UpdatePlayerData(type, ply, data, date, callback)
		stub("UpdatePlayerData")
	end

	function NSTATISTICS.Provider.ManuallyUpdateStatistics(type, startdate, enddate, updater)
		stub("ManuallyUpdateStatistics")
	end

	function NSTATISTICS.Provider.ManuallyUpdateData(type, startdate, enddate, updater)
		stub("ManuallyUpdateData")
	end

	function NSTATISTICS.Provider.RemoveRawDataType(type, startdate, enddate, callback)
		stub("RemoveRawDataType")
	end

	function NSTATISTICS.Provider.RemoveRawData(startdate, enddate, callback)
		stub("RemoveRawData")
	end

	function NSTATISTICS.Provider.RemoveStatisticsType(type, startdate, enddate, callback)
		stub("RemoveStatisticsType")
	end

	function NSTATISTICS.Provider.RemoveStatistics(startdate, enddate, callback)
		stub("RemoveStatistics")
	end

	function NSTATISTICS.Provider.ImportRawData(data)
		stub("ImportRawData")
	end

	function NSTATISTICS.Provider.ImportStatistics(data)
		stub("ImportStatistics")
	end
end

loadStubs()

function NSTATISTICS.FreezeProvider()
	NSTATISTICS.ProviderFreezed = true
	loadStubs()
end
