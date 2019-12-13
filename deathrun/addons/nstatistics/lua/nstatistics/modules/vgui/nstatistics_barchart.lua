local PANEL = {}

local hoveringBlackout = 50

function PANEL:PaintChart(x, y, w, h)
	local count = table.Count(self.data)
	local chartw = (self.offset - 20) / count
	local w = math.min(chartw, 50)
	local XAdd = 40 + self.offset / 2 - w * count / 2

	local i = 0

	local mx, my = gui.MousePos()
	local tx, ty, text

	for chart, values in pairs(self.data) do
		if not self.DisabledBranches[chart] then
			for date, data in pairs(values) do
				local h = math.max(self.height * data / self.max, 3)
				local x = (date - 1) * self.offset + i * math.floor(w) + XAdd
				local y = self.corner.y - h

				local sx, sy = self:LocalToScreen(x, y)

				local color = self.colors[chart]

				if not text and mx >= sx and mx <= sx + w and my >= sy and my <= sy + h then
					color = Color(math.min(color.r + 30, 255), math.min(color.g + 30, 255), math.min(color.b + 30, 255))

					tx = sx + w / 2
					ty = sy

					text = ""

					if self.ShowLegend then
						text = chart .. "\n"
					end

					text = text .. self.dates[date]
					text = text .. "\n" .. NSTATISTICS.GetStatisticsDisplayText(self.statistic.Display, data)
				else
					color = Color(color.r, color.g, color.b)
				end

				if self.hoverdChart == chart then
					color.r = math.max(color.r - hoveringBlackout, 0)
					color.g = math.max(color.g - hoveringBlackout, 0)
					color.b = math.max(color.b - hoveringBlackout, 0)
				end

				surface.SetDrawColor(color)
				surface.DrawRect(x, y, w, h)
			end

			i = i + 1
		end
	end

	if text then
		self:DrawInfo(text, tx, ty)
	end
end

function PANEL:GetDatePos(i)
	return 40 + self.offset / 2 + i * self.offset
end

function PANEL:DataChanged(newData)
	self.colors = {}

	local ColorsCopy = table.Copy(NSTATISTICS.config.HistogramColors)

	for k, v in pairs(newData) do
		local color

		if #ColorsCopy == 0 then
			color = ColorRand()
		else
			local key = math.random(#ColorsCopy)
			color = ColorsCopy[key]
			table.remove(ColorsCopy, key)
		end

		self.colors[k] = color
	end

	self:CreateLegend(newData, self.colors)
	self.data = newData

	local max = 0

	for k, v in pairs(newData) do
		local count = table.Count(v)

		if count > max then
			max = count
		end
	end

	self.offset = math.floor(self.width / max)
end

function PANEL:PaintLegendIcon(color, chart, w, h)
	surface.SetDrawColor(color)
	surface.DrawRect(0, 0, w, h)
end

vgui.Register("nstatistics_barchart", PANEL, "nstatistics_chartpanel")
