surface.CreateFont(
	"NStatistics_DataBarText",
	{
		font = "Arial",
		size = 15,
		weight = 800
	}
)

surface.CreateFont(
	"NStatistics_PageNumber",
	{
		font = "Arial",
		size = 14,
		weight = 1000
	}
)

surface.CreateFont(
	"NStatistics_DataNotification",
	{
		font = "Arial",
		size = 15,
		weight = 1000
	}
)

local PANEL = {}

function PANEL:Init()
	self.IsRaw = true

	local w, h = self:GetParent():GetSize()
	self:SetSize(w, 30)
	self:GetParent():SetTall(30)

	local x = 10

	self.OnPagePnl = self:Add("DComboBox")
	self.OnPagePnl:SetSortItems(false)
	self.OnPagePnl:SetPos(x, 10)
	self.OnPagePnl:SetSize(80, 20)

	self.OnPagePnl.OnSelect = function(panel, index, value, id)
		self.OnPage = value

		if self.page then
			self:OpenPage(self.page)
		end
	end

	self.OnPage = 25

	self.OnPagePnl:AddChoice(10)
	self.OnPagePnl:AddChoice(25, 1, true)
	self.OnPagePnl:AddChoice(50)
	self.OnPagePnl:AddChoice(100)

	x = x + self.OnPagePnl:GetWide() + 20

	self.OnPagePnlLabel = self:Add("DLabel")
	self.OnPagePnlLabel:SetTextColor(Color(120, 120, 120))
	self.OnPagePnlLabel:SetText(NSTATISTICS.GetPhrase("OnPage"))
	self.OnPagePnlLabel:SizeToContents()
	self.OnPagePnlLabel:SetPos(x, 20 - self.OnPagePnlLabel:GetTall() / 2)

	x = x + self.OnPagePnlLabel:GetWide() + 70

	self.SearchLabel = self:Add("DLabel")
	self.SearchLabel:SetTextColor(Color(120, 120, 120))
	self.SearchLabel:SetText(NSTATISTICS.GetPhrase("SearchBySteamID"))
	self.SearchLabel:SizeToContents()
	self.SearchLabel:SetPos(x, 20 - self.SearchLabel:GetTall() / 2)

	x = x + self.SearchLabel:GetWide() + 10

	self.SearchInput = self:Add("DTextEntry")
	self.SearchInput:SetPos(x, 10)
	self.SearchInput:SetSize(130, 20)

	x = x + self.SearchInput:GetWide() + 10

	self.Search = self:Add("DButton")
	self.Search:SetText(NSTATISTICS.GetPhrase("Search"))
	self.Search:SetPos(x, 10)
	self.Search:SetSize(60, 20)
	self.Search.DoClick = function()
		self.steamid = self.SearchInput:GetValue()

		if self.steamid == "" then
			self.steamid = nil
		end

		self:OpenPage(1)
	end

	self.DataList = self:Add("DListLayout")
	self.DataList:SetPos(10, 40)
	self.DataList:SetWide(w - 40)
end

function PANEL:Paint(w, h)
end

local function set(self, sended, size)
	if not self.OnPage then
		return
	end

	local pages = math.ceil(size / self.OnPage)

	self.DataList:Clear()

	self.Data = {}

	if #sended == 0 then
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

		local h = nodata:GetTall()

		NoDataPanel:SetTall(h)
		self:SetTall(h + 90)

		return
	end

	local w = self.DataList:GetWide()

	local IsPlayer = self.statistic and self.statistic.ForPlayers

	local texts = {}
	local maxw = 0

	for k, v in ipairs(sended) do
		local text = v.date

		if v.server then
			text =
				text ..
				"     (" .. (NSTATISTICS.config.Servers[tonumber(v.server)] or ("Uknown server with ID: " .. v.server)) .. ")"
		end

		texts[k] = text

		surface.SetFont("NStatistics_DataBarText")
		local w = surface.GetTextSize(text)

		maxw = math.max(maxw, w)
	end

	for k, v in ipairs(sended) do
		local pnl = self.DataList:Add("DPanel")
		pnl:SetTall(30)

		local data = v.data

		if self.statistic and self.statistic.Beautifier then
			data = self.statistic.Beautifier(data, pnl)
		else
			data = data
		end

		local text = v.date

		if v.server then
			text =
				text ..
				"     (" .. (NSTATISTICS.config.Servers[tonumber(v.server)] or ("Uknown server with ID: " .. v.server)) .. ")"
		end

		pnl.Paint = function(_, w, h)
			if k % 2 == 0 then
				surface.SetDrawColor(220, 220, 220)
			else
				surface.SetDrawColor(230, 230, 230)
			end
			surface.DrawRect(0, 0, w, h)

			draw.SimpleText(text, "NStatistics_DataBarText", 20, h / 2, Color(120, 120, 120), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText(
				data,
				"NStatistics_DataBarText",
				w - 20,
				h / 2,
				Color(120, 120, 120),
				TEXT_ALIGN_RIGHT,
				TEXT_ALIGN_CENTER
			)

			if IsPlayer then
				draw.SimpleText(
					v.id,
					"NStatistics_DataBarText",
					maxw + 70,
					h / 2,
					Color(120, 120, 120),
					TEXT_ALIGN_LEFT,
					TEXT_ALIGN_CENTER
				)
			end
		end
	end

	self.Footer = self.DataList:Add("DPanel")
	self.Footer:SetTall(50)
	self.Footer.Paint = function()
	end

	self.GoToPage = self.Footer:Add("DNumberWang")
	self.GoToPage:SetValue(self.page)
	self.GoToPage:SetPos(w - 40, 30)
	self.GoToPage:SetSize(30, 18)
	self.GoToPage:HideWang()
	self.GoToPage.OnLoseFocus = function()
		local value = math.Clamp(self.GoToPage:GetValue(), 1, pages)
		self.GoToPage:SetText(value)

		self:OpenPage(value)
	end

	self.GoToPageLabel = self.Footer:Add("DLabel")
	self.GoToPageLabel:SetText(NSTATISTICS.GetPhrase("GoToPage"))
	self.GoToPageLabel:SetTextColor(Color(120, 120, 120))
	self.GoToPageLabel:SizeToContents()
	self.GoToPageLabel:SetPos(w - 50 - self.GoToPageLabel:GetWide(), 38 - self.GoToPageLabel:GetTall() / 2)

	-- PGNum 16681496
	self.Pages = self.Footer:Add("DIconLayout")
	self.Pages:SetTall(30)
	self.Pages:SetPos(0, 20)
	self.Pages.Paint = function(_, w, h)
	end

	local w = 0

	self.Pages.AddPage = function(panel, IsEnabled, text, font, callback, color)
		local btn = panel:Add("DButton")
		btn:SetFont(font or "NStatistics_PageNumber")
		btn:SetText(text)
		btn:SetTextColor(Color(110, 110, 110))
		btn:SetSize(30, 30)
		btn:SetEnabled(IsEnabled)
		btn.DoClick = callback
		btn.Paint = function(_, w, h)
			if color then
				surface.SetDrawColor(color)
			elseif btn:IsHovered() and IsEnabled then
				surface.SetDrawColor(220, 220, 220)
			else
				surface.SetDrawColor(230, 230, 230)
			end
			surface.DrawRect(0, 0, w, h)
		end

		w = w + btn:GetWide()
	end

	if self.page ~= 1 then
		self.Pages:AddPage(
			true,
			"3",
			"marlett",
			function()
				local page = self.page - 1

				if page > 0 then
					self:OpenPage(page)
				end
			end
		)
	end

	local ToAdd = {}

	for i = 1, 3 do
		ToAdd[i] = true
	end

	for i = self.page - 2, self.page + 2 do
		ToAdd[i] = true
	end

	for i = pages - 2, pages do
		ToAdd[i] = true
	end

	for k, v in SortedPairs(ToAdd) do
		if k >= 1 and k <= pages then
			if k == self.page then
				self.Pages:AddPage(
					false,
					k,
					nil,
					function()
						self:OpenPage(k)
					end,
					Color(210, 210, 210)
				)
			else
				self.Pages:AddPage(
					true,
					k,
					nil,
					function()
						self:OpenPage(k)
					end
				)
			end

			if not ToAdd[k + 1] and k + 1 <= pages then
				self.Pages:AddPage(false, "...", nil, nil)
			end
		end
	end

	if self.page ~= pages then
		self.Pages:AddPage(
			true,
			"4",
			"marlett",
			function()
				local page = self.page + 1

				if page <= pages then
					self:OpenPage(page)
				end
			end
		)
	end

	self.Pages:SetWide(w)

	local h = #sended * 30 + 90

	self:SetTall(h + 15)
end

function PANEL:SetData(sended, size)
	if self.statistic.ForPlayers and NSTATISTICS.config.RawDataNicks and table.Count(sended) > 0 then
		for _, tbl in pairs(sended) do
			steamworks.RequestPlayerInfo(util.SteamIDTo64(tbl.id))
		end

		timer.Simple(
			1,
			function()
				for _, tbl in pairs(sended) do
					tbl.id = tbl.id .. " (" .. steamworks.GetPlayerName(util.SteamIDTo64(tbl.id)) .. ")"
				end

				set(self, sended, size)
			end
		)
	else
		set(self, sended, size)
	end
end

function PANEL:OpenPage(page, update)
	if NSTATISTICS.CurrentStatistic then
		self.page = page
		self.DataList:Clear()

		local LoadingPanel = self.DataList:Add("DPanel")
		LoadingPanel:SetWide(self.DataList:GetWide())
		LoadingPanel.Paint = function(_, w, h)
		end

		local loading = LoadingPanel:Add("DLabel")
		loading:SetText(NSTATISTICS.GetPhrase("Loading"))
		loading:SetFont("NStatistics_DataNotification")
		loading:SetTextColor(Color(130, 130, 130))
		loading:SizeToContents()
		loading:CenterHorizontal()

		local h = loading:GetTall()

		LoadingPanel:SetTall(h)
		self:SetTall(h + 90)

		local from = self.OnPage * (self.page - 1) + 1

		NSTATISTICS.RequestRawData(
			self.statistic.Name,
			self.servers,
			self.startdate,
			self.finaldate,
			from,
			from + self.OnPage - 1,
			update or false,
			self.steamid,
			self.filter
		)
	end
end

function PANEL:SetInfo(startdate, finaldate, statistic, precision, servers, filter)
	self.startdate = startdate
	self.finaldate = finaldate
	self.statistic = statistic
	self.servers = servers
	self.filter = filter

	self:OpenPage(1, true)
end

vgui.Register("nstatistics_data", PANEL, "EditablePanel")
