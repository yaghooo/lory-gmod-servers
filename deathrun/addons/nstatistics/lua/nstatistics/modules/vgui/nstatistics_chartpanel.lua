surface.CreateFont(
	"NStatistics_ChartTitle",
	{
		font = "Arial",
		size = 15,
		weight = 1200
	}
)

local PANEL = {}

function PANEL:SetData(sended)
	local sw, sh = self:GetSize()

	self.dates = {}
	local data = {}

	for _, tbl in pairs(sended) do
		if not table.HasValue(self.dates, tbl.date) then
			table.insert(self.dates, tbl.date)
		end

		local key = table.KeyFromValue(self.dates, tbl.date)

		for k, v in pairs(tbl.data) do
			if not data[k] then
				data[k] = {}
			end

			data[k][key] = v
		end
	end

	for curdate, _ in pairs(self.dates) do
		for _, tbl in pairs(data) do
			local finded = false

			for date, _ in pairs(tbl) do
				if date == curdate then
					finded = true
					break
				end
			end

			if not finded then
				tbl[curdate] = 0
			end
		end
	end

	if self.statistic and self.statistic.ShowKey then
		self.lw = 90
	end

	if self.lw then
		sw = sw - self.lw
	end

	self.XOffset = (sw - 80) / math.max(table.Count(self.dates) - 1, 1)

	surface.SetFont("NStatistics_LineChartAxis")

	local maxw = 0

	for k, v in pairs(self.dates) do
		local w = surface.GetTextSize(v)

		if w > maxw then
			maxw = w
		end

		if maxw > self.XOffset then
			break
		end
	end

	self.TwoLines = (maxw > (self.XOffset - 20)) and 1 or 0

	local max

	for k, tbl in pairs(sended) do
		for _, v in pairs(tbl.data) do
			if max and v > max or not max then
				max = v
			end
		end
	end

	if not max then
		return
	end

	if self.statistic.MinChartY then
		max = math.max(self.statistic.MinChartY, max)
	end

	local NewMax, NewMin
	local unit = 0

	local h = draw.GetFontHeight("NStatistics_LineChartAxis")

	if max <= 10 then
		unit = 1
		NewMax = 10

		self.YOffset = (sh - 100) / 10
	else
		local i = 1
		local add

		if max <= 60 then
			add = 5
		elseif max <= 400 then
			add = 10
		else
			add = 100
		end

		repeat
			unit = unit + add

			local count = math.ceil(max / unit)
			NewMax = count * unit

			self.YOffset = (sh - 100) / count

			i = i + 1
		until self.YOffset > h + 6 or i >= 100
	end

	self.max = NewMax
	self.step = unit
	self.corner = {x = 40, y = sh - 40}
	self.width = sw - 80
	self.height = sh - 100

	local max = NSTATISTICS.config.MaxStatisticsBranches
	local count = table.Count(data)

	if max and max < count then
		local sums = {}

		for date, tbl in pairs(data) do
			local sum = 0

			for k, v in pairs(tbl) do
				sum = sum + v
			end

			table.insert(
				sums,
				{
					key = date,
					sum = sum
				}
			)
		end

		table.SortByMember(sums, "sum")

		for i = 1, count - max do
			local key = sums[#sums].key
			table.remove(sums, #sums)
			data[key] = nil
		end
	end

	local copy = table.Copy(data)
	data = {}

	for chart, cdata in pairs(copy) do
		local key

		if self.statistic.Legend then
			key = self.statistic.Legend(chart)
		else
			key = chart
		end

		data[key] = cdata
	end

	self:DataChanged(data)

	self.loaded = true
end

function PANEL:CreateLegend(newData, colors, hovered)
	self.ShowLegend = self.statistic and self.statistic.ShowKey
	self.LegendLabels = {}
	self.DisabledBranches = {}

	if self.ShowLegend then
		local w = 50

		for chart, data in pairs(newData) do
			surface.SetFont("NStatistics_Legend")
			local tw = math.min(surface.GetTextSize(chart), 150)

			if tw > w then
				w = tw
			end
		end

		self:SetLegendWide(w)

		self.LegendScroller = self:Add("DScrollPanel")
		self.LegendScroller:SetPos(self:GetWide() - w - 20 - 10, 30)
		self.LegendScroller:SetSize(w + 30, self:GetTall() - 40)

		local vbar = self.LegendScroller:GetVBar()
		vbar:SetWide(4)

		vbar.Paint = function(panel, w, h)
		end

		vbar.btnGrip.Paint = function(panel, w, h)
			draw.RoundedBox(8, 0, 0, w, h, Color(200, 200, 200))
		end

		vbar.btnUp.Paint = function(panel, w, h)
		end

		vbar.btnDown.Paint = function(panel, w, h)
		end

		local selectPnl = self.LegendScroller:Add("DPanel")
		selectPnl:SetSize(w + 20, 16)
		selectPnl.Paint = function()
		end

		selectPnl.SelectAll = selectPnl:Add("DButton")
		selectPnl.SelectAll:SetSize(16, 16)
		selectPnl.SelectAll:SetPos(0, 0)
		selectPnl.SelectAll:SetText("")

		selectPnl.SelectAll.Paint = function(_, w, h)
			local color

			if selectPnl.SelectAll:IsHovered() then
				color = Color(120, 120, 120)
			else
				color = Color(150, 150, 150)
			end

			surface.SetDrawColor(color)
			surface.DrawRect(0, 0, w, h)

			surface.SetDrawColor(255, 255, 255)
			surface.DrawRect(2, 2, w - 4, h - 4)

			surface.SetDrawColor(color)
			surface.DrawRect(4, 4, w - 8, h - 8)
		end

		selectPnl.SelectAll.DoClick = function()
			for k, v in pairs(self.DisabledBranches) do
				self.DisabledBranches[k] = false
			end
		end

		selectPnl.DeselectAll = selectPnl:Add("DButton")
		selectPnl.DeselectAll:SetSize(16, 16)
		selectPnl.DeselectAll:SetPos(25, 0)
		selectPnl.DeselectAll:SetText("")

		selectPnl.DeselectAll.Paint = function(_, w, h)
			local color

			if selectPnl.DeselectAll:IsHovered() then
				color = Color(120, 120, 120)
			else
				color = Color(150, 150, 150)
			end

			surface.SetDrawColor(color)
			surface.DrawRect(0, 0, w, h)

			surface.SetDrawColor(255, 255, 255)
			surface.DrawRect(2, 2, w - 4, h - 4)
		end

		selectPnl.DeselectAll.DoClick = function()
			for k, v in pairs(self.DisabledBranches) do
				self.DisabledBranches[k] = true
			end
		end

		for chart, data in SortedPairsByMemberValue(self:GetDataWithSum(newData), "__utilsum", true) do
			self.DisabledBranches[chart] = false

			local pnl = self.LegendScroller:Add("DButton")
			pnl:SetText("")
			pnl:SetSize(w + 20, 0)

			pnl.Paint = function(_, w, h)
				if pnl:IsHovered() then
					surface.SetDrawColor(255, 255, 208)
					surface.DrawRect(0, 0, w, h)
				end

				self:PaintLegendIcon(colors[chart], chart, 14, 14, pnl:IsHovered())
			end

			pnl.PaintOver = function(_, w, h)
				if self.DisabledBranches[chart] then
					surface.SetDrawColor(255, 255, 255, 100)
					surface.DrawRect(0, 0, w, h)
				end
			end

			pnl.Think = function()
				if pnl:IsHovered() then
					if hovered then
						hovered(chart, colors[chart])
					end

					if self.hoverdChart ~= chart then
						self.hoverdChart = chart
					end

					pnl.label:SetTextColor(Color(90, 90, 90))
				else
					if self.hoverdChart == chart then
						self.hoverdChart = nil
					end

					pnl.label:SetTextColor(Color(120, 120, 120))
				end
			end

			pnl.DoClick = function()
				self.DisabledBranches[chart] = not self.DisabledBranches[chart]
			end

			pnl.label = pnl:Add("DLabel")
			pnl.label:SetTextColor(Color(120, 120, 120))
			pnl.label:SetPos(20, 0)
			pnl.label:SetWide(w)
			pnl.label:SetAutoStretchVertical(true)
			pnl.label:SetWrap(true)
			pnl.label:SetFont("NStatistics_Legend")
			pnl.label:SetText(chart)

			self.LegendLabels[chart] = {
				pnl = pnl,
				index = table.Count(self.LegendLabels)
			}

			pnl.label.PerformLayout = function(_, w, h)
				pnl:SetTall(h)

				local sh = 30

				for k, v in SortedPairsByMemberValue(self.LegendLabels, "index") do
					if IsValid(v.pnl) then
						v.pnl:SetPos(0, sh)
						sh = sh + v.pnl:GetTall() + 10
					end
				end
			end
		end
	end
end

function PANEL:PaintLegendIcon(color, chart)
end

function PANEL:GetDataWithSum(data)
	local newdata = table.Copy(data)

	for k, tbl in pairs(newdata) do
		local sum = 0

		for _, v in pairs(tbl) do
			sum = sum + v
		end

		newdata[k].__utilsum = sum
	end

	return newdata
end

function PANEL:SetLegendWide(wide)
	self.lw = wide
	self.width = self:GetWide() - wide - 80
	self.XOffset = self.width / math.max(table.Count(self.dates) - 1, 1)

	local maxw = 0

	for k, v in pairs(self.dates) do
		local w = surface.GetTextSize(v)

		if w > maxw then
			maxw = w
		end

		if maxw > self.XOffset then
			break
		end
	end

	self.TwoLines = (maxw > (self.XOffset - 20)) and 1 or 0
end

function PANEL:DrawInfo(info, x, y)
	self:GetParent():DrawInfo(info, x, y)
end

function PANEL:Paint(w, h)
	if self.loaded then
		self:PaintBackground(w, h)

		local ChartW = w

		if self.lw then
			ChartW = ChartW - self.lw
		end

		self:PaintAxis(ChartW, h)
		self:PaintChart(40, 40, ChartW - 80, h - 80)
	end
end

function PANEL:PaintBackground(w, h)
	surface.SetDrawColor(255, 255, 255)
	surface.DrawRect(0, 0, w, h)

	if self.server then
		local tw = w

		if self.lw then
			tw = w - self.lw
		end

		draw.SimpleText(
			NSTATISTICS.config.Servers[self.server],
			"NStatistics_ChartTitle",
			tw / 2,
			15,
			Color(80, 80, 80),
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_TOP
		)
	end
end

function PANEL:PaintAxis(w, h)
	surface.SetDrawColor(130, 130, 130)
	surface.DrawRect(40, 60, 2, h - 100)
	surface.DrawRect(40, h - 42, w - 80, 2)

	local i = 0

	for _, v in pairs(self.dates) do
		draw.SimpleText(
			v,
			"NStatistics_LineChartAxis",
			self:GetDatePos(i),
			h - 30 + (i % 2 * self.TwoLines * 10),
			Color(100, 100, 100),
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_TOP
		)
		i = i + 1
	end

	for i = 0, self.max / self.step do
		local y = h - 40 - i * self.YOffset

		draw.SimpleText(
			i * self.step,
			"NStatistics_LineChartAxis",
			30,
			y,
			Color(100, 100, 100),
			TEXT_ALIGN_RIGHT,
			TEXT_ALIGN_CENTER
		)

		if i ~= 0 then
			surface.SetDrawColor(200, 200, 200)
			surface.DrawRect(42, y, w - 82, 1)
		end
	end
end

function PANEL:GetDatePos(i)
	return 40 + i * self.XOffset
end

function PANEL:PaintChart(x, y, w, h)
end

function PANEL:DataChanged(data)
end

vgui.Register("nstatistics_chartpanel", PANEL, "EditablePanel")
