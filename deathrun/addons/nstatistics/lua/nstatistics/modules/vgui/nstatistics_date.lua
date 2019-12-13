surface.CreateFont(
	"NStatistics_DateButton",
	{
		font = "Tahoma",
		size = 13,
		weight = 1000
	}
)

surface.CreateFont(
	"NStatistics_DatePanelTitle",
	{
		font = "Tahoma",
		size = 13,
		weight = 1000
	}
)

surface.CreateFont(
	"NStatistics_DateButton",
	{
		font = "Tahoma",
		size = 13,
		weight = 1000
	}
)

local DATEPOPUP = {}

local function center(pnl1, pnl2)
	local x1, y1 = pnl1:GetPos()
	local x2, y2 = pnl2:GetPos()

	pnl1:SetPos(x2 + (pnl2:GetWide() - pnl1:GetWide()) / 2, y1)
end

local InputW = -10

local function CreateLabeledInput(parent, label, input, text)
	parent[label] = parent.Inputs:Add("DLabel")
	parent[label]:SetText(NSTATISTICS.GetPhrase(text))
	parent[label]:SizeToContents()

	parent[input] = parent.Inputs:Add("DNumberWang")
	parent[input]:SetPos(InputW + 10, parent[label]:GetTall() + 5)
	parent[input]:SetSize(40, 20)
	parent[input]:HideWang()
	parent[input].OnLoseFocus = function()
		parent:SetDate(parent:GetDate())
	end

	center(parent[label], parent[input])

	InputW = InputW + parent[input]:GetWide() + 10
end

function DATEPOPUP:Init()
	local w, h = 400, 150

	self:SetSize(w, h)
	self:Center()
	self:MakePopup()

	self.CloseButton = self:Add("DButton")
	self.CloseButton:SetFont("marlett")
	self.CloseButton:SetText("r")
	self.CloseButton:SetSize(30, 25)
	self.CloseButton:SetPos(w - self.CloseButton:GetWide(), 0)
	self.CloseButton.Paint = function()
	end
	self.CloseButton.DoClick = function()
		self:Hide()
	end
	self.CloseButton.UpdateColours = function(panel, skin)
		if panel:IsHovered() then
			return panel:SetTextStyleColor(Color(220, 220, 220))
		else
			return panel:SetTextStyleColor(Color(255, 255, 255))
		end
	end

	self.Inputs = self:Add("DPanel")
	self.Inputs.Paint = function(_, w, h)
	end

	CreateLabeledInput(self, "YearLabel", "year", "Year")
	CreateLabeledInput(self, "MonthLabel", "month", "Month")
	CreateLabeledInput(self, "DayLabel", "day", "Day")
	CreateLabeledInput(self, "HourLabel", "hour", "Hour")

	self.Inputs:SetSize(InputW, self.YearLabel:GetTall() + self.year:GetTall() + 5)
	self.Inputs:SetPos(0, 40)
	self.Inputs:CenterHorizontal()

	self.ButtonsWrap = self:Add("DPanel")
	self.ButtonsWrap:SetPos(0, h - 45)
	self.ButtonsWrap.Paint = function()
	end

	self.OK = self.ButtonsWrap:Add("DButton")
	self.OK:SetSize(90, 25)
	self.OK:SetPos(0, 0)
	self.OK:SetFont("NStatistics_DateButton")
	self.OK:SetText(NSTATISTICS.GetPhrase("OK"))
	self.OK:SetTextColor(Color(255, 255, 255))
	self.OK.Paint = function(panel, w, h) -- 16690923
		if self.OK:IsHovered() then
			surface.SetDrawColor(89, 111, 255)
		else
			surface.SetDrawColor(65, 87, 255)
		end
		surface.DrawRect(0, 0, w, h)
	end
	self.OK.DoClick = function()
		if self.binded then
			local date = self:GetDate()

			self.binded:SetDate(date)
		end

		self:Hide()
		self.binded:OnSelect()
	end

	self.NotLimited = self.ButtonsWrap:Add("DButton")
	self.NotLimited:SetSize(90, 25)
	self.NotLimited:SetPos(100, 0)
	self.NotLimited:SetFont("NStatistics_DateButton")
	self.NotLimited:SetText(NSTATISTICS.GetPhrase("NotLimited"))
	self.NotLimited:SetTextColor(Color(255, 255, 255))
	self.NotLimited.Paint = function(panel, w, h)
		if self.NotLimited:IsHovered() then
			surface.SetDrawColor(89, 111, 255)
		else
			surface.SetDrawColor(65, 87, 255)
		end
		surface.DrawRect(0, 0, w, h)
	end
	self.NotLimited.DoClick = function()
		if self.binded then
			self.binded:SetDate(nil)
		end

		self:Hide()
	end

	self.ButtonsWrap:SetSize(
		self.OK:GetWide() + self.NotLimited:GetWide() + 10,
		math.max(self.OK:GetTall(), self.NotLimited:GetTall())
	)
	self.ButtonsWrap:CenterHorizontal()
end

function DATEPOPUP:Paint(w, h)
	surface.SetDrawColor(60, 60, 60)
	surface.DrawRect(0, 0, w, h)

	surface.SetFont("NStatistics_DatePanelTitle")
	surface.SetTextPos(10, 5)
	surface.SetTextColor(220, 220, 220)
	surface.DrawText(NSTATISTICS.GetPhrase("SelectDate"))
end

function DATEPOPUP:Bind(panel)
	InputW = -10
	self.binded = panel

	local date

	if panel.date then
		date = table.Copy(panel:GetDate())
	else
		date = NSTATISTICS.GetDateWithHours(os.time())
	end

	for k, v in pairs(date) do
		date[k] = tonumber(v)
	end

	self:SetDate(date)

	self:Show()
	self:MoveToFront()
end

local DaysInMonth = {
	31,
	0,
	31,
	30,
	31,
	30,
	31,
	31,
	30,
	31,
	30,
	31
}

function DATEPOPUP:CheckDate(date)
	local year = math.Clamp(date.year, 2016, 2100)
	local month = math.Clamp(date.month, 1, 12)
	local day = date.day
	local hour = math.Clamp(date.hour, 0, 23)

	local maxday = DaysInMonth[month]

	if maxday == 0 then
		if (year % 4 == 0 and year % 100 ~= 0) or year % 400 == 0 then
			maxday = 29
		else
			maxday = 28
		end
	end

	day = math.Clamp(day, 1, maxday)

	local time =
		os.time(
		{
			year = year,
			month = month,
			day = day,
			hour = hour
		}
	)

	local NewDate = NSTATISTICS.GetDateWithHours(time)

	return NewDate
end

function DATEPOPUP:GetDate()
	return {
		year = self.year:GetValue(),
		month = self.month:GetValue(),
		day = self.day:GetValue(),
		hour = self.hour:GetValue()
	}
end

function DATEPOPUP:SetDate(date)
	date = self:CheckDate(date)

	self.year:SetText(date.year)
	self.month:SetText(date.month)
	self.day:SetText(date.day)
	self.hour:SetText(date.hour)
end

vgui.Register("nstatistics_datepopup", DATEPOPUP, "EditablePanel")

local DATE = {}

function DATE:Init()
	self:SetWide(250)
end

function DATE:SetDate(date)
	self.date = date

	self.printdate = date and NSTATISTICS.GetDateFormat(date) or nil
end

function DATE:SetUNIXTime(time)
	self:SetDate(NSTATISTICS.GetDateWithHours(time))
end

function DATE:GetDate()
	return self.date
end

function DATE:GetUNIXTime()
	local date = self:GetDate()

	return date and os.time(date) or nil
end

function DATE:SetText(text)
	self.text = text
end

function DATE:Paint(w, h)
	if self:IsHovered() then
		surface.SetDrawColor(76, 141, 255)
	else
		surface.SetDrawColor(53, 118, 247)
	end
	surface.DrawRect(0, 0, w, h)

	if self.text then
		local date = self.printdate and self.printdate or NSTATISTICS.GetPhrase("NotLimited")
		draw.SimpleText(
			self.text .. "  " .. date,
			"NStatistics_DateButton",
			w / 2,
			h / 2,
			Color(255, 255, 255),
			TEXT_ALIGN_CENTER,
			TEXT_ALIGN_CENTER
		)
	end

	return true
end

function DATE:DoClick()
	if not IsValid(NSTATISTICS.DatePopup) then
		NSTATISTICS.DatePopup = vgui.Create("nstatistics_datepopup")
	end

	NSTATISTICS.DatePopup:Bind(self)
end

function DATE.OnSelect()
end

vgui.Register("nstatistics_date", DATE, "DButton")
