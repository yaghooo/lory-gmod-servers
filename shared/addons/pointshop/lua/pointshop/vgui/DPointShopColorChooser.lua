local PANEL = {}

function PANEL:Init()
    self.StartTime = CurTime()
    self:SetTitle("Escolher cor")
    self:SetSize(300, 300)
    self:SetBackgroundBlur(true)
    self:SetDrawOnTop(true)
    self.DColorMixer = vgui.Create("DColorMixer", self)
    --DColorMixer:DockMargin(0, 0, 0, 60)
    self.DColorMixer:Dock(FILL)
    local DButton = vgui.Create("DButton", self)
    DButton:DockMargin(0, 5, 0, 0)
    DButton:Dock(BOTTOM)
    DButton:SetText("")

    DButton.DoClick = function()
        self.OnChoose(self.DColorMixer:GetColor())
        self:Close()
    end

    function DButton:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(123, 227, 149))
        draw.RoundedBox(0, 1, 1, w - 2, h - 2, Color(77, 209, 110))
        draw.SimpleText("FEITO", "PS_CatName", w / 2, h / 2, ColorAlpha(color_white, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    self:Center()
    self:Show()
    self.btnMaxim.Paint = function() end
    self.btnMinim.Paint = function() end
    self.lblTitle:SetTextColor(color_white)
end

function PANEL:Paint(w, h)
    Derma_DrawBackgroundBlur(self, self.StartTime)
    draw.RoundedBox(0, 0, 0, w, h, Color(57, 61, 72))
    draw.RoundedBox(0, 1, 1, w - 2, h - 2, ColorAlpha(color_white, 10))
    draw.RoundedBox(0, 2, 2, w - 4, h - 4, Color(57, 61, 72))
end

function PANEL:SetColor(color)
    self.DColorMixer:SetColor(color or color_white)
end

function PANEL:OnChoose()
    --loot at me, i'm useless, but necessary
end

vgui.Register("DPointShopColorChooser", PANEL, "DFrame")