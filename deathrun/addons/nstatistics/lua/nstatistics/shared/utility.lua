function NSTATISTICS.IsPlayerHaveMenuAccess(ply)
	return table.HasValue(NSTATISTICS.config.MenuAccess, ply:GetUserGroup())
end

function NSTATISTICS.IsDataAreServerDepending()
	return NSTATISTICS.config.Provider == "mysql"
end

function NSTATISTICS.CompleteNumber(number, decimals)
	local neg = number < 0

	if neg then
		number = math.abs(number)
	end

	local str = tostring(number)

	local complete = string.rep("0", math.max(decimals - #str, 0)) .. str

	if neg then
		complete = "-" .. complete
	end

	return complete
end

-- Table shouldn't have loops
function NSTATISTICS.RoundTable(tbl, decimals)
	for k, v in pairs(tbl) do
		if isnumber(v) then
			tbl[k] = math.Round(v, decimals)
		end

		if istable(v) then
			NSTATISTICS.RoundTable(v, decimals)
		end
	end
end

function NSTATISTICS.ToSteamID(ply)
	local id

	if isentity(ply) then
		if IsValid(ply) and ply.SteamID then
			id = ply:SteamID()
		end
	elseif isstring(ply) then
		id = ply
	end

	return id or "incorrect"
end

function NSTATISTICS.ParseText(text, unformatted)
	local phrase = string.PatternSafe(unformatted)
	local pattern = string.gsub(phrase, "%%%%%%?%.?%d?%w", "(.+)")

	return string.match(string.lower(text), string.lower(pattern))
end

function NSTATISTICS.ParsePhrase(text, key)
	return NSTATISTICS.ParseText(text, NSTATISTICS.GetUnformattedPhrase(key))
end

function NSTATISTICS.EscapePath(path)
	local str = string.gsub(path, "[^%w_]", "")

	if str and str ~= "" then
		return str
	else
		return "invalid_name"
	end
end

function NSTATISTICS.StripExportComments(data)
	local lines = string.Explode("\n", data)
	local newdata = ""

	for _, v in pairs(lines) do
		local trimmed = string.Trim(v)
		if not string.StartWith(trimmed, "#") and trimmed ~= "" then
			newdata = newdata .. v .. "\n"
		end
	end

	return newdata
end

-- For easily searching debug prints that I can forget to remove
function NSTATISTICS.PrintConsoleWithoutPrefix(...)
	print(...)
end

function NSTATISTICS.PrintConsole(...)
	NSTATISTICS.PrintConsoleWithoutPrefix("nStatistics: ", ...)
end

function NSTATISTICS.Error(msg, lvl)
	error("nStatistics error: " .. msg, (lvl or 1) + 1)
end
