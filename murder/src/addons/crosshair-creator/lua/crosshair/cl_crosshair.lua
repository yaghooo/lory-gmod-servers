surface.CreateFont("MersRadialMedium", {
    font = "coolvetica",
    size = math.ceil(ScrW() / 50)
})

CH = {}
CH.SliderTextColor = Color(200, 200, 200)
CH.XHairThickness = CreateClientConVar("crosshair_thickness", 2, true, false)
CH.XHairGap = CreateClientConVar("crosshair_gap", 8, true, false)
CH.XHairSize = CreateClientConVar("crosshair_size", 8, true, false)
CH.XHairRed = CreateClientConVar("crosshair_red", 255, true, false)
CH.XHairGreen = CreateClientConVar("crosshair_green", 255, true, false)
CH.XHairBlue = CreateClientConVar("crosshair_blue", 255, true, false)
CH.XHairAlpha = CreateClientConVar("crosshair_alpha", 255, true, false)

function CH:OpenCrosshairCreator()
    local frame = vgui.Create("DFrame")
    frame:SetSize(640, 480)
    frame:Center()
    frame:MakePopup()
    frame:SetTitle("Crosshair Creator")
    frame.backgroundColor = Color(40, 40, 40)

    function frame:Paint()
        surface.SetDrawColor(self.backgroundColor)
        surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
    end

    local panel = vgui.Create("DPanel", frame)
    panel:SetSize(frame:GetWide() - 8, frame:GetTall() - 44)
    panel:SetPos(4, 32)
    panel.Paint = self.Empty

    local crosshair = vgui.Create("DPanel", panel)
    crosshair:SetSize(panel:GetWide() / 2 - 2, panel:GetTall())
    crosshair:SetPos(0, 0)

    crosshair.Paint = function(s, w, h)
        surface.SetDrawColor(0, 0, 0, 100)
        surface.DrawRect(0, 0, w, h)

        self:DrawCrosshair(w / 2, h / 2)
    end

    local controls = vgui.Create("DPanel", panel)
    controls:SetSize(panel:GetWide() / 2 - 2, panel:GetTall())
    controls:SetPos(panel:GetWide() - controls:GetWide(), 0)
    controls.color = Color(50, 50, 50)

    function controls:Paint(w, h)
        surface.SetDrawColor(self.color)
        surface.DrawRect(0, 0, w, h)
    end

    local scrollPanel = vgui.Create("DScrollPanel", controls)
    scrollPanel:SetSize(controls:GetWide() - 16, controls:GetTall() - 16)
    scrollPanel:SetPos(8, 8)
    local vbar = scrollPanel:GetVBar()
    vbar:SetWide(4)
    vbar.color = ColorAlpha(color_black, 100)

    function vbar:Paint(w, h)
        surface.SetDrawColor(self.color)
        surface.DrawRect(0, 0, w, h)
    end

    vbar.btnUp.Paint = self.Empty
    vbar.btnDown.Paint = self.Empty
    vbar.btnGrip.color = ColorAlpha(color_white, 200)

    function vbar.btnGrip:Paint(w, h)
        surface.SetDrawColor(self.color)
        surface.DrawRect(0, 0, w, h)
    end

    local list = vgui.Create("DIconLayout", scrollPanel)
    list:SetSize(scrollPanel:GetSize())
    list:SetPos(0, 0)
    list:SetSpaceX(0)
    list:SetSpaceY(4)
    self:AddHeaderToList(list, "Dimensões da crosshair")
    self:AddSliderConvarToList(list, "Espessura do traço", 0, 16, "crosshair_thickness")
    self:AddSliderConvarToList(list, "Abertura interna", 0, 32, "crosshair_gap")
    self:AddSliderConvarToList(list, "Tamanho do traço", 0, 32, "crosshair_size")
    self:AddHeaderToList(list, "Cores da crosshair")
    self:AddSliderConvarToList(list, "Vermelho", 0, 255, "crosshair_red")
    self:AddSliderConvarToList(list, "Verde", 0, 255, "crosshair_green")
    self:AddSliderConvarToList(list, "Azul", 0, 255, "crosshair_blue")
    self:AddSliderConvarToList(list, "Transparência", 0, 255, "crosshair_alpha")
end

function CH:AddSliderConvarToList(list, text, min, max, convar)
    local label = vgui.Create("DLabel")
    label:SetTextColor(self.SliderTextColor)
    label:SetText(text)
    label:SizeToContents()
    label:SetWide(list:GetWide())
    list:Add(label)
    local slider = vgui.Create("Slider")
    slider:SetMin(min)
    slider:SetMax(max)
    slider:SetWide(list:GetWide())
    slider:SetValue(GetConVar(convar):GetFloat())

    slider.OnValueChanged = function(s, value)
        RunConsoleCommand(convar, value)
        self:Update()
    end

    list:Add(slider)
end

function CH:AddHeaderToList(list, text)
    local space = vgui.Create("DPanel")
    space:SetWide(list:GetWide())
    space:SetTall(12)
    space.Paint = self.Empty
    list:Add(space)
    local label = vgui.Create("DLabel")
    label:SetFont("MersRadialMedium")
    label:SetTextColor(color_white)
    label:SetText(text)
    label:SizeToContents()
    label:SetWide(list:GetWide())
    list:Add(label)
end

function CH:Empty()
end

function CH:Update()
    self.XHairThicknessValue = self.XHairThickness:GetInt()
    self.XHairGapValue = self.XHairGap:GetInt()
    self.XHairSizeValue = self.XHairSize:GetInt()
    self.XHairRedValue = self.XHairRed:GetInt()
    self.XHairGreenValue = self.XHairGreen:GetInt()
    self.XHairBlueValue = self.XHairBlue:GetInt()
    self.XHairAlphaValue = self.XHairAlpha:GetInt()
    self.Updated = true
end

function CH:DrawCrosshair(x, y)
    x = x or ScrW() / 2
    y = y or ScrH() / 2

    if not self.Updated then
        self:Update()
    end

    surface.SetDrawColor(self.XHairRedValue, self.XHairGreenValue, self.XHairBlueValue, self.XHairAlphaValue)
    surface.DrawRect(x - (self.XHairThicknessValue / 2), y - (self.XHairSizeValue + self.XHairGapValue / 2), self.XHairThicknessValue, self.XHairSizeValue)
    surface.DrawRect(x - (self.XHairThicknessValue / 2), y + (self.XHairGapValue / 2), self.XHairThicknessValue, self.XHairSizeValue)
    surface.DrawRect(x + (self.XHairGapValue / 2), y - (self.XHairThicknessValue / 2), self.XHairSizeValue, self.XHairThicknessValue)
    surface.DrawRect(x - (self.XHairSizeValue + self.XHairGapValue / 2), y - (self.XHairThicknessValue / 2), self.XHairSizeValue, self.XHairThicknessValue)
end

hook.Add("HUDPaint", "DrawCustomCrosshair", function()
    local client = LocalPlayer()

    -- Is able to draw crosshair
    if IsValid(client) and client:Health() > 0 and not client:KeyDown(IN_ATTACK2) then
        CH:DrawCrosshair()
    end
end)

hook.Add("HUDShouldDraw", "HideHUD", function(name)
    -- Never return true here unless you have a reason
    if name == "CHudCrosshair" then return false end
end)

concommand.Add("open_crosshair_menu", function()
    CH:OpenCrosshairCreator()
end)