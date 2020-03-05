local function exportToTable(data)
	local lines = string.Explode("\n", data)
	local tbl = {}

	for _, v in pairs(lines) do
		local line = string.Trim(v)

		if line ~= "" then
			local key, value = string.match(line, "([^=]+)%s*=%s*(.+)")

			key = string.Trim(key)
			value = string.Trim(value)

			if key and value and key ~= "" then
				table.insert(
					tbl,
					{
						key = key,
						value = value
					}
				)
			end
		end
	end

	return tbl
end

local function toKeyValue(data)
	local new = {}

	for _, tbl in pairs(data) do
		new[tbl.key] = tbl.value
	end

	return new
end

local notHeaders = {
	rawdata = true,
	statistics = true
}

local ignore = {
	crcheaders = true,
	crcdata = true
}

local function getHeadersChecksum(data)
	local tocheck = ""

	for _, tbl in pairs(data) do
		if not notHeaders[tbl.key] and not ignore[tbl.key] then
			tocheck = tocheck .. tbl.key .. tbl.value
		end
	end

	return util.CRC(tocheck)
end

local function getInfoChecksum(data)
	local tocheck = ""

	for _, tbl in pairs(data) do
		if notHeaders[tbl.key] and not ignore[tbl.key] then
			tocheck = tocheck .. tbl.key .. tbl.value
		end
	end

	return util.CRC(tocheck)
end

function NSTATISTICS.ImportData(name)
	name = NSTATISTICS.EscapePath(name)

	if not string.EndsWith(name, ".dat") then
		name = name .. ".dat"
	end

	local path = "nstatistics/saved/" .. name

	if not file.Exists(path, "DATA") then
		NSTATISTICS.PrintConsole("File '" .. path .. "' doesn't exists")
		return
	end

	local stripped = NSTATISTICS.StripExportComments(file.Read(path))
	local data = exportToTable(stripped)
	local kvData = toKeyValue(data)

	NSTATISTICS.PrintConsole("Data was read")

	if kvData["crcheaders"] then
		if kvData["crcheaders"] ~= getHeadersChecksum(data) then
			NSTATISTICS.PrintConsole("Headers was changed by someone")
		end
	else
		NSTATISTICS.PrintConsole("Missing headers checksum")
	end

	if kvData["crcdata"] then
		if kvData["crcdata"] ~= getInfoChecksum(data) then
			NSTATISTICS.PrintConsole("Data was changed by someone")
		end
	else
		NSTATISTICS.PrintConsole("Missing data checksum")
	end

	NSTATISTICS.PrintConsole("Importing raw data...")

	if kvData["rawdata"] then
		local data = util.JSONToTable(kvData["rawdata"])

		if data then
			NSTATISTICS.Provider.RemoveRawData()
			NSTATISTICS.Provider.ImportRawData(data)
		else
			NSTATISTICS.PrintConsole("Corrupted JSON in rawdata, importing failed")
		end
	else
		NSTATISTICS.PrintConsole("Missing raw data")
	end

	if kvData["statistics"] then
		local data = util.JSONToTable(kvData["statistics"])

		if data then
			NSTATISTICS.Provider.RemoveStatistics()
			NSTATISTICS.Provider.ImportStatistics(data)
		else
			NSTATISTICS.PrintConsole("Corrupted JSON in statistics, importing failed")
		end
	else
		NSTATISTICS.PrintConsole("Missing statistics")
	end

	if kvData["version"] then
		if string.find(kvData["version"], "%d+%.%d+%.%d+") then
			NSTATISTICS.PrintConsole("Export version: " .. kvData["version"] .. ", switching")
			NSTATISTICS.SetLastVersion(NSTATISTICS.CreateVersionObj(kvData["version"]))
		else
			NSTATISTICS.PrintConsole("Malformed export version: " .. kvData["version"])
		end
	else
		NSTATISTICS.PrintConsole("Unknown export version")
	end

	NSTATISTICS.PrintConsole("Importing successfully finished, please restart server or change the map")
	NSTATISTICS.FreezeProvider()
end

concommand.Add(
	"nstatistics_import",
	function(ply, cmd, args)
		if table.HasValue(NSTATISTICS.config.CanUseImport, ply:GetUserGroup()) then
			local name = args[1]

			if name then
				NSTATISTICS.ImportData(name)
			else
				NSTATISTICS.PrintConsole("Filename doesn't specified")
			end
		else
			chat.AddText(Color(255, 0, 0), "You don't have access to this command")
		end
	end
)

concommand.Add(
	"nstatistics_importlist",
	function(ply)
		if table.HasValue(NSTATISTICS.config.CanUseImport, ply:GetUserGroup()) then
			local files = file.Find("nstatistics/saved/*.dat", "DATA")

			if #files > 0 then
				NSTATISTICS.PrintConsoleWithoutPrefix("List of files to import:")

				for _, v in pairs(files) do
					NSTATISTICS.PrintConsoleWithoutPrefix(string.StripExtension(v))
				end
			else
				NSTATISTICS.PrintConsoleWithoutPrefix("No files to import")
			end
		else
			chat.AddText(Color(255, 0, 0), "You don't have access to this command")
		end
	end
)
