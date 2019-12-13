local template = {
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

local statistics = {
	["country"] = "Country",
	["region"] = "Region",
	["city"] = "City",
	["timezone"] = "Timezone"
}

for k, v in pairs(statistics) do
	local copy = table.Copy(template)
	copy.Name = k
	copy.Title = v

	NSTATISTICS.AddStatistic(copy)
end
