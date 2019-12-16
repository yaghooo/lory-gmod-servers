NSTATISTICS.config = {
	-- Provider type. Can be mysql or json
	Provider = "mysql",
	-- Groups that have access to the menu
	MenuAccess = {
		"superadmin"
	},
	-- Disabled statistics. You can see statistics list by nstatistics_list concommand
	DisabledStatistics = {},
	-- IDs and names of your servers.
	-- This table should be the same on all your servers. IDs should be unique and belongs to the interval [0, 65535]
	Servers = {
		[1] = "Lory Deathrun"
	},
	-- Server ID from the table above
	ThisServer = 1,
	-- Console command to open menu
	ConCommand = "nstatistics",
	-- Chat command to open menu
	ChatCommand = "!nstatistics",
	-- Default language. You can set any of this: en, fr, ge, ru
	DefaultLanguage = "en",
	-- Date format with day, month, year, hours. y - year, m - month, d - day, h - hour
	DateFormatYMDH = "d/m/y h:00",
	-- Date format with day, month, year. y - year, m - month, d - day
	DateFormatYMD = "d/m/y",
	-- Date format with month, year. y - year, m - month
	DateFormatYM = "m/y",
	-- Date format with year. y - year
	DateFormatY = "y",
	-- Show nicknames on the data page. It will take 1 second to request nicknames
	RawDataNicks = true,
	-- Autoload data after switching to another tab
	Autoload = true,
	-- Intervals of the total time. Each number pair is an interval. Should be sorted ascending
	TotalTimeIntervals = {
		5,
		20,
		50,
		100,
		200,
		300
	},
	-- How much different statistics branches can be shown in the barchart and linechart
	MaxStatisticsBranches = 15,
	-- Colors of the histograms
	HistogramColors = {
		Color(141, 23, 23),
		Color(180, 15, 45),
		Color(210, 31, 39),
		Color(179, 42, 84),
		Color(220, 90, 160),
		Color(140, 81, 47),
		Color(219, 70, 12),
		Color(241, 115, 93),
		Color(245, 167, 0),
		Color(243, 165, 117),
		Color(254, 203, 0),
		Color(51, 153, 103),
		Color(101, 178, 50),
		Color(187, 206, 29),
		Color(97, 142, 227),
		Color(35, 165, 217),
		Color(158, 49, 142),
		Color(100, 50, 147)
	},
	-- Colors of the line charts
	LineChartsColors = {
		Color(141, 23, 23),
		Color(180, 15, 45),
		Color(210, 31, 39),
		Color(179, 42, 84),
		Color(220, 90, 160),
		Color(140, 81, 47),
		Color(219, 70, 12),
		Color(241, 115, 93),
		Color(245, 167, 0),
		Color(243, 165, 117),
		Color(254, 203, 0),
		Color(51, 153, 103),
		Color(101, 178, 50),
		Color(187, 206, 29),
		Color(97, 142, 227),
		Color(35, 165, 217),
		Color(158, 49, 142),
		Color(100, 50, 147)
	}
}

if CLIENT then
	timer.Simple(
		0,
		function()
			hook.Run("NStatistics_ConfigLoaded", NSTATISTICS.Loaded)
			NSTATISTICS.Loaded = true
		end
	)
end
