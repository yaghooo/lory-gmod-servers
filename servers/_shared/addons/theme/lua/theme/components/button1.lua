THEME.Component.Button1 = "LoryButton1"

local button1 = {}
button1.OutLineSize = 1

function button1:Init()
    self:SetTextColor(color_white)
    self:SetBackgroundColor(THEME.Color.Primary)
    self:SetFont(THEME.Font.Coolvetica20)
end

function button1:SetBackgroundColor(color)
    self.BackgroundColor = color
end

function button1:Paint(w, h)
    local color = self:IsEnabled() and self.BackgroundColor or ColorAlpha(self.BackgroundColor, 25)
    surface.SetDrawColor(color)
    surface.DrawRect(0, 0, w, h)
end

vgui.Register(THEME.Component.Button1, button1, "DButton")