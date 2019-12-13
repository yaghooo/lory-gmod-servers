surface.CreateFont(
	"NStatistics_LineChartAxis",
	{
		font = "Arial",
		size = 12,
		weight = 1000
	}
)

surface.CreateFont(
	"NStatistics_NoteLabel",
	{
		font = "Tahoma",
		size = 13,
		weight = 1200
	}
)

surface.CreateFont(
	"NStatistics_Legend",
	{
		font = "Tahoma",
		size = 13,
		weight = 1000
	}
)

surface.CreateFont(
	"NStatistics_ChartNotification",
	{
		font = "Arial",
		size = 15,
		weight = 1000
	}
)

local resolution = 64

local texture = GetRenderTarget("triangle" .. os.time(), resolution, resolution, false)

local triangle =
	CreateMaterial(
	"triangle" .. os.time(),
	"UnlitGeneric",
	{
		["$basetexture"] = texture:GetName(),
		["$vertexalpha"] = 1,
		["$vertexcolor"] = 1
	}
)

local vertices = {
	{x = resolution * 0.3, y = 0},
	{x = resolution, y = 0},
	{x = 0, y = resolution}
}

render.PushRenderTarget(texture)
cam.Start2D()

render.OverrideAlphaWriteEnable(true, true)
render.Clear(0, 0, 0, 0, true, true)

draw.NoTexture()
surface.SetDrawColor(255, 255, 255)
surface.DrawPoly(vertices)

cam.End2D()
render.PopRenderTarget()

triangle:SetTexture("$basetexture", texture)

local PANEL = {}

function PANEL:Init()
	self.IsRaw = false

	local w = self:GetParent():GetWide()
	self:SetPos(10, 0)
	self:SetWidth(w - 40)

	self.InfoPanel = vgui.Create("DPanel")

	self.InfoPanel.Paint = function(_, w, h)
		surface.SetDrawColor(60, 60, 60)
		surface.DrawRect(0, 0, w, h - 15)

		surface.SetMaterial(triangle)
		surface.DrawTexturedRect(w / 2, h - 15, 15, 15)

		surface.SetDrawColor(255, 255, 255)
		surface.DrawRect(2, 2, w - 4, h - 19)
	end

	self.InfoPanel.label = self.InfoPanel:Add("DLabel")
	self.InfoPanel.label:SetFont("NStatistics_NoteLabel")
	self.InfoPanel.label:SetTextColor(Color(100, 100, 100))
	self.InfoPanel.label:SetWide(120)
	self.InfoPanel.label:SetWrap(true)
	self.InfoPanel.label:SetAutoStretchVertical(true)

	self.InfoPanel:SetPaintedManually(true)
end

function PANEL:SetInfo(startdate, finaldate, statistic, precision, servers, filter)
	self.startdate = startdate
	self.finaldate = finaldate
	self.statistic = statistic
	self.precision = precision
	self.servers = servers
	self.filter = filter

	local loading = self:Add("DLabel")
	loading:SetText(NSTATISTICS.GetPhrase("Loading"))
	loading:SetFont("NStatistics_ChartNotification")
	loading:SetTextColor(Color(130, 130, 130))
	loading:SizeToContents()
	loading:CenterHorizontal()
	self:SetTall(loading:GetTall())

	NSTATISTICS.RequestData(
		statistic.Name,
		servers,
		startdate,
		finaldate,
		precision,
		self:GetMaxCount(),
		true,
		self.filter
	)
end

function PANEL:GetMaxCount()
	local w = self:GetWide()
	local strw = (self:GetDateLabelSize() + 25)
	local max = math.ceil(w / strw * 2)

	local chart = self:GetChartMaxCount()

	if chart and chart ~= 0 then
		return math.min(math.ceil(chart), max)
	else
		return max
	end
end

function PANEL:GetChartMaxCount()
end

function PANEL:GetDateLabelSize()
	local date = {
		year = 1111
	}

	if self.precision ~= NSTATISTICS.Precisions.Year then
		date.month = 11

		if self.precision ~= NSTATISTICS.Precisions.Month then
			date.day = 11
		end
	end

	surface.SetFont("NStatistics_LineChartAxis")
	return surface.GetTextSize(NSTATISTICS.GetDateFormat(date))
end

function PANEL:SetData(sended)
	self:Clear()
	self:SetTall(440)

	if table.Count(sended) == 0 then
		local nodata = self:Add("DLabel")
		nodata:SetText(NSTATISTICS.GetPhrase("NoData"))
		nodata:SetFont("NStatistics_ChartNotification")
		nodata:SetTextColor(Color(130, 130, 130))
		nodata:SizeToContents()
		nodata:CenterHorizontal()
		self:SetTall(nodata:GetTall())

		return
	end

	local servers = {}

	for _, tbl in pairs(sended) do
		local server = tonumber(tbl.server)

		if not servers[server] then
			servers[server] = {}
		end

		table.insert(
			servers[server],
			{
				data = tbl.data,
				date = tbl.date
			}
		)
	end

	self.ChartPanels = {}

	if self.parameter then
		local y = 0

		for server, tbl in pairs(servers) do
			local pnl = self:Add(self.parameter)

			if not IsValid(pnl) then
				NSTATISTICS.Error("Invalid VGUI: " .. tostring(self.parameter))
			end

			pnl:SetPos(0, y)
			pnl:SetSize(self:GetWide(), 440)
			pnl.server = server
			pnl.statistic = self.statistic
			pnl:SetData(tbl)

			table.insert(self.ChartPanels, pnl)

			y = y + pnl:GetTall() + 40
		end

		self:SetTall(y - 40)
	end
end

local lastx, lasty

function PANEL:DrawInfo(info, x, y)
	self.InfoPanel.label:SetText(info)
	self.InfoPanel.label:SizeToContentsX()

	local w, h = self.InfoPanel.label:GetSize()
	self.InfoPanel:SetSize(w + 10, h + 25)
	self.InfoPanel:SetPos(x - w / 2, y - self.InfoPanel:GetTall() - 5)
	self.InfoPanel.label:SetPos(5, 5)

	if lastx == x and lasty == y then
		self.PaintInfoPanel = true
	end

	lastx = x
	lasty = y
end

function PANEL:PaintOver()
	if self.PaintInfoPanel then
		self.InfoPanel:PaintManual()
		self.PaintInfoPanel = false
	end
end

vgui.Register("nstatistics_chartbase", PANEL, "EditablePanel")
