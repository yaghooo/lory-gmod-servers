NSTATISTICS.AddStatistic(
	{
		Title = "Resolution",
		Name = "resolution",
		Beautifier = nil,
		RawDataModifier = nil,
		Modifier = nil,
		ForPlayers = true,
		Display = "%.2f%%",
		Legend = nil,
		ShowKey = true,
		MinChartY = 100,
		ModifyFilterRawData = nil
	}
)

NSTATISTICS.AddStatistic(
	{
		Title = "Videocard",
		Name = "videocard",
		Beautifier = nil,
		RawDataModifier = nil,
		Modifier = nil,
		ForPlayers = true,
		Display = "%.2f%%",
		Legend = nil,
		ShowKey = true,
		MinChartY = 100,
		ModifyFilterRawData = nil
	}
)

NSTATISTICS.AddStatistic(
	{
		Title = "VideocardManufacturer",
		Name = "videocard_manufacturer",
		Beautifier = nil,
		RawDataModifier = nil,
		Modifier = nil,
		ForPlayers = true,
		Display = "%.2f%%",
		Legend = nil,
		ShowKey = true,
		MinChartY = 100,
		ModifyFilterRawData = nil
	}
)

local function GetNiceRAM(data)
	if tonumber(data) < 1 then
		data = "< 1"
	end

	return data .. " GB"
end

NSTATISTICS.AddStatistic(
	{
		Title = "RAM",
		Name = "ram",
		Beautifier = function(data)
			return GetNiceRAM(data)
		end,
		RawDataModifier = nil,
		Modifier = nil,
		ForPlayers = true,
		Display = "%.2f%%",
		Legend = function(data)
			return GetNiceRAM(data)
		end,
		ShowKey = true,
		MinChartY = 100,
		ModifyFilterRawData = function(filter)
			return (filter:TextFormatToFilter("%.2f GB") or filter):GetNumbers()
		end
	}
)

NSTATISTICS.AddInitialSpawnCallback(
	function()
		local w = ScrW()
		local h = ScrH()

		-- Min resolution is 640x480, max is 4096x3072
		if w >= 640 and w <= 4096 and h >= 480 and h <= 3072 then
			NSTATISTICS.SendStatisticToServer(
				"resolution",
				{
					w = w,
					h = h
				}
			)
		end

		local files = file.Find("*.mdmp", "BASE_PATH")

		local videocard
		local ram

		for _, v in pairs(files) do
			local content = file.Read(v, "BASE_PATH")

			if not videocard then
				videocard = string.match(content, "Driver Name:%s*([^\n]*)\n")
			end

			if not ram then
				ram =
					string.match(content, "Total:%s*([%d%.]+)MB Physical") or string.match(content, "totalPhysical%s*Mb(([%d%.]+))")

				if ram ~= nil then
					ram = tonumber(string.Trim(ram))
				end
			end

			if videocard and ram then
				break
			end
		end

		if videocard then
			videocard = string.Trim(videocard)

			NSTATISTICS.SendStatisticToServer("videocard", {videocard})

			local manufacturer = string.Explode(" ", videocard)[1]

			if manufacturer then
				NSTATISTICS.SendStatisticToServer("videocard_manufacturer", {manufacturer})
			end
		end

		if ram then
			ram = ram / 1024

			-- < 1 GB
			if ram < 0.9 then
				ram = 0
			end

			NSTATISTICS.SendStatisticToServer("ram", {math.Round(ram)})
		end
	end
)
