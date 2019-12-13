util.AddNetworkString("NStatistics_RequestRawData")
util.AddNetworkString("NStatistics_SendRawData")

util.AddNetworkString("NStatistics_RequestStatisticData")
util.AddNetworkString("NStatistics_SendStatisticData")

util.AddNetworkString("NStatistics_SendPlayerStatistic")

net.Receive(
	"NStatistics_RequestRawData",
	function(len, ply)
		if NSTATISTICS.IsPlayerHaveMenuAccess(ply) then
			local type = net.ReadString()
			local servers = net.ReadTable()
			local startdate = net.ReadUInt(32)
			local enddate = net.ReadUInt(32)
			local from = net.ReadUInt(32)
			local to = net.ReadUInt(32)
			local reload = net.ReadBool()
			local target = net.ReadString()
			local filter = NSTATISTICS.SetFilterMeta(net.ReadTable())

			local statistic = NSTATISTICS.Statistics[type] or {}
			if statistic.ModifyFilterRawData then
				filter = statistic.ModifyFilterRawData(filter)
			end

			if #servers == 0 then
				servers = {NSTATISTICS.config.ThisServer}
			end

			if target == "" then
				target = nil
			end

			if startdate == 0 then
				startdate = nil
			else
				startdate = NSTATISTICS.GetDateWithHours(startdate)
			end

			if enddate == 0 then
				enddate = nil
			else
				enddate = NSTATISTICS.GetDateWithHours(enddate)
			end

			local data, size

			NSTATISTICS.Provider.ReadInfoInterval(
				statistic.ForPlayers,
				type,
				servers,
				from,
				to,
				startdate,
				enddate,
				ply,
				reload,
				target,
				filter,
				function(data, size)
					local function send(tosend)
						local compress = NSTATISTICS.config.SendCompressed and statistic.Compress

						net.Start("NStatistics_SendRawData")
						net.WriteBool(compress)

						if compress then
							local compressed = util.Compress(util.TableToJSON(data))

							net.WriteUInt(#compressed, 32)
							net.WriteData(compressed, #compressed)
							net.WriteUInt(size, 32)
						else
							net.WriteTable(data)
							net.WriteUInt(size, 32)
						end
						net.Send(ply)
					end

					if statistic.RawDataSending then
						statistic.RawDataSending(send, data)
					else
						send(data)
					end
				end
			)
		end
	end
)

local function DecreasePrecision(data, concatenate)
	local temp = {}

	for k, tbl in pairs(data) do
		if not temp[tbl.server] then
			temp[tbl.server] = {}
		end

		local date = string.gsub(tbl.date, "_%d+$", "")

		if not temp[tbl.server][date] then
			temp[tbl.server][date] = {}
		end

		table.insert(temp[tbl.server][date], tbl.data)
	end

	local newdata = {}

	for srv, tbl in pairs(temp) do
		for k, v in pairs(tbl) do
			table.insert(
				newdata,
				{
					data = concatenate(v),
					date = k,
					server = srv
				}
			)
		end
	end

	return newdata
end

net.Receive(
	"NStatistics_RequestStatisticData",
	function(len, ply)
		if NSTATISTICS.IsPlayerHaveMenuAccess(ply) then
			local type = net.ReadString()
			local servers = net.ReadTable()
			local startdate = net.ReadUInt(32)
			local enddate = net.ReadUInt(32)
			local precision = net.ReadUInt(2)
			local max = net.ReadUInt(16)
			local formatdate = net.ReadBool()

			if #servers == 0 then
				servers = {NSTATISTICS.config.ThisServer}
			end

			if startdate == 0 then
				startdate = nil
			else
				startdate = NSTATISTICS.GetDateWithHours(startdate)
			end

			if enddate == 0 then
				enddate = nil
			else
				enddate = NSTATISTICS.GetDateWithHours(enddate)
			end

			local statistic = NSTATISTICS.Statistics[type] or {}

			NSTATISTICS.Provider.ReadCalculatedData(
				type,
				servers,
				startdate,
				enddate,
				function(data)
					local i = 1

					while (i <= precision or #data > max and max ~= 0) and i < 3 do
						data = DecreasePrecision(data, statistic.Concatenate)
						i = i + 1
					end

					table.SortByMember(data, "date", true)

					if formatdate then
						for k, v in pairs(data) do
							v.date = NSTATISTICS.GetDateFormat(NSTATISTICS.StrToDate(v.date))
						end
					end

					local function send(tosend)
						local compress = NSTATISTICS.config.SendCompressed and statistic.Compress

						net.Start("NStatistics_SendStatisticData")
						net.WriteBool(compress)

						if compress then
							local compressed = util.Compress(util.TableToJSON(tosend))

							net.WriteUInt(#compressed, 32)
							net.WriteData(compressed, #compressed)
						else
							net.WriteTable(tosend)
						end
						net.Send(ply)
					end

					if statistic.Sending then
						statistic.Sending(send, data)
					else
						send(data)
					end
				end
			)
		end
	end
)

local function PrintNstatisticsMessage(ply, str)
	if NSTATISTICS.config.PrintWarningMessages then
		NSTATISTICS.PrintConsole(ply:Nick() .. " (" .. ply:SteamID() .. ") " .. str)
	end
end

local function suspicious(ply, punish)
	ply.nstatistic_suspicion = (ply.nstatistic_suspicion or 0) + 1

	if ply.nstatistic_suspicion < NSTATISTICS.config.PotentialSpammerNum and not punish then
		return
	end

	local action = NSTATISTICS.config.PotentialSpammerAction

	if action == "kick" then
		ply:Kick(NSTATISTICS.config.PotentialSpammerReason)
	elseif string.StartWith(action, "ban") then
		local length = string.Replace(action, "ban", "")
		length = string.Replace(action, ":", "")
		length = string.Replace(action, " ", "")

		if length and length ~= "" then
			length = tonumber(length)
			ply:Ban(length, false)
			ply:Kick(NSTATISTICS.config.PotentialSpammerReason)
		end
	else
		PrintNstatisticsMessage(ply, "have " .. ply.nstatistic_suspicion .. " suspicious actions")
	end
end

net.Receive(
	"NStatistics_SendPlayerStatistic",
	function(len, ply)
		local type = net.ReadString()
		local data = net.ReadTable()

		local statistic = NSTATISTICS.Statistics[type]

		if not statistic then
			PrintNstatisticsMessage(ply, "is trying to send unknown statistic type: " .. type)

			return
		end

		if statistic.Disabled then
			return
		end

		if statistic.Serverside then
			PrintNstatisticsMessage(ply, "is trying to send statistic '" .. type .. "', but it's marked as serverside")
			suspicious(ply)

			return
		end

		if statistic.Once then
			if not ply.nstatistic_sended then
				ply.nstatistic_sended = {}
			end

			if ply.nstatistic_sended[type] then
				PrintNstatisticsMessage(ply, "is trying to send '" .. type .. "' several times, but it's marked as once")
				suspicious(ply)
				return
			else
				ply.nstatistic_sended[type] = true
			end
		end

		if statistic.Delay then
			if not ply.nstatistic_waiting then
				ply.nstatistic_waiting = {}
			end

			if ply.nstatistic_waiting[type] and ply.nstatistic_waiting[type] > CurTime() then
				PrintNstatisticsMessage(
					ply,
					"is trying to send '" ..
						type ..
							"' with delay in '" ..
								(ply.nstatistic_waiting[type] - CurTime()) .. "' s, but he should wait " .. statistic.Delay .. " s"
				)
				suspicious(ply)
				return
			else
				ply.nstatistic_waiting[type] = CurTime() + statistic.Delay
			end
		end

		if statistic.Suspicious then
			local issuspicious, ignore = statistic.Suspicious(data)

			if ignore then
				return
			elseif issuspicious then
				PrintNstatisticsMessage(ply, "sended data that was recognized as weird by statistic '" .. type .. "'")
				suspicious(ply)
				return
			end
		end

		local add = function()
			if statistic.Beautifier then
				data = statistic.Beautifier(data)
			end

			if statistic.CustomSave then
				statistic.CustomSave(ply, data)
			else
				NSTATISTICS.Provider.AddPlayerNote(type, ply, data)
			end
		end

		if statistic.AddIfNotExists then
			NSTATISTICS.Provider.CallIfPlayerDataNotExists(
				type,
				ply,
				NSTATISTICS.GetCurDate(),
				function(exists)
					add()
				end
			)
		else
			add()
		end
	end
)
