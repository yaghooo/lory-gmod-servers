surface.CreateFont(
	"NStatistics_ListNotification",
	{
		font = "Arial",
		size = 15,
		weight = 1000
	}
)

surface.CreateFont(
	"NStatistics_ListInfo",
	{
		font = "Arial",
		size = 15,
		weight = 800
	}
)

surface.CreateFont(
	"NStatistics_LoadListButton",
	{
		font = "Tahoma",
		size = 13,
		weight = 1000
	}
)

surface.CreateFont(
	"NStatistics_DateLabel",
	{
		font = "Tahoma",
		size = 13,
		weight = 800
	}
)

local PANEL = {}

function PANEL:Init()
	self.IsRaw = false

	local w = self:GetParent():GetWide()
	self:SetWide(w)

	local x = 10

	self.YearLabel = self:Add("DLabel")
	self.YearLabel:SetText(NSTATISTICS.GetPhrase("Year"))
	self.YearLabel:SetFont("NStatistics_DateLabel")
	self.YearLabel:SetTextColor(Color(140, 140, 140))
	self.YearLabel:SizeToContents()
	self.YearLabel:SetPos(x, 20 - self.YearLabel:GetTall() / 2)

	x = x + self.YearLabel:GetWide() + 10

	self.Year = self:Add("DComboBox")
	self.Year:SetSortItems(false)
	self.Year:SetSize(90, 20)
	self.Year:SetPos(x, 10)

	self.Year.OnSelect = function(_, index, value)
		if self.data then
			self.Month:Clear()
			self.Month:AddChoice(NSTATISTICS.GetPhrase("Any"), true, true)

			self.Day:Clear()
			self.Day:AddChoice(NSTATISTICS.GetPhrase("Any"), true, true)

			if self.data[value] then
				for k, v in pairs(self.data[value]) do
					self.Month:AddChoice(k)
				end
			end
		end
	end

	self.Year:AddChoice(NSTATISTICS.GetPhrase("Any"), true, true)

	x = x + self.Year:GetWide() + 20

	self.MonthLabel = self:Add("DLabel")
	self.MonthLabel:SetText(NSTATISTICS.GetPhrase("Month"))
	self.MonthLabel:SetFont("NStatistics_DateLabel")
	self.MonthLabel:SetTextColor(Color(140, 140, 140))
	self.MonthLabel:SizeToContents()
	self.MonthLabel:SetPos(x, 20 - self.MonthLabel:GetTall() / 2)

	x = x + self.MonthLabel:GetWide() + 10

	self.Month = self:Add("DComboBox")
	self.Month:SetSortItems(false)
	self.Month:SetSize(90, 20)
	self.Month:SetPos(x, 10)

	self.Month.OnSelect = function(_, index, value)
		if self.data then
			self.Day:Clear()
			self.Day:AddChoice(NSTATISTICS.GetPhrase("Any"), true, true)

			local selected = self.Year:GetSelected()

			if self.data[selected] and self.data[selected][value] then
				for k, v in pairs(self.data[selected][value]) do
					self.Day:AddChoice(k)
				end
			end
		end
	end

	self.Month:AddChoice(NSTATISTICS.GetPhrase("Any"), true, true)

	x = x + self.Month:GetWide() + 20

	self.DayLabel = self:Add("DLabel")
	self.DayLabel:SetText(NSTATISTICS.GetPhrase("Day"))
	self.DayLabel:SetFont("NStatistics_DateLabel")
	self.DayLabel:SetTextColor(Color(140, 140, 140))
	self.DayLabel:SizeToContents()
	self.DayLabel:SetPos(x, 20 - self.DayLabel:GetTall() / 2)

	x = x + self.DayLabel:GetWide() + 10

	self.Day = self:Add("DComboBox")
	self.Day:SetSortItems(false)
	self.Day:SetSize(90, 20)
	self.Day:SetPos(x, 10)

	self.Day:AddChoice(NSTATISTICS.GetPhrase("Any"), true, true)

	x = x + self.Day:GetWide() + 30

	if NSTATISTICS.IsDataAreServerDepending() then
		self.ServerLabel = self:Add("DLabel")
		self.ServerLabel:SetText(NSTATISTICS.GetPhrase("Server"))
		self.ServerLabel:SetFont("NStatistics_DateLabel")
		self.ServerLabel:SetTextColor(Color(140, 140, 140))
		self.ServerLabel:SizeToContents()
		self.ServerLabel:SetPos(x, 20 - self.ServerLabel:GetTall() / 2)

		x = x + self.ServerLabel:GetWide() + 10

		self.Server = self:Add("DComboBox")
		self.Server:SetSortItems(false)
		self.Server:SetSize(120, 20)
		self.Server:SetPos(x, 10)

		self.Server:AddChoice(NSTATISTICS.GetPhrase("Any"), true, true)

		x = x + self.Server:GetWide() + 30
	end

	self.Show = self:Add("DButton")
	self.Show:SetPos(x, 10)
	self.Show:SetSize(50, 20)
	self.Show:SetFont("NStatistics_LoadListButton")
	self.Show:SetTextColor(Color(255, 255, 255))
	self.Show:SetText(NSTATISTICS.GetPhrase("Show"))

	self.Show.Paint = function(panel, w, h)
		if panel:IsHovered() then
			surface.SetDrawColor(76, 141, 255)
		else
			surface.SetDrawColor(53, 118, 247)
		end
		surface.DrawRect(0, 0, w, h)
	end

	self.Show.DoClick = function()
		if table.Count(self.data) == 0 then
			return
		end

		self.DataList:Clear()

		local year, allyears = self.Year:GetSelected()
		local month, allmonths = self.Month:GetSelected()
		local day, alldays = self.Day:GetSelected()
		local server

		if IsValid(self.Server) then
			_, server = self.Server:GetSelected()
		end

		local years = {}
		local months = {}
		local days = {}

		-- Long and boring data processing...

		for srv, data in pairs(self.data) do
			if server == true or server == nil or server == srv then
				if allyears then
					for k, v in pairs(data) do
						table.insert(
							years,
							{
								info = {
									year = k,
									server = srv
								},
								tbl = v
							}
						)
					end
				elseif data[year] then
					table.insert(
						years,
						{
							info = {
								year = year,
								server = srv
							},
							tbl = data[year]
						}
					)
				end
			end
		end

		if self.precision ~= NSTATISTICS.Precisions.Year then
			for _, tbl in pairs(years) do
				if allmonths then
					for k, v in pairs(tbl.tbl) do
						table.insert(
							months,
							{
								info = {
									year = tbl.info.year,
									month = k,
									server = tbl.info.server
								},
								tbl = v
							}
						)
					end
				elseif tbl.tbl[month] then
					table.insert(
						months,
						{
							info = {
								year = tbl.info.year,
								month = month,
								server = tbl.info.server
							},
							tbl = tbl.tbl[month]
						}
					)
				end
			end
		else
			months = years
		end

		if self.precision == NSTATISTICS.Precisions.Day then
			for _, tbl in pairs(months) do
				if alldays then
					for k, v in pairs(tbl.tbl) do
						table.insert(
							days,
							{
								info = {
									year = tbl.info.year,
									month = tbl.info.month,
									day = k,
									server = tbl.info.server
								},
								tbl = v
							}
						)
					end
				elseif tbl.tbl[day] then
					table.insert(
						days,
						{
							info = {
								year = tbl.info.year,
								month = tbl.info.month,
								day = day
							},
							tbl = tbl.tbl[day]
						}
					)
				end
			end
		else
			days = months
		end

		local maxw = 0

		for _, day in pairs(days) do
			local server = NSTATISTICS.config.Servers[tonumber(day.info.server)]

			surface.SetFont("NStatistics_ListInfo")
			local w = surface.GetTextSize(server)

			maxw = math.max(maxw, w)
		end

		local final = {}

		for _, day in pairs(days) do
			for _, tbl in pairs(day.tbl) do
				for k, v in pairs(tbl) do
					local toinsert = {}
					toinsert.server = NSTATISTICS.config.Servers[tonumber(day.info.server)]
					toinsert.text = ""
					toinsert.data = NSTATISTICS.GetStatisticsDisplayText(self.statistic.Display, v)

					if self.statistic.ShowKey then
						if self.statistic.Legend then
							toinsert.text = self.statistic.Legend(k)
						else
							toinsert.text = k
						end
					end

					local date = NSTATISTICS.DateToStr(day.info.year, day.info.month, day.info.day)

					if final[date] then
						table.insert(final[date], toinsert)
					else
						final[date] = {toinsert}
					end
				end
			end
		end

		local h = 40
		local i = 0

		for date, data in SortedPairs(final, true) do
			local pnl = self.DataList:Add("DPanel")
			pnl:SetTall(35)

			local niceDate = NSTATISTICS.GetDateFormat(NSTATISTICS.StrToDate(date))

			pnl.Paint = function(_, w, h)
				draw.SimpleText(
					niceDate,
					"NStatistics_ListInfo",
					w / 2,
					(h - 5) / 2,
					Color(100, 100, 100),
					TEXT_ALIGN_CENTER,
					TEXT_ALIGN_CENTER
				)
			end

			h = h + pnl:GetTall()

			for _, day in pairs(data) do
				local pnl = self.DataList:Add("DPanel")
				pnl:SetTall(30)

				local copy = i
				pnl.Paint = function(_, w, h)
					if copy % 2 == 0 then
						surface.SetDrawColor(220, 220, 220)
					else
						surface.SetDrawColor(230, 230, 230)
					end
					surface.DrawRect(0, 0, w, h)

					draw.SimpleText(
						day.server,
						"NStatistics_ListInfo",
						10,
						h / 2,
						Color(120, 120, 120),
						TEXT_ALIGN_LEFT,
						TEXT_ALIGN_CENTER
					)
					draw.SimpleText(
						day.text,
						"NStatistics_ListInfo",
						maxw + 80,
						h / 2,
						Color(120, 120, 120),
						TEXT_ALIGN_LEFT,
						TEXT_ALIGN_CENTER
					)
					draw.SimpleText(
						day.data,
						"NStatistics_ListInfo",
						w - 20,
						h / 2,
						Color(120, 120, 120),
						TEXT_ALIGN_RIGHT,
						TEXT_ALIGN_CENTER
					)
				end

				h = h + pnl:GetTall()
				i = i + 1
			end
		end

		self:SetTall(h)
	end

	self.DataList = self:Add("DListLayout")
	self.DataList:SetPos(10, 40)
	self.DataList:SetWide(w - 40)
end

function PANEL:Paint(w, h)
end

function PANEL:SetData(sended)
	self.data = {}

	if table.Count(sended) == 0 then
		local NoDataPanel = self.DataList:Add("DPanel")
		NoDataPanel:SetWide(self.DataList:GetWide())
		NoDataPanel.Paint = function(_, w, h)
		end

		local nodata = NoDataPanel:Add("DLabel")
		nodata:SetText(NSTATISTICS.GetPhrase("NoData"))
		nodata:SetFont("NStatistics_DataNotification")
		nodata:SetTextColor(Color(130, 130, 130))
		nodata:SizeToContents()
		nodata:CenterHorizontal()

		local h = nodata:GetTall() + 40

		NoDataPanel:SetTall(h)
		self:SetTall(h)

		return
	end

	for _, data in pairs(sended) do
		local date = NSTATISTICS.StrToDate(data.date)

		local year = date.year or 0
		local month = date.month or 0
		local day = date.day or 0
		local server = tonumber(data.server) or NSTATISTICS.config.ThisServer

		if not self.data[server] then
			self.data[server] = {}
		end

		local tbl = self.data[server]

		if not tbl[year] then
			tbl[year] = {}
		end

		tbl = tbl[year]

		if self.precision ~= NSTATISTICS.Precisions.Year then
			if not tbl[month] then
				tbl[month] = {}
			end

			tbl = tbl[month]

			if self.precision ~= NSTATISTICS.Precisions.Month then
				if not tbl[day] then
					tbl[day] = {}
				end

				tbl = tbl[day]
			end
		end

		table.insert(tbl, data.data)
	end

	for k, v in pairs(self.data) do
		self.Year:AddChoice(k)
	end
end

function PANEL:SetInfo(startdate, finaldate, statistic, precision, servers)
	self.startdate = startdate
	self.finaldate = finaldate
	self.statistic = statistic
	self.precision = precision
	self.servers = servers

	if servers and IsValid(self.Server) then
		for _, id in pairs(servers) do
			self.Server:AddChoice(NSTATISTICS.config.Servers[id], id)
		end
	end

	self:SetTall(40)

	NSTATISTICS.RequestData(statistic.Name, servers, startdate, finaldate, precision, 0, false)
end

vgui.Register("nstatistics_list", PANEL, "EditablePanel")
