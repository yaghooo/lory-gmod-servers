function NSTATISTICS.RequestRawData(type, servers, startdate, enddate, from, to, reload, steamid, filter)
	net.Start("NStatistics_RequestRawData")
	net.WriteString(type)
	net.WriteTable(servers or {}, 16)
	net.WriteUInt(startdate or 0, 32)
	net.WriteUInt(enddate or 0, 32)
	net.WriteUInt(from, 32)
	net.WriteUInt(to, 32)
	net.WriteBool(reload)
	net.WriteString(steamid or "")
	net.WriteTable(filter or NSTATISTICS.CreateFilter("", "", false, false))
	net.SendToServer()
end

function NSTATISTICS.RequestData(type, servers, startdate, enddate, precision, max, formatdate)
	if formatdate == nil then
		formatdate = true
	end

	net.Start("NStatistics_RequestStatisticData")
	net.WriteString(type)
	net.WriteTable(servers or {}, 16)
	net.WriteUInt(startdate or 0, 32)
	net.WriteUInt(enddate or 0, 32)
	net.WriteUInt(precision or NSTATISTICS.Precisions.Day, 2)
	net.WriteUInt(max or 0, 16)
	net.WriteBool(formatdate)
	net.SendToServer()
end

function NSTATISTICS.SendStatisticToServer(type, data)
	local statistic = NSTATISTICS.Statistics[type]

	if statistic and not statistic.Disabled then
		net.Start("NStatistics_SendPlayerStatistic")
		net.WriteString(type)
		net.WriteTable(data)
		net.SendToServer()
	end
end

net.Receive(
	"NStatistics_SendRawData",
	function()
		if IsValid(NSTATISTICS.ContentPanel) then
			local compress = net.ReadBool()

			local data, size

			if compress then
				length = net.ReadUInt(32)
				compressed = net.ReadData(length)
				data = util.JSONToTable(util.Decompress(compressed))
				size = net.ReadUInt(32)
			else
				data = net.ReadTable()
				size = net.ReadUInt(32)
			end

			local statistic = NSTATISTICS.Statistics[NSTATISTICS.CurrentStatistic]

			if statistic and statistic.RawDataModifier then
				data, size = statistic.RawDataModifier(data, size)
			end

			NSTATISTICS.ContentPanel:SetData(data, size)
		end
	end
)

net.Receive(
	"NStatistics_SendStatisticData",
	function()
		if IsValid(NSTATISTICS.ContentPanel) then
			local compress = net.ReadBool()
			local data

			if compress then
				length = net.ReadUInt(32)
				compressed = net.ReadData(length)
				data = util.JSONToTable(util.Decompress(compressed))
			else
				data = net.ReadTable()
			end

			local statistic = NSTATISTICS.Statistics[NSTATISTICS.CurrentStatistic]

			if statistic and statistic.Modifier then
				data = statistic.Modifier(data)
			end

			NSTATISTICS.ContentPanel:SetData(data)
		end
	end
)
