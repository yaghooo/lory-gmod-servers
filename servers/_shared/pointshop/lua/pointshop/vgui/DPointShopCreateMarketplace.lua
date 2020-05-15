local PANEL = {}

function PANEL:Init()
    self:SetSize(400, 200)
    self:MakePopup()
    self:SetDrawOnTop(true)
    self:RenderPointsInput()
    self:RenderSubmitButton()
end

function PANEL:RenderPointsInput()
    local pointsLabel = vgui.Create("DLabel", self)
    pointsLabel:SetText(PS.Config.PointsName .. ":")
    pointsLabel:Dock(TOP)
    pointsLabel:DockMargin(self.ContainerPadding, 10, self.ContainerPadding, 4)
    pointsLabel:SizeToContents()
    self.PointsInput = vgui.Create("DNumberWang", self)
    self.PointsInput:SetTextColor(color_black)
    self.PointsInput:SetTall(24)
    self.PointsInput:DockMargin(self.ContainerPadding, 0, self.ContainerPadding, 4)
    self.PointsInput:Dock(TOP)
    self.PointsInput:SetKeyboardInputEnabled(true)

    self.PointsInput.OnValueChanged = function(s, value)
        self.SelectedValue = tonumber(value)
        self:Update()
    end
end

function PANEL:RenderSubmitButton()
    local submitContainer = vgui.Create("DPanel", self)
    submitContainer:SetPaintBackground(false)
    submitContainer:DockMargin(0, 0, self.ContainerPadding, self.ContainerPadding)
    submitContainer:Dock(BOTTOM)
    self.SubmitButton = vgui.Create("DButton", submitContainer)
    self.SubmitButton:SetText("")
    self.SubmitButton:SetDisabled(true)
    self.SubmitButton:Dock(RIGHT)
    self.SubmitButton:SetSize(100, self.SubmitButton:GetTall())

    self.SubmitButton.DoClick = function()
        print(":O")
    end

    function self.SubmitButton:Paint(w, h)
        local opc = self:GetDisabled() and 50 or 150
        draw.RoundedBox(0, 0, 0, w, h, ColorAlpha(THEME.Color.Success, opc))
        draw.RoundedBox(0, 1, 1, w - 2, h - 2, ColorAlpha(color_white, 10))
        draw.RoundedBox(0, 2, 2, w - 4, h - 4, ColorAlpha(THEME.Color.Success, opc))
        draw.SimpleText("Enviar", THEME.Font.Coolvetica20, w / 2, h / 2, ColorAlpha(color_white, opc), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

vgui.Register("DPointShopCreateMarketplace", PANEL, THEME.Component.Page)