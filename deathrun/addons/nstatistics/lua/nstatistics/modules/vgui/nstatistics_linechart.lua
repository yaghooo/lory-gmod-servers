local PANEL = {}

local function DrawThickLine(x1, y1, x2, y2, thick, color, outline)
	local w = x2 - x1
	local h = y2 - y1

	local angle = math.atan2(y1 - y2, x1 - x2) / math.pi * 180

	local x = x1 + w / 2
	local y = y1 + h / 2
	local lw = math.sqrt(w ^ 2 + h ^ 2)

	draw.NoTexture()

	-- Smooth sharp edges
	surface.SetDrawColor(Color(color.r, color.g, color.b, math.max(0, color.a - 70)))
	surface.DrawTexturedRectRotated(x, y, lw, thick + outline, -angle)

	surface.SetDrawColor(color)
	surface.DrawTexturedRectRotated(x, y, lw, thick, -angle)
end

-- https://wiki.garrysmod.com/page/surface/DrawPoly
local function DrawCircle(x, y, radius, seg)
	local cir = {}

	table.insert(cir, {x = x, y = y, u = 0.5, v = 0.5})
	for i = 0, seg do
		local a = math.rad((i / seg) * -360)
		table.insert(
			cir,
			{x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5}
		)
	end

	local a = math.rad(0) -- This is needed for non absolute segment counts
	table.insert(
		cir,
		{x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5}
	)

	surface.DrawPoly(cir)
end

local resolution = 64

local texture = GetRenderTarget("circle" .. os.time(), resolution, resolution, false)

local circle =
	CreateMaterial(
	"circle" .. os.time(),
	"UnlitGeneric",
	{
		["$basetexture"] = texture:GetName(),
		["$vertexalpha"] = 1,
		["$vertexcolor"] = 1
	}
)

render.PushRenderTarget(texture)
cam.Start2D()

render.OverrideAlphaWriteEnable(true, true)
render.Clear(0, 0, 0, 0, true, true)

draw.NoTexture()
surface.SetDrawColor(255, 255, 255)
DrawCircle(resolution / 2, resolution / 2, resolution / 2, 64)

cam.End2D()
render.PopRenderTarget()

circle:SetTexture("$basetexture", texture)

local hoveringBlackout = 50

function PANEL:PaintChart(x, y, w, h)
	surface.SetDrawColor(255, 0, 0)

	local HoveredR = 10
	local mx, my = gui.MousePos()

	local tx, ty, text

	for chart, tbl in pairs(self.vertices) do
		if not self.DisabledBranches[chart] then
			local isHovered = self.hoverdChart == chart

			for k, v in ipairs(tbl) do
				local NextVertex = tbl[k + 1]

				if NextVertex then
					local color = Color(tbl.color.r, tbl.color.g, tbl.color.b)

					if isHovered then
						color.r = math.max(color.r - hoveringBlackout, 0)
						color.g = math.max(color.g - hoveringBlackout, 0)
						color.b = math.max(color.b - hoveringBlackout, 0)
					end

					DrawThickLine(v.x, v.y, NextVertex.x, NextVertex.y, 2, color, 1)
				end

				local r

				local x, y = self:LocalToScreen(v.x, v.y)

				if
					not text and mx >= x - HoveredR / 2 and mx <= x + HoveredR / 2 and my >= y - HoveredR / 2 and
						my <= y + HoveredR / 2
				 then
					r = HoveredR
					hovered = true

					text = ""

					if self.ShowLegend then
						text = chart .. "\n"
					end

					text = text .. v.date
					text = text .. "\n" .. v.data

					tx, ty = x, y
				else
					r = 8
					hovered = false
				end

				local color = Color(tbl.circlecolor.r, tbl.circlecolor.g, tbl.circlecolor.b)

				if isHovered then
					color.r = math.max(color.r - hoveringBlackout, 0)
					color.g = math.max(color.g - hoveringBlackout, 0)
					color.b = math.max(color.b - hoveringBlackout, 0)
				end

				surface.SetDrawColor(color)
				surface.SetMaterial(circle)
				surface.DrawTexturedRect(v.x - r / 2, v.y - r / 2, r, r)
			end
		end
	end

	if tx and ty and text then
		self:DrawInfo(text, tx, ty)
	end
end

function PANEL:DataChanged(newData)
	self.vertices = {}
	self.colors = {}

	local ColorsCopy = table.Copy(NSTATISTICS.config.LineChartsColors)

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

	local addChartName = table.Count(newData) > 1

	for chart, values in pairs(newData) do
		local tbl = {}

		for date, data in pairs(values) do
			local info = {}
			info.x = (date - 1) * self.XOffset + self.corner.x
			info.y = self.corner.y - self.height * data / self.max
			info.data = NSTATISTICS.GetStatisticsDisplayText(self.statistic.Display, data)
			info.date = self.dates[date]

			if addChartName then
				info.chart = chart
			end

			table.insert(tbl, info)
		end

		tbl.color = self.colors[chart]
		tbl.circlecolor = Color(math.max(tbl.color.r - 40, 0), math.max(tbl.color.g - 40, 0), math.max(tbl.color.b - 40, 0))

		self.vertices[chart] = tbl
	end
end

function PANEL:PaintLegendIcon(color, chart, w, h)
	surface.SetDrawColor(color)
	surface.DrawRect(0, h / 2 - 1, w, 3)
end

vgui.Register("nstatistics_linechart", PANEL, "nstatistics_chartpanel")
