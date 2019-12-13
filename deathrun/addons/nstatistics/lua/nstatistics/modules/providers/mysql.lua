local provider = NSTATISTICS.Provider
provider.SQLite = NSTATISTICS.config.SQLite

if not provider.SQLite then
	local isWindows = system.IsWindows()
	local isLinux = system.IsLinux()

	local isWindowsModuleExists = file.Exists("lua/bin/gmsv_mysqloo_win32.dll", "GAME")
	local isLinuxModuleExists = file.Exists("lua/bin/gmsv_mysqloo_linux.dll", "GAME")

	local add = ". Install MySQLOO correctrly or set SQLite = true in the config."

	if isWindows and not isWindowsModuleExists and isLinuxModuleExists then
		NSTATISTICS.Error("You have installed MySQLOO for Linux, but you have Windows OS" .. add)
	end

	if isWindows and not isWindowsModuleExists then
		NSTATISTICS.Error("You haven't installed MySQLOO for Windows." .. add)
	end

	if isLinux and not isLinuxModuleExists and isWindowsModuleExists then
		NSTATISTICS.Error("You have installed MySQLOO for Windows, but you have Linux OS" .. add)
	end

	if isLinux and not isLinuxModuleExists then
		NSTATISTICS.Error("You haven't installed MySQLOO for Linux." .. add)
	end

	require("mysqloo")
end

function provider.Query(qs, callback, errcallback)
	if provider.SQLite then
		local ret = sql.Query(qs)

		if ret == false then
			ErrorNoHalt("nStatistics MySQL error: " .. sql.LastError() .. " (" .. qs .. ")")
			debug.Trace()

			if errcallback then
				errcallback()
			end
		end

		if callback then
			callback(ret or {})
		end
	else
		local q = provider.DB:query(qs)

		if callback then
			function q:onSuccess(data)
				callback(data, q)
			end
		end

		function q:onError(err, sql)
			ErrorNoHalt("nStatistics MySQL error: " .. err .. " (" .. sql .. ")")
			debug.Trace()

			if errcallback then
				errcallback(q)
			end
		end

		q:start()
	end
end

function provider.Escape(str)
	str = tostring(str)
	local escaped

	if provider.SQLite then
		escaped = SQLStr(str, true)
	else
		escaped = provider.DB:escape(str)
	end

	-- Doesn't connected to the server
	if not escaped then
		escaped = SQLStr(str, true)

		if not escaped then
			error("Can't escape '" .. str .. "', SQLite = " .. tostring(provider.SQLite))
		end
	end

	return escaped
end

function provider.Initialize()
	local autoincrement = provider.SQLite and "AUTOINCREMENT" or "AUTO_INCREMENT"

	local CreateData =
		[[
		CREATE TABLE IF NOT EXISTS ns_data (
			id INTEGER NOT NULL PRIMARY KEY ]] ..
		autoincrement ..
			[[,
			type VARCHAR(30) NOT NULL,
			steamid VARCHAR(50) DEFAULT NULL,
			data VARCHAR(255) NOT NULL,
			time INTEGER NOT NULL,
			server SMALLINT UNSIGNED NOT NULL
		);
	]]

	provider.Query(CreateData)

	local CreateStatistics =
		[[
		CREATE TABLE IF NOT EXISTS ns_statistics (
			id INTEGER NOT NULL PRIMARY KEY ]] ..
		autoincrement ..
			[[,
			type VARCHAR(30) NOT NULL,
			data VARCHAR(2048) NOT NULL,
			time INTEGER NOT NULL,
			server SMALLINT UNSIGNED NOT NULL
		);
	]]

	provider.Query(CreateStatistics)
end

local attempts = 0

function provider.Connect()
	if provider.SQLite then
		provider.Initialize()
	else
		local host = NSTATISTICS.config.Host
		local username = NSTATISTICS.config.Username
		local password = NSTATISTICS.config.Password
		local database = NSTATISTICS.config.Database
		local port = NSTATISTICS.config.Port

		provider.DB = mysqloo.connect(host, username, password, database, port)

		-- Add initialization in the queue
		provider.Initialize()

		function provider.DB:onConnected()
			NSTATISTICS.PrintConsole("Connected to MySQL server")
		end

		function provider.DB:onConnectionFailed(err)
			NSTATISTICS.PrintConsole("Connection failed with error: " .. err)
			NSTATISTICS.PrintConsole("Retrying in 10 seconds...")

			if attempts >= 10 then
				NSTATISTICS.PrintConsole(
					"Can't connnect to MySQL server. Please fix the problem and use command 'nstatistics_dbconnect' to try again."
				)
				attempts = 0
			else
				timer.Simple(
					10,
					function()
						attempts = attempts + 1
						provider.Connect()
					end
				)
			end
		end

		provider.DB:connect()
	end
end

concommand.Add(
	"nstatistics_dbconnect",
	function(ply)
		if table.HasValue(NSTATISTICS.config.CanConnectDBManually, ply:GetUserGroup()) then
			provider.Connect()
		end
	end
)

provider.Connect()

local function GetCurTime()
	local time = os.time()

	local year = os.date("%Y", time)
	local month = os.date("%m", time)
	local day = os.date("%d", time)
	local hour = os.date("%H", time)

	return os.time(
		{
			year = tonumber(year),
			month = tonumber(month),
			day = tonumber(day),
			hour = tonumber(hour)
		}
	)
end

-- Secretly add argument in the end, shhh
function provider.AddNote(type, value, callback, time)
	if NSTATISTICS.Statistics[type] and not NSTATISTICS.Statistics[type].Disabled then
		if isnumber(value) then
			value = math.Round(value, 4)
		end

		local query = "INSERT INTO ns_data (type, data, time, server) VALUES ('%s', '%s', '%s', '%s')"
		provider.Query(
			string.format(
				query,
				provider.Escape(type),
				provider.Escape(value),
				provider.Escape(time or GetCurTime()),
				provider.Escape(NSTATISTICS.config.ThisServer)
			),
			callback
		)
	end
end

-- Secretly add argument in the end, shhh. And keep old comment here: a90fd4f6958c4144f236a0d55e1735842980ff3745db51bb8287f494191b32c9
function provider.AddPlayerNote(type, ply, value, callback, curtime)
	if NSTATISTICS.Statistics[type] and not NSTATISTICS.Statistics[type].Disabled then
		if isnumber(value) then
			value = math.Round(value, 4)
		end

		local query = "INSERT INTO ns_data (type, steamid, data, time, server) VALUES ('%s', '%s', '%s', '%s', '%s')"

		provider.Query(
			string.format(
				query,
				provider.Escape(type),
				provider.Escape(NSTATISTICS.ToSteamID(ply)),
				provider.Escape(tostring(value)),
				provider.Escape(time or GetCurTime()),
				provider.Escape(NSTATISTICS.config.ThisServer)
			),
			callback
		)
	end
end

local function AddWhereOr(query)
	if string.find(query, "WHERE") then
		return query .. " AND"
	else
		return query .. " WHERE"
	end
end

local function AddDateCondition(query, startdate, enddate)
	local added = false

	if startdate or enddate then
		local AddAnd = false

		query = AddWhereOr(query)

		if startdate then
			query = query .. " time >= '" .. provider.Escape(os.time(startdate)) .. "'"
			AddAnd = true
		end

		if enddate then
			if AddAnd then
				query = query .. " AND"
			end

			query = query .. " time <= '" .. provider.Escape(os.time(enddate)) .. "'"
		end

		added = true
	end

	return query, added
end

-- 16681544
local function AddServersConditions(query, servers)
	local added = false

	if servers and #servers > 0 then
		query = AddWhereOr(query)
		query = query .. " ("

		local first = true

		for _, v in pairs(servers) do
			if first then
				first = false
			else
				query = query .. " OR"
			end

			query = query .. " server = '" .. provider.Escape(v) .. "'"
		end

		query = query .. ")"

		added = true
	end

	return query, added
end

local function AddFilter(query, filter, field)
	field = provider.Escape(field)

	local SQL = NSTATISTICS.FilterToSQL(filter, field, provider.Escape)

	if SQL and SQL ~= "" then
		query = AddWhereOr(query)
		query = query .. " " .. SQL
	end

	return query
end

function provider.ReadRawSharedData(type, servers, startdate, enddate, callback)
	local query =
		AddDateCondition("SELECT data FROM ns_data WHERE type = '" .. provider.Escape(type) .. "'", startdate, enddate)
	query = AddServersConditions(query, servers)

	provider.Query(
		query,
		function(rows)
			local data = {}

			for _, tbl in pairs(rows) do
				table.insert(data, {tbl.data})
			end

			callback(data)
		end
	)
end

function provider.ReadRawPlayerData(type, servers, startdate, enddate, steamid, callback)
	local query =
		AddDateCondition(
		"SELECT steamid, data FROM ns_data WHERE type = '" .. provider.Escape(type) .. "'",
		startdate,
		enddate
	)
	query = AddServersConditions(query, servers)

	if steamid then
		query = query .. " AND steamid = '" .. provider.Escape(steamid) .. "'"
	end

	provider.Query(
		query,
		function(rows)
			local data = {}

			for _, tbl in pairs(rows) do
				if tbl.steamid then
					if not data[tbl.steamid] then
						data[tbl.steamid] = {}
					end

					table.insert(data[tbl.steamid], tbl.data)
				end
			end

			local collision = NSTATISTICS.Statistics[type].Collision

			if collision then
				data = collision(data)
			end

			callback(data)
		end
	)
end

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
	local query =
		AddDateCondition(
		"SELECT data, time, server FROM ns_data WHERE type = '" .. provider.Escape(type) .. "'",
		startdate,
		enddate
	)
	query = AddServersConditions(query, servers)
	query = AddFilter(query, filter, "data")

	query = query .. " ORDER BY time DESC"
	query = query .. " LIMIT " .. (from - 1) .. ", " .. (to - from)

	local count =
		AddDateCondition(
		"SELECT COUNT(*) AS cnt FROM ns_data WHERE type = '" .. provider.Escape(type) .. "'",
		startdate,
		enddate
	)
	count = AddServersConditions(count, servers)
	count = AddFilter(count, filter, "data")

	query = query .. "; " .. count

	provider.Query(
		query,
		function(rows, q)
			local data = {}

			for _, tbl in pairs(rows) do
				if not provider.SQLite or not tbl.cnt then
					table.insert(
						data,
						{
							data = tbl.data,
							date = NSTATISTICS.GetDateFormat(NSTATISTICS.GetDate(tbl.time)),
							server = tbl.server
						}
					)
				end
			end

			local count

			if provider.SQLite then
				count = tonumber(rows[#rows].cnt)
			else
				q:getNextResults()
				count = q:getData()[1].cnt
			end

			callback(data, count)
		end
	)
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
	local query =
		AddDateCondition(
		"SELECT steamid, data, time, server FROM ns_data WHERE type = '" .. provider.Escape(type) .. "'",
		startdate,
		enddate
	)
	query = AddServersConditions(query, servers)
	query = AddFilter(query, filter, "data")

	local count =
		AddDateCondition(
		"SELECT COUNT(*) AS cnt FROM ns_data WHERE type = '" .. provider.Escape(type) .. "'",
		startdate,
		enddate
	)
	count = AddServersConditions(count, servers)
	count = AddFilter(count, filter, "data")

	if steamid then
		local condition = " AND steamid = '" .. provider.Escape(steamid) .. "'"

		query = query .. condition
		count = count .. condition
	end

	query = query .. " ORDER BY time DESC"
	query = query .. " LIMIT " .. (from - 1) .. ", " .. (to - from)

	query = query .. "; " .. count

	provider.Query(
		query,
		function(rows, q)
			local data = {}

			for _, tbl in pairs(rows) do
				if not provider.SQLite or not tbl.cnt then
					table.insert(
						data,
						{
							data = tbl.data,
							id = tbl.steamid,
							date = NSTATISTICS.GetDateFormat(NSTATISTICS.GetDate(tbl.time)),
							server = tbl.server
						}
					)
				end
			end

			local count

			if provider.SQLite then
				count = tonumber(rows[#rows].cnt)
			else
				q:getNextResults()
				count = q:getData()[1].cnt
			end

			callback(data, count)
		end
	)
end

function provider.GetRawDataDates(type, callback)
	local query = "SELECT time FROM ns_data WHERE server = '" .. provider.Escape(NSTATISTICS.config.ThisServer) .. "'"

	provider.Query(
		query,
		function(rows)
			local time = {}

			for _, v in pairs(rows) do
				time[v.time] = true
			end

			local dates = {}

			for k, v in pairs(time) do
				table.insert(dates, NSTATISTICS.GetDateWithHours(k))
			end

			callback(dates)
		end
	)
end

function provider.WriteCalculatedData(type, data, year, month, day, callback)
	local time =
		os.time(
		{
			year = year,
			month = month,
			day = day
		}
	)

	NSTATISTICS.RoundTable(data, 4)

	local query = "INSERT INTO ns_statistics (type, data, time, server) VALUES ('%s', '%s', '%s', '%s')"
	provider.Query(
		string.format(
			query,
			provider.Escape(type),
			provider.Escape(util.TableToJSON(data)),
			provider.Escape(time),
			provider.Escape(NSTATISTICS.config.ThisServer)
		),
		callback
	)

	provider.RemoveObsoleteRawData()
end

function provider.ReadCalculatedData(type, servers, startdate, enddate, callback)
	local query =
		AddDateCondition(
		"SELECT id, data, time, server FROM ns_statistics WHERE type = '" .. provider.Escape(type) .. "'",
		startdate,
		enddate
	)
	query = AddServersConditions(query, servers)

	provider.Query(
		query,
		function(rows)
			local data = {}

			for _, tbl in pairs(rows) do
				local date = NSTATISTICS.GetDate(tbl.time)

				local jsontbl = util.JSONToTable(tbl.data)

				if not jsontbl then
					NSTATISTICS.PrintConsole("Corrupted data in ns_statistics table with ID: " .. tbl.id)
				else
					table.insert(
						data,
						{
							data = jsontbl,
							date = NSTATISTICS.DateToStr(date.year, date.month, date.day),
							server = tbl.server
						}
					)
				end
			end

			callback(data)
		end
	)
end

function provider.IsPlayerDataExists(type, ply, date, callback)
	ply = NSTATISTICS.ToSteamID(ply)
	local startdate, enddate = NSTATISTICS.GetDayEnds(date)

	local query =
		AddDateCondition(
		"SELECT EXISTS(SELECT * FROM ns_data WHERE type = '" .. provider.Escape(type) .. "'",
		startdate,
		enddate
	)
	query =
		query ..
		" AND steamid = '" ..
			provider.Escape(ply) .. "' AND server = '" .. provider.Escape(NSTATISTICS.config.ThisServer) .. "') AS ex"

	provider.Query(
		query,
		function(rows)
			callback(rows[1] and tonumber(rows[1]["ex"]) == 1)
		end
	)
end

function provider.IsCalculated(type, year, month, day, callback)
	local time =
		os.time(
		{
			year = year,
			month = month,
			day = day
		}
	)
	local query = "SELECT COUNT(*) AS cnt FROM ns_statistics WHERE type = '%s' AND time = '%s' AND server = '%s'"

	provider.Query(
		string.format(query, provider.Escape(type), provider.Escape(time), provider.Escape(NSTATISTICS.config.ThisServer)),
		function(rows)
			callback(tonumber(rows[1].cnt) > 0)
		end
	)
end

function provider.UpdateData(type, data, date, callback)
	if NSTATISTICS.Statistics[type] and not NSTATISTICS.Statistics[type].Disabled then
		local startdate, enddate = NSTATISTICS.GetDayEnds(date)

		local query =
			AddDateCondition(
			"UPDATE ns_data SET data = '" .. provider.Escape(data) .. "' WHERE type = '" .. provider.Escape(type) .. "'",
			startdate,
			enddate
		)
		query = query .. " AND server = '" .. provider.Escape(NSTATISTICS.config.ThisServer) .. "'"

		provider.Query(query, callback)
	end
end

function provider.UpdatePlayerData(type, ply, data, date, callback)
	if NSTATISTICS.Statistics[type] and not NSTATISTICS.Statistics[type].Disabled then
		local startdate, enddate = NSTATISTICS.GetDayEnds(date)

		ply = NSTATISTICS.ToSteamID(ply)

		if isnumber(data) then
			data = math.Round(data, 4)
		end

		local query =
			AddDateCondition(
			"UPDATE ns_data SET data = '" .. provider.Escape(data) .. "' WHERE type = '" .. provider.Escape(type) .. "'",
			startdate,
			enddate
		)
		query =
			query ..
			" AND steamid = '" ..
				provider.Escape(ply) .. "' AND server = '" .. provider.Escape(NSTATISTICS.config.ThisServer) .. "'"

		provider.Query(query, callback)
	end
end

local function update(sqlTable, type, startdate, enddate, updater)
	sqlTable = provider.Escape(sqlTable)

	local query =
		AddDateCondition(
		"SELECT id, data FROM " .. sqlTable .. " WHERE type = '" .. provider.Escape(type) .. "'",
		startdate,
		enddate
	)
	query = query .. " AND server = '" .. provider.Escape(NSTATISTICS.config.ThisServer) .. "'"

	provider.Query(
		query,
		function(rows)
			for _, row in pairs(rows) do
				local newdata = updater(row.data)

				if isstring(newdata) then
					local update =
						"UPDATE " ..
						sqlTable .. " SET data = '" .. provider.Escape(newdata) .. "' WHERE id = '" .. provider.Escape(row.id) .. "'"
					provider.Query(update)
				elseif newdata == true then
					local remove = "DELETE FROM " .. sqlTable .. " WHERE id = '" .. provider.Escape(row.id) .. "'"
					provider.Query(remove)
				end
			end
		end
	)
end

function NSTATISTICS.Provider.ManuallyUpdateStatistics(type, startdate, enddate, updater)
	update("ns_statistics", type, startdate, enddate, updater)
end

function NSTATISTICS.Provider.ManuallyUpdateData(type, startdate, enddate, updater)
	update("ns_data", type, startdate, enddate, updater)
end

function provider.RemoveRawData(startdate, enddate, callback)
	local query, added = AddDateCondition("DELETE FROM ns_data", startdate, enddate)

	if added then
		query = query .. " AND"
	else
		query = query .. " WHERE"
	end

	query = query .. " server = '" .. provider.Escape(NSTATISTICS.config.ThisServer) .. "'"
	provider.Query(query, callback)
end

function provider.RemoveStatisticsType(type, startdate, enddate, callback)
	local query = AddDateCondition("DELETE FROM ns_statistics ", startdate, enddate)
	query =
		query ..
		" AND server = '" .. provider.Escape(NSTATISTICS.config.ThisServer) .. "' AND type = " .. provider.Escape(type) .. "'"
	provider.Query(query, callback)
end

function provider.RemoveStatistics(startdate, enddate, callback)
	local query, added = AddDateCondition("DELETE FROM ns_statistics", startdate, enddate)

	if added then
		query = query .. " AND"
	else
		query = query .. " WHERE"
	end

	query = query .. " server = '" .. provider.Escape(NSTATISTICS.config.ThisServer) .. "'"
	provider.Query(query, callback)
end

function NSTATISTICS.Provider.ImportRawData(data)
	local toadd = provider.PrepareRawData(data)

	NSTATISTICS.PrintConsole("Importing raw data...")

	for type, typed in pairs(toadd) do
		NSTATISTICS.PrintConsole("Importing raw data type: " .. type)

		local forPlayers = NSTATISTICS.Statistics[type].ForPlayers

		for date, data in pairs(typed) do
			local time = os.time(NSTATISTICS.StrToDate(date))

			for k, tbl in pairs(data) do
				if not forPlayers then
					provider.AddNote(type, tbl, nil, time)
				else
					for _, v in pairs(tbl) do
						provider.AddPlayerNote(type, k, v, nil, time)
					end
				end
			end
		end
	end

	NSTATISTICS.PrintConsole("Raw data was imported")
end

function NSTATISTICS.Provider.ImportStatistics(data)
	local toadd = provider.PrepareStatistics(data)

	NSTATISTICS.PrintConsole("Importing statistics...")

	for type, typed in pairs(toadd) do
		NSTATISTICS.PrintConsole("Importing statistics type: " .. type)

		for date, data in pairs(typed) do
			local tblDate = NSTATISTICS.StrToDate(date)
			provider.WriteCalculatedData(type, data, tblDate.year, tblDate.month, tblDate.day)
		end
	end

	NSTATISTICS.PrintConsole("Statistics was imported")
end

function provider.DropTables()
	provider.Query("DROP TABLE ns_data")
	provider.Query("DROP TABLE ns_statistics")
end

function provider.RecreateTables()
	provider.DropTables()
	provider.Initialize()
end
