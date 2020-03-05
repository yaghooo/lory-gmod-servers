table.Merge(
	NSTATISTICS.config,
	{
		-- Time when raw data should be removed. You can use: d - days, m - month, y - year.
		-- For example 7d = 7 days. Set to "0" if you want to remove raw data immediately
		RemoveRawData = "7d",
		-- Time when statistics should be removed. You can use: d - days, m - month, y - year.
		-- Leave empty if you don't want to remove statistics
		RemoveStatistics = "",
		-- Number of suspicious actions before getting punishment
		PotentialSpammerNum = 2,
		-- What is the punishment for the potential spammer. Can be "none", "kick", "ban: time in minutes"
		PotentialSpammerAction = "none",
		-- Reason for kick/ban
		PotentialSpammerReason = "nStatistics: Potential spammer",
		-- Should data be sent to the client compressed using util.Compress and net.WriteData
		SendCompressed = true,
		-- Print warning messages in the console
		PrintWarningMessages = true,
		-- Links to your steam groups
		SteamGroups = {
			"https://steamcommunity.com/groups/lorybr"
		},
		-- MySQL settings

		-- Should use SQLite library. Set to false to use mysqloo
		SQLite = true,
		-- Dedicated MySQL server
		Host = "127.0.0.1",
		Username = "root",
		Password = "",
		Database = "nstatistics",
		Port = 3306,
		-- Groups that can use nstatistics_dbconnect concommand
		CanConnectDBManually = {
			"superadmin"
		},
		-- Groups that can use nstatistics_import concommand
		CanUseImport = {
			"superadmin"
		},
		-- Groups that can use nstatistics_export concommand
		CanUseExport = {
			"superadmin"
		},
		-- JSON settings

		-- Time between cache saving in seconds. 0 to save data immediately after changing, can cause lags
		CacheSavingTime = 30,
		-- Time between removing raw data cache in seconds
		RawDataCacheRemoving = 120
	}
)

timer.Simple(
	0,
	function()
		hook.Run("NStatistics_ConfigLoaded", NSTATISTICS.Loaded)
		NSTATISTICS.Loaded = true
	end
)
