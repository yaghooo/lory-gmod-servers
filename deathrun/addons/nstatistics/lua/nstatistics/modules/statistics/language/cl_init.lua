local languages = {
	["bg"] = "Bulgarian",
	["cs"] = "Czech",
	["da"] = "Danish",
	["de"] = "German",
	["el"] = "Greek",
	["en-PT"] = "English",
	["en"] = "English",
	["es-ES"] = "Spanish",
	["et"] = "Estonian",
	["fi"] = "Finnish",
	["fr"] = "French",
	["he"] = "Hebrew",
	["hr"] = "Croatian",
	["hu"] = "Hungarian",
	["it"] = "Italian",
	["ja"] = "Japanese",
	["ko"] = "Korean",
	["lt"] = "Lithuanian",
	["nl"] = "Dutch",
	["no"] = "Norwegian",
	["pl"] = "Polish",
	["pt-BR"] = "Portuguese",
	["pt-PT"] = "Portuguese",
	["ru"] = "Russian",
	["sk"] = "Slovak",
	["sv-SE"] = "Swedish",
	["th"] = "Thai",
	["tr"] = "Turkish",
	["uk"] = "Ukrainian",
	["vi"] = "Vietnamese",
	["zh-CN"] = "Chinese",
	["zh-TW"] = "Chinese"
}

NSTATISTICS.AddStatistic(
	{
		Title = "Language",
		Name = "language",
		Beautifier = function(data)
			return NSTATISTICS.GetPhrase(languages[data] or "Unknown")
		end,
		RawDataModifier = nil,
		Modifier = nil,
		ForPlayers = true,
		Display = "%.2f%%",
		Legend = function(data)
			return NSTATISTICS.GetPhrase(languages[data] or "Unknown")
		end,
		ShowKey = true,
		MinChartY = 100,
		ModifyFilterRawData = function(filter)
			return filter:FindLikePhrases(languages) or filter
		end
	}
)

NSTATISTICS.AddInitialSpawnCallback(
	function()
		NSTATISTICS.SendStatisticToServer("language", {GetConVar("gmod_language"):GetString()})
	end
)
