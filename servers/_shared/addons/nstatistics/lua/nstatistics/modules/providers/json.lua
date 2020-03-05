local provider = NSTATISTICS.Provider

local CacheDate
local cache = {}
local TypesChanged = {}

local function FileToJSON(path)
	local json = file.Read(path, "DATA")
	if not json then
		return
	end

	local data = util.JSONToTable(json)

	if not data then
		NSTATISTICS.PrintConsole("Corrupted JSON in file " .. path)
		return
	end

	return data
end

timer.Simple(
	0,
	function()
		local date = os.date("%Y_%m_%d_%H", os.time())

		for _, v in pairs(NSTATISTICS.Statistics) do
			local path = "nstatistics/data/" .. v.Name .. "/" .. date .. ".txt"

			if file.Exists(path, "DATA") then
				CacheDate = date
				cache[v.Name] = FileToJSON(path)
			end
		end
	end
)

function provider.ClearCacheType(type)
	cache[type] = nil
end

function provider.ClearCache()
	table.Empty(cache)
end

function provider.GetCache(type)
	if type then
		return cache[type]
	else
		return cache
	end
end

function provider.Save(type, time)
	if not cache[type] then
		return
	end

	local path = "nstatistics/data/" .. NSTATISTICS.EscapePath(type) .. "/"

	if not file.Exists(path, "DATA") then
		file.CreateDir(path)
	end

	local tbl = table.Copy(cache[type])
	tbl.IsPlayer = nil

	NSTATISTICS.RoundTable(tbl, 4)

	file.Write(path .. os.date("%Y_%m_%d_%H", time or os.time()) .. ".txt", util.TableToJSON(tbl))
end

function provider.SaveAll(time)
	for k, v in pairs(cache) do
		provider.Save(k, time)
	end
end

hook.Add(
	"NStatistics_HourChanged",
	"NStatistics_SaveCache",
	function()
		local time = os.time() - 3600

		provider.SaveAll(time)

		provider.ClearCache()
	end
)

local function CheckCache()
	local date = os.date("%Y_%m_%d_%H", os.time())

	if date ~= CacheDate then
		provider.SaveAll(CacheDate)

		CacheDate = date
		cache = {}
	end
end

function provider.AddNote(type, value, callback)
	if NSTATISTICS.Statistics[type] and not NSTATISTICS.Statistics[type].Disabled then
		CheckCache()

		if not cache[type] then
			cache[type] = {}
		end

		table.insert(cache[type], value)

		if NSTATISTICS.config.CacheSavingTime == 0 then
			provider.Save(type)
		else
			TypesChanged[type] = true
		end
	end

	if callback then
		callback()
	end
end

function provider.AddPlayerNote(type, ply, value, callback)
	if NSTATISTICS.Statistics[type] and not NSTATISTICS.Statistics[type].Disabled then
		CheckCache()

		if not cache[type] then
			cache[type] = {}
			cache[type].IsPlayer = true
		end

		ply = NSTATISTICS.ToSteamID(ply)

		if not cache[type][ply] then
			cache[type][ply] = {}
		end

		table.insert(cache[type][ply], value)

		if NSTATISTICS.config.CacheSavingTime == 0 then
			provider.Save(type)
		else
			TypesChanged[type] = true
		end
	end

	if callback then
		callback()
	end
end

if NSTATISTICS.config.CacheSavingTime ~= 0 then
	timer.Create(
		"NStatistics_SaveCache",
		NSTATISTICS.config.CacheSavingTime,
		0,
		function()
			provider.SaveAll()

			TypesChanged = {}
		end
	)
end

local function FilesIterator(path, startdate, enddate, iterator)
	local StartTime

	if startdate then
		StartTime =
			os.time(
			{
				year = startdate.year,
				month = startdate.month,
				day = startdate.day,
				hour = startdate.hour
			}
		)
	end

	local EndTime

	if enddate then
		EndTime =
			os.time(
			{
				year = enddate.year,
				month = enddate.month,
				day = enddate.day,
				hour = enddate.hour
			}
		)
	end

	local files = file.Find(path .. "*.txt", "DATA")

	for _, v in pairs(files) do
		local name = string.Replace(v, ".txt", "")

		if StartTime or EndTime then
			local time = os.time(NSTATISTICS.StrToDate(name))

			if not (StartTime and time < StartTime or EndTime and time > EndTime) then
				iterator(path .. v, name)
			end
		else
			iterator(path .. v, name)
		end
	end
end

local function ReadData(type, startdate, enddate, func)
	local data = {}

	FilesIterator(
		"nstatistics/data/" .. NSTATISTICS.EscapePath(type) .. "/",
		startdate,
		enddate,
		function(path, date)
			local FileData = FileToJSON(path)

			if FileData then
				func(data, FileData, date)
			end
		end
	)

	return data
end

function provider.ReadRawSharedData(type, servers, startdate, enddate, callback)
	local data =
		ReadData(
		type,
		startdate,
		enddate,
		function(toinsert, add, date)
			for _, v in pairs(add) do
				table.insert(toinsert, {v})
			end
		end
	)

	callback(data)
end

function provider.ReadRawPlayerData(type, servers, startdate, enddate, steamid, callback)
	local data =
		ReadData(
		type,
		startdate,
		enddate,
		function(toinsert, add)
			for id, tbl in pairs(add) do
				for _, v in pairs(tbl) do
					if not steamid or id == steamid then
						if not toinsert[id] then
							toinsert[id] = {}
						end

						table.insert(toinsert[id], v)
					end
				end
			end
		end
	)

	local collision = NSTATISTICS.Statistics[type].Collision

	if collision then
		data = collision(data)
	end

	callback(data)
end

local InfoIntervalCache = {}

function provider.ReadSharedDataInterval(
	type,
	servers,
	from,
	to,
	startdate,
	enddate,
	requesting,
	reload,
	filter,
	callback)
	local id = requesting:SteamID()

	timer.Remove("NSTATISTICS.config.RawDataCacheRemoving" .. id)

	if reload then
		InfoIntervalCache[id] = nil
	end

	if not InfoIntervalCache[id] or InfoIntervalCache[id] and InfoIntervalCache[id].type ~= type then
		InfoIntervalCache[id] =
			ReadData(
			type,
			startdate,
			enddate,
			function(toinsert, add, date)
				local NewDate = NSTATISTICS.GetDateFormat(NSTATISTICS.StrToDate(date))

				for _, v in pairs(add) do
					if not NSTATISTICS.ShouldBeFiltered(filter, v) then
						table.insert(
							toinsert,
							{
								date = NewDate,
								data = v,
								server = NSTATISTICS.config.ThisServer
							}
						)
					end
				end
			end
		)

		InfoIntervalCache[id].type = type

		timer.Create(
			"NSTATISTICS.config.RawDataCacheRemoving" .. id,
			NSTATISTICS.config.RawDataCacheRemoving,
			1,
			function()
				InfoIntervalCache[id] = nil
			end
		)
	end

	local tbl = {}

	for i = from, to do
		if InfoIntervalCache[id][i] then
			table.insert(tbl, InfoIntervalCache[id][i])
		end
	end

	callback(tbl, #InfoIntervalCache[id])
end

function provider.ReadPlayerDataInterval(
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
	local id = requesting:SteamID()

	timer.Remove("NSTATISTICS.config.RawDataCacheRemoving" .. id)

	if reload then
		InfoIntervalCache[id] = nil
	end

	if not InfoIntervalCache[id] then
		InfoIntervalCache[id] =
			ReadData(
			type,
			startdate,
			enddate,
			function(toinsert, add, date)
				local NewDate = NSTATISTICS.GetDateFormat(NSTATISTICS.StrToDate(date))

				for id, tbl in pairs(add) do
					for _, v in pairs(tbl) do
						if not NSTATISTICS.ShouldBeFiltered(filter, v) then
							table.insert(
								toinsert,
								{
									data = v,
									id = id,
									date = NewDate,
									server = NSTATISTICS.config.ThisServer
								}
							)
						end
					end
				end
			end
		)

		timer.Create(
			"NSTATISTICS.config.RawDataCacheRemoving",
			NSTATISTICS.config.RawDataCacheRemoving,
			1,
			function()
				InfoIntervalCache[id] = nil
			end
		)
	end

	local info

	if steamid then
		info = {}

		for _, v in pairs(InfoIntervalCache[id]) do
			if v.id == steamid then
				table.insert(info, v)
			end
		end
	else
		info = InfoIntervalCache[id]
	end

	local tbl = {}

	for i = from, to do
		if info[i] then
			table.insert(tbl, info[i])
		end
	end

	callback(tbl, #info)
end

function provider.GetRawDataDates(type, callback)
	local files = file.Find("nstatistics/data/" .. NSTATISTICS.EscapePath(type) .. "/*.txt", "DATA")

	local dates = {}

	for _, v in pairs(files) do
		local date = string.Replace(v, ".txt", "")
		dates[date] = true
	end

	local tbls = {}

	for k, _ in pairs(dates) do
		table.insert(tbls, NSTATISTICS.StrToDate(k))
	end

	callback(tbls)
end

local function GetFileName(year, month, day)
	return NSTATISTICS.DateToStr(year, month, day) .. ".txt"
end

function provider.WriteCalculatedData(type, data, year, month, day, callback)
	local path = "nstatistics/statistics/" .. NSTATISTICS.EscapePath(type) .. "/"

	if not file.Exists(path, "DATA") then
		file.CreateDir(path)
	end

	NSTATISTICS.RoundTable(data, 4)

	file.Write(path .. GetFileName(year, month, day), util.TableToJSON(data))

	provider.RemoveObsoleteRawData()

	callback()
end

function provider.ReadCalculatedData(type, servers, startdate, enddate, callback)
	local readed = {}

	FilesIterator(
		"nstatistics/statistics/" .. NSTATISTICS.EscapePath(type) .. "/",
		startdate,
		enddate,
		function(path, name)
			local data = FileToJSON(path)

			if data then
				table.insert(
					readed,
					{
						data = data,
						date = name,
						server = NSTATISTICS.config.ThisServer
					}
				)
			end
		end
	)

	callback(readed)
end

function provider.IsPlayerDataExists(type, ply, date, callback)
	ply = NSTATISTICS.ToSteamID(ply)
	local startdate, enddate = NSTATISTICS.GetDayEnds(date)

	local exists = false

	local data =
		ReadData(
		type,
		startdate,
		enddate,
		function(toinsert, add)
			if not exists and add[ply] then
				exists = true
			end
		end
	)

	callback(exists)
end

function provider.IsCalculated(type, year, month, day, callback)
	local path = "nstatistics/statistics/" .. NSTATISTICS.EscapePath(type) .. "/" .. GetFileName(year, month, day)

	callback(file.Exists(path, "DATA"))
end

function provider.UpdateData(type, data, date, callback)
	if NSTATISTICS.Statistics[type] and not NSTATISTICS.Statistics[type].Disabled then
		data = {data}
		local startdate, enddate = NSTATISTICS.GetDayEnds(date)

		if NSTATISTICS.IsDateBetween(startdate, enddate, date) and NSTATISTICS.config.CacheSavingTime > 0 then
			cache[type] = data
		end

		local json = util.TableToJSON(data)

		FilesIterator(
			"nstatistics/data/" .. NSTATISTICS.EscapePath(type) .. "/",
			startdate,
			enddate,
			function(path, name)
				file.Write(path, json)
			end
		)

		if callback then
			callback()
		end
	end
end

function provider.UpdatePlayerData(type, ply, data, date, callback)
	if NSTATISTICS.Statistics[type] and not NSTATISTICS.Statistics[type].Disabled then
		local startdate, enddate = NSTATISTICS.GetDayEnds(date)

		ply = NSTATISTICS.ToSteamID(ply)

		FilesIterator(
			"nstatistics/data/" .. NSTATISTICS.EscapePath(type) .. "/",
			startdate,
			enddate,
			function(path, name)
				local FileData = FileToJSON(path)

				if FileData then
					local changed = false

					for k, v in pairs(FileData) do
						if k == ply then
							FileData[k] = {data}
							changed = true

							break
						end
					end

					if changed then
						local date = NSTATISTICS.StrToDate(name)

						provider.RemoveRawDataType(type, date, date)

						NSTATISTICS.RoundTable(FileData, 4)

						file.Write(path, util.TableToJSON(FileData))
					end
				end
			end
		)

		if callback then
			callback()
		end
	end
end

function NSTATISTICS.Provider.ManuallyUpdateStatistics(type, startdate, enddate, updater)
	FilesIterator(
		"nstatistics/statistics/" .. NSTATISTICS.EscapePath(type) .. "/",
		startdate,
		enddate,
		function(path, name)
			local data = file.Read(path)

			if data then
				local newdata = updater(data)

				if isstring(newdata) then
					file.Write(path, newdata)
				elseif newdata == true then
					file.Delete(path)
				end
			end
		end
	)
end

function NSTATISTICS.Provider.ManuallyUpdateData(type, startdate, enddate, updater)
	FilesIterator(
		"nstatistics/data/" .. NSTATISTICS.EscapePath(type) .. "/",
		startdate,
		enddate,
		function(path, name)
			local data = FileToJSON(path)

			if data then
				local updated = false
				local newdata = {}

				for id, tbl in pairs(data) do
					local newtbl = {}

					for k, v in pairs(tbl) do
						local updatedData = updater(v)

						-- Add modified
						if isstring(updatedData) then
							-- Don't add
							table.insert(newtbl, updatedData)
							updated = true
						elseif updatedData == true then
							-- Add without changes
							updated = true
						else
							table.insert(newtbl, v)
						end
					end

					if #newtbl > 0 then
						newdata[id] = newtbl
					end
				end

				if updated then
					if table.Count(newdata) == 0 then
						file.Delete(path)
					else
						file.Write(path, util.TableToJSON(newdata))
					end
				end
			else
				ErrorNoHalt("nStatistics ManuallyUpdateStatistics: Corrupted JSON in " .. path)
			end
		end
	)
end

function provider.RemoveRawDataType(type, startdate, enddate, callback)
	FilesIterator(
		"nstatistics/data/" .. NSTATISTICS.EscapePath(type) .. "/",
		startdate,
		enddate,
		function(path)
			file.Delete(path)
		end
	)

	cache[type] = nil

	if callback then
		callback()
	end
end

function provider.RemoveRawData(startdate, enddate, callback)
	local _, dirs = file.Find("nstatistics/data/*", "DATA")

	for _, dir in pairs(dirs) do
		provider.RemoveRawDataType(dir, startdate, enddate, callback)
	end
end

function provider.RemoveStatisticsType(type, startdate, enddate, callback)
	FilesIterator(
		"nstatistics/statistics/" .. NSTATISTICS.EscapePath(type) .. "/",
		startdate,
		enddate,
		function(path)
			file.Delete(path)
		end
	)

	if callback then
		callback()
	end
end

function provider.RemoveStatistics(startdate, enddate, callback)
	local _, dirs = file.Find("nstatistics/statistics/*", "DATA")

	for _, dir in pairs(dirs) do
		provider.RemoveStatisticsType(dir, startdate, enddate, callback)
	end
end

hook.Add(
	"ShutDown",
	"NStatistics_SaveCache",
	function()
		provider.SaveAll()
	end
)

function provider.ImportRawData(data)
	local toadd = provider.PrepareRawData(data)

	NSTATISTICS.PrintConsole("Importing raw data...")

	for type, typed in pairs(toadd) do
		NSTATISTICS.PrintConsole("Importing raw data type: " .. type)

		local path = "nstatistics/data/" .. NSTATISTICS.EscapePath(type) .. "/"

		if not file.Exists(path, "DATA") then
			file.CreateDir(path)
		end

		for date, data in pairs(typed) do
			local savepath = path .. NSTATISTICS.EscapePath(date) .. ".txt"
			file.Write(savepath, util.TableToJSON(data))
		end
	end

	NSTATISTICS.PrintConsole("Raw data was imported")
end

function provider.ImportStatistics(data)
	local toadd = provider.PrepareStatistics(data)

	NSTATISTICS.PrintConsole("Importing statistics...")

	for type, typed in pairs(toadd) do
		NSTATISTICS.PrintConsole("Importing statistics type: " .. type)

		local path = "nstatistics/statistics/" .. NSTATISTICS.EscapePath(type) .. "/"

		if not file.Exists(path, "DATA") then
			file.CreateDir(path)
		end

		for date, data in pairs(typed) do
			local savepath = path .. NSTATISTICS.EscapePath(date) .. ".txt"
			file.Write(savepath, util.TableToJSON(data))
		end
	end

	NSTATISTICS.PrintConsole("Statistics was imported")
end
