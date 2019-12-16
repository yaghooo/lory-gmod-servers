surface.CreateFont(
	"NStatistics_Title",
	{
		font = "Trebuchet18",
		size = 16,
		weight = 800
	}
)

surface.CreateFont(
	"NStatistics_Footer",
	{
		font = "Trebuchet18",
		size = 11,
		weight = 800
	}
)

surface.CreateFont(
	"NStatistics_StatisticButton",
	{
		font = "Arial",
		size = 15,
		weight = 1000
	}
)

surface.CreateFont(
	"NStatistics_LoadButton",
	{
		font = "Tahoma",
		size = 13,
		weight = 1000
	}
)

local PANEL = {}

local function findElement(parent, chain, callback)
	for _, disable in pairs(chain) do
		if isstring(disable) then
			if IsValid(parent[disable]) then
				callback(parent[disable])
			end
		elseif istable(disable) then
			local cur = parent

			for _, element in pairs(disable) do
				cur = cur[element]

				if not IsValid(cur) then
					break
				end
			end

			if IsValid(cur) then
				callback(cur)
			end
		end
	end
end

function PANEL:Init()
	local w = 1200
	local h = 700

	self:SetSize(w, h)
	self:Center()
	self:MakePopup()

	self.Title = self:Add("DLabel")
	self.Title:SetFont("NStatistics_Title")
	self.Title:SetText("NStatistics - " .. GetHostName())
	self.Title:SetColor(Color(240, 240, 240))
	self.Title:SetPos(10, 10)
	self.Title:SizeToContents()

	self.CloseButton = self:Add("DButton")
	self.CloseButton:SetFont("marlett")
	self.CloseButton:SetText("r")
	self.CloseButton:SetSize(30, 25)
	self.CloseButton:SetPos(w - self.CloseButton:GetWide(), 0)
	self.CloseButton.Paint = function()
	end
	self.CloseButton.DoClick = function()
		NSTATISTICS.CloseMenu()
	end
	self.CloseButton.UpdateColours = function(panel, skin)
		if panel:IsHovered() then
			return panel:SetTextStyleColor(Color(220, 220, 220))
		else
			return panel:SetTextStyleColor(Color(255, 255, 255))
		end
	end

	self.StatisticsScroller = self:Add("DScrollPanel")
	self.StatisticsScroller:SetPos(0, 40)
	self.StatisticsScroller:SetSize(220, h - 80)

	local StatisticsScrollerVBar = self.StatisticsScroller:GetVBar()
	StatisticsScrollerVBar:SetWide(10)

	StatisticsScrollerVBar.Paint = function(panel, w, h)
		surface.SetDrawColor(40, 40, 40)
		surface.DrawRect(2, 0, w - 2, h)
	end

	StatisticsScrollerVBar.btnGrip.Paint = function(panel, w, h)
		surface.SetDrawColor(Color(70, 70, 70))
		surface.DrawRect(2, 0, w - 2, h)
	end

	StatisticsScrollerVBar.btnUp.Paint = function(panel, w, h)
		surface.SetDrawColor(40, 40, 40)
		surface.DrawRect(2, 0, w - 2, h)

		draw.SimpleText("5", "marlett", w / 2 + 2, h / 2, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	StatisticsScrollerVBar.btnDown.Paint = function(panel, w, h)
		surface.SetDrawColor(40, 40, 40)
		surface.DrawRect(2, 0, w - 2, h)

		draw.SimpleText("6", "marlett", w / 2 + 2, h / 2, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	self.StatisticsLayout = self.StatisticsScroller:Add("DListLayout")
	self.StatisticsLayout:SetSize(self.StatisticsScroller:GetSize())

	self.Statistics = {}

	for _, v in pairs(NSTATISTICS.Statistics) do
		if not v.Disabled then
			local pnl = self.StatisticsLayout:Add("DButton")
			pnl:SetSize(self.StatisticsLayout:GetWide(), 40)
			pnl:SetText("")

			local text = NSTATISTICS.GetPhrase(v.Title)

			pnl.Paint = function(panel, w, h)
				if panel.Active then
					surface.SetDrawColor(0, 95, 199)
				elseif panel:IsHovered() then
					surface.SetDrawColor(35, 35, 35)
				else
					surface.SetDrawColor(30, 30, 30)
				end

				surface.DrawRect(0, 0, w, h)

				draw.SimpleText(
					text,
					"NStatistics_StatisticButton",
					10,
					h / 2,
					Color(255, 255, 255),
					TEXT_ALIGN_LEFT,
					TEXT_ALIGN_CENTER
				)
			end

			pnl.DoClick = function()
				for _, btn in pairs(self.Statistics) do
					btn.Active = false
				end

				pnl.Active = true
				NSTATISTICS.CurrentStatistic = v.Name

				if self.Content then
					self.Content:Clear()
					self.Content:SetTall(0)
				end

				if NSTATISTICS.config.Autoload and IsValid(self.Load) then
					self.Load:DoClick()
				end
			end

			table.insert(self.Statistics, pnl)
		end
	end

	if self.Statistics[1] then
		self.Statistics[1]:DoClick()
	end

	local ContentW, ContentH = w - self.StatisticsScroller:GetWide() - 10, h - 80

	self.ContentScroller = self:Add("DScrollPanel")
	self.ContentScroller:SetPos(self.StatisticsScroller:GetWide() + 5, 40)
	self.ContentScroller:SetSize(ContentW, ContentH)
	self.ContentScroller.Paint = function(panel, w, h)
		surface.SetDrawColor(240, 240, 240)
		surface.DrawRect(0, 0, w, h)
	end

	self.Content = self.ContentScroller:Add("DPanel")
	self.Content:SetWide(ContentW)
	self.Content.Paint = function()
	end

	self.DisplayTypePanel = self.ContentScroller:Add("DPanel")
	self.DisplayTypePanel:SetSize(ContentW - 20, 20)
	self.DisplayTypePanel.Paint = function()
	end
	self.DisplayTypePanel.Position = function(pself, y)
		pself:SetPos(10, y)
	end

	self.DisplayType = self.DisplayTypePanel:Add("DComboBox")
	self.DisplayType:SetSize(150, 20)

	self.DisplayType.OnSelect = function(panel, index, value, id)
		if self.OldID then
			if NSTATISTICS.Display[self.OldID].MakeInvisible then
				findElement(
					self,
					NSTATISTICS.Display[self.OldID].MakeInvisible,
					function(pnl)
						pnl:SetVisible(true)
					end
				)
			end

			if NSTATISTICS.Display[self.OldID].Disable then
				findElement(
					self,
					NSTATISTICS.Display[self.OldID].Disable,
					function(pnl)
						pnl:SetDisabled(false)
					end
				)
			end
		end

		if NSTATISTICS.Display[id].MakeInvisible then
			findElement(
				self,
				NSTATISTICS.Display[id].MakeInvisible,
				function(pnl)
					pnl:SetVisible(false)
				end
			)
		end

		if NSTATISTICS.Display[id].Disable then
			findElement(
				self,
				NSTATISTICS.Display[id].Disable,
				function(pnl)
					pnl:SetDisabled(true)
				end
			)
		end

		self:AlignElements()
		self.Content:Clear()

		self.OldID = id
	end

	for k, v in pairs(NSTATISTICS.Display) do
		self.DisplayType:AddChoice(NSTATISTICS.GetPhrase(v.Title), k, false)
	end

	self.DisplayTypeLabel = self.DisplayTypePanel:Add("DLabel")
	self.DisplayTypeLabel:SetText(NSTATISTICS.GetPhrase("DisplayType"))
	self.DisplayTypeLabel:SetTextColor(Color(120, 120, 120))
	self.DisplayTypeLabel:SizeToContents()
	self.DisplayTypeLabel:SetPos(self.DisplayType:GetWide() + 20, 10 - self.DisplayTypeLabel:GetTall() / 2)

	self.PrecisionPanel = self.ContentScroller:Add("DPanel")
	self.PrecisionPanel:SetSize(ContentW - 20, 20)
	self.PrecisionPanel.Paint = function()
	end
	self.PrecisionPanel.Position = function(pself, y)
		pself:SetPos(10, y)
	end

	self.Precision = self.PrecisionPanel:Add("DComboBox")
	self.Precision:SetSize(150, 20)
	self.Precision:AddChoice(NSTATISTICS.GetPhrase("Day"), NSTATISTICS.Precisions.Day, true)
	self.Precision:AddChoice(NSTATISTICS.GetPhrase("Month"), NSTATISTICS.Precisions.Month)
	self.Precision:AddChoice(NSTATISTICS.GetPhrase("Year"), NSTATISTICS.Precisions.Year)

	self.Precision.OnSelect = function(panel, index, value, id)
		self.Content:Clear()
	end

	self.PrecisionLabel = self.PrecisionPanel:Add("DLabel")
	self.PrecisionLabel:SetText(NSTATISTICS.GetPhrase("Precision"))
	self.PrecisionLabel:SetTextColor(Color(120, 120, 120))
	self.PrecisionLabel:SizeToContents()
	self.PrecisionLabel:SetPos(self.Precision:GetWide() + 20, 10 - self.PrecisionLabel:GetTall() / 2)

	self.ServersPanel = self.ContentScroller:Add("DPanel")
	self.ServersPanel:SetVisible(NSTATISTICS.IsDataAreServerDepending())
	self.ServersPanel.Paint = function()
	end

	self.ServersPanel.GetChildrenTall = function()
		local tall = self.ServersPanel.Label:GetTall()

		for _, v in pairs(self.ServersPanel.Servers) do
			tall = tall + v:GetTall() + 10
		end

		return tall
	end

	self.ServersPanel.Label = self.ServersPanel:Add("DLabel")
	self.ServersPanel.Label:SetTextColor(Color(120, 120, 120))
	self.ServersPanel.Label:SetText(NSTATISTICS.GetPhrase("Servers"))
	self.ServersPanel.Label:SizeToContents()

	self.ServersPanel:SetSize(ContentW - 20, self.ServersPanel.Label:GetTall())
	self.ServersPanel.Paint = function()
	end
	self.ServersPanel.Position = function(pself, y)
		pself:SetPos(10, y)

		return pself:GetChildrenTall()
	end

	self.ServersPanel.GetServers = function(pself)
		if not pself:IsVisible() then
			return nil
		end

		local servers = {}

		for _, v in pairs(pself.Servers) do
			if v:GetChecked() then
				table.insert(servers, v.id)
			end
		end

		if #servers == 0 then
			for _, v in pairs(pself.Servers) do
				if v.id == NSTATISTICS.config.ThisServer then
					v:SetChecked(true)
					break
				end
			end

			table.insert(servers, NSTATISTICS.config.ThisServer)
		end

		return servers
	end

	self.ServersPanel.Servers = {}
	self.ServersPanel.AddCheckbox = function(pself, id, server)
		local pnl = pself:Add("DCheckBoxLabel")
		pnl.id = id
		pnl:SetTextColor(Color(120, 120, 120))
		pnl:SetText(server)
		pnl:SetChecked(id == NSTATISTICS.config.ThisServer)
		pnl:SetPos(0, pself:GetChildrenTall() + 10)

		table.insert(pself.Servers, pnl)

		pself:SetTall(pself:GetChildrenTall())
	end

	for id, server in pairs(NSTATISTICS.config.Servers) do
		self.ServersPanel:AddCheckbox(id, server)
	end

	if table.Count(NSTATISTICS.config.Servers) <= 1 then
		self.ServersPanel:Hide()
	end

	self.FilterPanel = self.ContentScroller:Add("DPanel")
	self.FilterPanel.Paint = function()
	end

	self.FilterPanel.GetChildrenTall = function(pself)
		return pself.offset
	end

	self.FilterPanel.Align = function(pself, pnl, marginLeft, marginTop, marginBottom, tall)
		if not pself.offset then
			pself.offset = 0
		end

		marginLeft = marginLeft or 0
		marginTop = marginTop or 0
		marginBottom = marginBottom or 0
		tall = tall or pnl:GetTall()

		pnl:SetPos(marginLeft, pself.offset + marginTop)
		pself.offset = pself.offset + tall + marginTop + marginBottom
	end

	self.FilterPanel.Label = self.FilterPanel:Add("DLabel")
	self.FilterPanel.Label:SetText(NSTATISTICS.GetPhrase("Filter"))
	self.FilterPanel.Label:SetTextColor(Color(120, 120, 120))
	self.FilterPanel.Label:SizeToContents()
	self.FilterPanel:Align(self.FilterPanel.Label, 0, 10)

	self.FilterPanel.Filter = self.FilterPanel:Add("DTextEntry")
	self.FilterPanel.Filter:SetSize(160, 20)
	self.FilterPanel:Align(self.FilterPanel.Filter, 0, 10)

	self.FilterPanel.NotContain = self.FilterPanel:Add("DCheckBoxLabel")
	self.FilterPanel.NotContain:SetText(NSTATISTICS.GetPhrase("NotContain"))
	self.FilterPanel.NotContain:SetTextColor(Color(120, 120, 120))
	self.FilterPanel.NotContain:SetChecked(false)
	self.FilterPanel:Align(self.FilterPanel.NotContain, 0, 10)

	self.FilterPanel.ExactMatch = self.FilterPanel:Add("DCheckBoxLabel")
	self.FilterPanel.ExactMatch:SetText(NSTATISTICS.GetPhrase("ExactMatch"))
	self.FilterPanel.ExactMatch:SetTextColor(Color(120, 120, 120))
	self.FilterPanel.ExactMatch:SetChecked(false)
	self.FilterPanel:Align(self.FilterPanel.ExactMatch, 0, 10)

	self.FilterPanel:SetSize(ContentW - 20, self.FilterPanel:GetChildrenTall())

	self.FilterPanel.Position = function(pself, y)
		pself:SetPos(10, y)

		return pself:GetChildrenTall()
	end

	self.FilterPanel.GetFilter = function(pself)
		local filter = pself.Filter:GetValue()
		return NSTATISTICS.CreateFilter(
			filter,
			pself.NotContain:GetChecked(),
			pself.ExactMatch:GetChecked(),
			{},
			filter == ""
		)
	end

	self.StartDate = self.ContentScroller:Add("nstatistics_date")
	self.StartDate:SetText(NSTATISTICS.GetPhrase("StartDate"))
	self.StartDate.Position = function(pself, y)
		pself:SetPos(10, y)
	end

	self.StartDate.OnSelect = function()
		self.Content:Clear()
	end

	self.FinalDate = self.ContentScroller:Add("nstatistics_date")
	self.FinalDate:SetText(NSTATISTICS.GetPhrase("FinalDate"))
	self.FinalDate.Position = function(pself, y)
		pself:SetPos(10, y)
	end

	self.FinalDate.OnSelect = function()
		self.Content:Clear()
	end

	self.Load = self.ContentScroller:Add("DButton")
	self.Load:SetText(NSTATISTICS.GetPhrase("Load"))
	self.Load:SetFont("NStatistics_LoadButton")
	self.Load:SetTextColor(Color(255, 255, 255))
	self.Load:SetSize(250, 20)
	self.Load.Paint = function(panel, w, h)
		if panel:IsHovered() then
			surface.SetDrawColor(76, 141, 255)
		else
			surface.SetDrawColor(53, 118, 247)
		end
		surface.DrawRect(0, 0, w, h)
	end

	self.Load.DoClick = function()
		local _, display = self.DisplayType:GetSelected()

		local newPanel = NSTATISTICS.Display[display].Panel

		self.Content:Clear()
		self.Content:SetTall(0)
		NSTATISTICS.ContentPanel = self.Content:Add(newPanel)
		NSTATISTICS.ContentPanel.parameter = NSTATISTICS.Display[display].Parameter

		NSTATISTICS.ContentPanel.OldSetTall = NSTATISTICS.ContentPanel.SetTall

		NSTATISTICS.ContentPanel.SetTall = function(panel, h)
			self.Content:SetTall(h)
			panel:OldSetTall(h)
		end

		local startdate = self.StartDate:GetUNIXTime()
		local enddate = self.FinalDate:GetUNIXTime()

		if startdate and enddate and startdate > enddate then
			self.StartDate:SetUNIXTime(enddate)
			self.FinalDate:SetUNIXTime(startdate)

			startdate, enddate = enddate, startdate
		end

		local _, precision = self.Precision:GetSelected()
		local statistic = NSTATISTICS.Statistics[NSTATISTICS.CurrentStatistic]
		local filter = self.FilterPanel:GetFilter():Modify(NSTATISTICS.ContentPanel.IsRaw, statistic)

		NSTATISTICS.ContentPanel:SetInfo(startdate, enddate, statistic, precision, self.ServersPanel:GetServers(), filter)
	end
	self.Load.Position = function(pself, y)
		pself:SetPos(10, y + 15)
	end

	self.Language = self:Add("DComboBox")
	self.Language:SetWide(80)
	self.Language:SetPos(w - self.Language:GetWide() - 10, h - self.Language:GetTall() - 10)

	for id, lang in pairs(NSTATISTICS.Languages) do
		self.Language:AddChoice(lang.Name or "Unnamed", id, NSTATISTICS.Language == id)
	end

	self.Language.OnSelect = function(panel, index, value, id)
		NSTATISTICS.SetLanguage(id)
	end

	self.Footer = self:Add("DLabel")
	self.Footer:SetText("v" .. tostring(NSTATISTICS.Version))
	self.Footer:SetTextColor(Color(100, 100, 100))
	self.Footer:SetFont("NStatistics_Footer")
	self.Footer:SizeToContents()
	self.Footer:SetPos(5, h - self.Footer:GetTall() - 5)

	self.DisplayType:ChooseOptionID(1)

	self.Elements = {}

	table.insert(self.Elements, self.DisplayTypePanel)
	table.insert(self.Elements, self.PrecisionPanel)
	table.insert(self.Elements, self.ServersPanel)
	table.insert(self.Elements, self.FilterPanel)
	table.insert(self.Elements, self.StartDate)
	table.insert(self.Elements, self.FinalDate)
	table.insert(self.Elements, self.Load)

	self:AlignElements()
end

function PANEL:AlignElements()
	if self.Elements then
		local y = 10

		for _, pnl in pairs(self.Elements) do
			if pnl:IsVisible() then
				local tall = pnl:Position(y) or pnl:GetTall()

				y = y + tall + 10
			end
		end

		self.Content:SetPos(0, y + 10)
	end
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(30, 30, 30)
	surface.DrawRect(0, 0, w, h)
end

vgui.Register("nstatistics_menu", PANEL, "EditablePanel")
