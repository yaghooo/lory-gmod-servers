local function beautify(utc)
	utc = string.Trim(utc)

	local hours = string.match(utc, "^[%+%-]%d%d")
	local minutes

	if hours then
		minutes = string.match(utc, "%d%d$", #hours + 1)
	end

	hours = tonumber(hours)
	minutes = tonumber(minutes)

	if hours and minutes then
		local str = hours > 0 and "+" or ""
		str = str .. NSTATISTICS.CompleteNumber(hours, 2)

		if minutes ~= 0 then
			str = str .. ":" .. NSTATISTICS.CompleteNumber(minutes, 2)
		end

		return "UTC" .. str
	end

	return nil
end

NSTATISTICS.AddStatistic(
	{
		Title = "Timezone",
		Name = "timezone",
		Beautifier = function(data)
			local beautified = beautify(data) or ""

			return #beautified > 0 and beautified or "Corrupted data"
		end,
		RawDataModifier = nil,
		Modifier = function(data)
			for _, tbl in pairs(data) do
				local copy = table.Copy(tbl.data)
				tbl.data = {}

				for k, v in pairs(copy) do
					local beautified = beautify(k)

					if beautified and #beautified > 0 then
						tbl.data[beautified] = v
					end
				end
			end

			return data
		end,
		ForPlayers = true,
		Display = "%.2f%%",
		Legend = nil,
		ShowKey = true,
		MinChartY = 100,
		ModifyFilterRawData = function(filter)
			filter.Filter = string.gsub(filter.Filter, "[^0-9%+%-]", "")
			return filter
		end
	}
)

NSTATISTICS.AddInitialSpawnCallback(
	function()
		local utc = os.date("%z")

		if utc and #utc > 0 then
			NSTATISTICS.SendStatisticToServer("timezone", {utc})
		end
	end
)
