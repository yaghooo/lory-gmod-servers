THEME.Component.Button2 = "LoryButton2"

local button2 = {}
button2.OutLineSize = 1

function button2:Init()
    self:SetTextColor(color_white)
    self:SetFont(THEME.Font.Coolvetica18)
end

function button2:Paint(w, h)
    surface.SetDrawColor(ColorAlpha(color_white, 12))
    surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(THEME.Color.LightSecondary)
    surface.DrawRect(self.OutLineSize, self.OutLineSize, w - self.OutLineSize * 2, h - self.OutLineSize * 2)
end

vgui.Register(THEME.Component.Button2, button2, "DButton")