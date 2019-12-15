local exported = 0

local function exportRawData(callback)
	NSTATISTICS.PrintConsole("Generating raw data export...")

	local curexported = exported

	local asked = {}
	local i = 0

	local info = {}

	local tocall = {}

	for type, statistic in pairs(NSTATISTICS.Statistics) do
		table.insert(
			tocall,
			{
				Type = type,
				ForPlayers = statistic.ForPlayers
			}
		)
	end

	for k, v in pairs(tocall) do
		NSTATISTICS.PrintConsole("Generating raw data export for " .. v.Type)

		NSTATISTICS.Provider.ReadRawDataWithDates(
			v.ForPlayers,
			v.Type,
			{NSTATISTICS.ThisServer},
			nil,
			nil,
			function(data)
				-- If we had finished working with this exporting
				if curexported ~= exported then
					return
				end

				for _, tbl in pairs(data) do
					tbl.Date = NSTATISTICS.DateToStr(tbl.Date.year, tbl.Date.month, tbl.Date.day, tbl.Date.hour)
				end

				table.insert(
					info,
					{
						Type = v.Type,
						Data = data
					}
				)

				tocall[k] = nil

				-- If all was readed

				if table.Count(tocall) == 0 then
					NSTATISTICS.PrintConsole("Raw data was exported")
					callback(util.TableToJSON(info))
				end
			end
		)
	end
end

local exported = 0

local function exportStatistics(callback)
	NSTATISTICS.PrintConsole("Generating statistics export...")

	local curexported = exported

	local info = {}
	local tocall = {}

	for type, statistic in pairs(NSTATISTICS.Statistics) do
		table.insert(tocall, type)
	end

	for k, v in pairs(tocall) do
		NSTATISTICS.PrintConsole("Generating statistics export for " .. v)

		NSTATISTICS.Provider.ReadCalculatedData(
			v,
			{NSTATISTICS.ThisServer},
			nil,
			nil,
			function(data)
				-- If we had finished working with this exporting
				if curexported ~= exported then
					return
				end

				-- Only from the current server
				for _, tbl in pairs(data) do
					tbl.server = nil
				end

				table.insert(
					info,
					{
						Type = v,
						Data = data
					}
				)

				tocall[k] = nil

				-- If all was readed
				if table.Count(tocall) == 0 then
					NSTATISTICS.PrintConsole("Statistics was exported")
					callback(util.TableToJSON(info))
				end
			end
		)
	end
end

local function escape(info)
	return string.Replace(info, "\n", "\\n")
end

local function pushComment(data, comment)
	return data .. "#" .. escape(tostring(comment)) .. "\n"
end

local notHeaders = {
	rawdata = true,
	statistics = true
}

local curheaders
local curinfo

local function pushInfo(data, key, value)
	key = tostring(key)
	value = tostring(value)

	if notHeaders[key] then
		curinfo = curinfo .. key .. value
	else
		curheaders = curheaders .. key .. value
	end

	return data .. escape(key) .. "=" .. escape(value) .. "\n"
end

function NSTATISTICS.GenerateExportData(creator, callback)
	curheaders = ""
	curinfo = ""

	exported = exported + 1

	local rawdata = ""
	local statistics = ""

	exportRawData(
		function(exportedData)
			rawdata = exportedData

			exportStatistics(
				function(exportedStatistics)
					statistics = exportedStatistics

					NSTATISTICS.PrintConsole("All data was exported")
					NSTATISTICS.PrintConsole("Creating headers...")

					local data = ""

					data = pushComment(data, "Raw data")
					data = pushInfo(data, "rawdata", rawdata)

					data = pushComment(data, "Statistics")
					data = pushInfo(data, "statistics", statistics)

					local headers = ""

					-- VERSION

					headers = pushComment(headers, "Version")
					headers = pushInfo(headers, "version", NSTATISTICS.Version)

					-- CREATOR

					headers = pushComment(headers, "Who created this file")

					local creatorInfo

					if not isstring(creator) and IsValid(creator) then
						creatorInfo = creator:Nick() .. " (" .. creator:SteamID() .. ")"
					elseif isstring(creator) then
						creatorInfo = creator
					else
						creatorInfo = "Unknown"
					end

					headers = pushInfo(headers, "creator", creatorInfo)

					-- SERVER INFO

					headers = pushComment(headers, "Server where this file was created")
					headers = pushInfo(headers, "svname", GetHostName())
					headers = pushInfo(headers, "svip", game.GetIPAddress())

					-- TIMESTAMP

					headers = pushComment(headers, "Timestamp")
					headers = pushInfo(headers, "timestamp", os.time())

					-- PROVIDER

					headers = pushComment(headers, "Provider info")
					headers = pushInfo(headers, "provider", NSTATISTICS.config.Provider)

					if NSTATISTICS.config.Provider == "mysql" then
						headers = pushInfo(headers, "sqlite", NSTATISTICS.config.SQLite)
					end

					-- SERVERS IN THE CONFIG

					headers = pushComment(headers, "Servers in the config")
					headers = pushInfo(headers, "servers", util.TableToJSON(NSTATISTICS.config.Servers))

					-- CHECKSUMS

					local headersSum = util.CRC(curheaders)

					headers = pushComment(headers, "Checksums")
					headers = pushInfo(headers, "crcheaders", headersSum)
					headers = pushInfo(headers, "crcdata", util.CRC(curinfo))

					NSTATISTICS.PrintConsole("Generating was finished")

					callback(headers .. data)
				end
			)
		end
	)
end

function NSTATISTICS.SaveExport(creator, name)
	local path = "nstatistics/saved/"

	file.CreateDir(path)

	if name and name ~= "" then
		path = path .. NSTATISTICS.EscapePath(name) .. "_"
	end

	path = path .. os.time() .. ".dat"

	NSTATISTICS.GenerateExportData(
		creator,
		function(data)
			NSTATISTICS.PrintConsole("Exported data was saved here: " .. path)
			file.Write(path, data)
		end
	)
end

concommand.Add(
	"nstatistics_export",
	function(ply, cmd, args)
		if table.HasValue(NSTATISTICS.config.CanUseExport, ply:GetUserGroup()) then
			NSTATISTICS.SaveExport(ply, args[1])
		else
			NSTATISTICS.PrintConsole("You don't have access to this command")
		end
	end
)
