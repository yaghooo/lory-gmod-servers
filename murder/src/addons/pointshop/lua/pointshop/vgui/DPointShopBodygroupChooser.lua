local PANEL = {}

function PANEL:Init()
    self:SetTitle("Modificações")
    self.StartTime = CurTime()
    self.BodyGroup = {}
    self.Skin = 0
end

function PANEL:SetData(item, modifications)
    self:SetSize(540, 525)
    self:SetDeleteOnClose(true)
    self:SetBackgroundBlur(true)
    self:MakePopup(true)
    self:Center()
    local DModelPanel = vgui.Create("DModelPanel", self)
    DModelPanel:Dock(FILL)
    DModelPanel:SetFOV(36)
    DModelPanel:SetCamPos(Vector())
    DModelPanel:SetDirectionalLight(BOX_RIGHT, Color(255, 160, 80))
    DModelPanel:SetDirectionalLight(BOX_LEFT, Color(80, 160, 255))
    DModelPanel:SetAmbientLight(Vector(-64, -64, -64))
    DModelPanel:SetAnimated(true)
    DModelPanel.Angles = Angle()
    DModelPanel:SetLookAt(Vector(-100, 0, -22))
    util.PrecacheModel(item.Model)
    DModelPanel:SetModel(item.Model)
    DModelPanel.Entity:SetPos(Vector(-100, 0, -61))

    function DModelPanel:DragMousePress()
        self.PressX, self.PressY = gui.MousePos()
        self.Pressed = true
    end

    function DModelPanel:DragMouseRelease()
        self.Pressed = false
    end

    function DModelPanel:LayoutEntity(Entity)
        if self.bAnimated then
            self:RunAnimation()
        end

        if self.Pressed then
            local mx = gui.MousePos()
            self.Angles = self.Angles - Angle(0, (self.PressX or mx) - mx, 0)
            self.PressX, self.PressY = gui.MousePos()
        end

        Entity:SetAngles(self.Angles)
    end

    dx, dy = 185, 30
    local DPanel = vgui.Create("DPanel", self)
    DPanel:Dock(RIGHT)
    DPanel:SetSize(200, 0)
    DPanel:DockPadding(8, 8, 8, 8)

    function DPanel:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(77, 81, 92))
        draw.RoundedBox(0, 1, 1, w - 2, h - 2, ColorAlpha(color_white, 10))
        draw.RoundedBox(0, 2, 2, w - 4, h - 4, Color(77, 81, 92))
    end

    local DScrollPanel = vgui.Create("DScrollPanel", DPanel)
    DScrollPanel:Dock(FILL)
    local skinsQuantity = DModelPanel.Entity:SkinCount()

    if skinsQuantity > 1 then
        local DNumSliderSkin = vgui.Create("DNumSlider", DScrollPanel)
        DNumSliderSkin:Dock(TOP)
        DNumSliderSkin:SetText("Skin")
        DNumSliderSkin:SetDark(true)
        DNumSliderSkin:SetTall(50)
        DNumSliderSkin:SetDecimals(0)
        DNumSliderSkin:SetMax(skinsQuantity - 1)

        DNumSliderSkin.OnValueChanged = function(s, value)
            self.Skin = math.Round(value)
            DModelPanel.Entity:SetSkin(self.Skin)
        end

        DNumSliderSkin:SetValue(modifications.skin)
        DScrollPanel:AddItem(DNumSliderSkin)
    end

    for k = 0, DModelPanel.Entity:GetNumBodyGroups() do
        local bodyGroupQuantity = DModelPanel.Entity:GetBodygroupCount(k)

        if bodyGroupQuantity > 1 then
            local DNumSliderBodygroup = vgui.Create("DNumSlider", DScrollPanel)
            DNumSliderBodygroup:Dock(TOP)
            DNumSliderBodygroup:SetText(DModelPanel.Entity:GetBodygroupName(k))
            DNumSliderBodygroup:SetDark(true)
            DNumSliderBodygroup:SetTall(50)
            DNumSliderBodygroup:SetDecimals(0)
            DNumSliderBodygroup:SetMax(bodyGroupQuantity - 1)
            DModelPanel.Entity:SetBodygroup(k, modifications.group ~= nil and modifications.group[k] or 0)

            DNumSliderBodygroup.OnValueChanged = function(s, value)
                self.BodyGroup[k] = math.Round(value)
                DModelPanel.Entity:SetBodygroup(k, self.BodyGroup[k])
            end

            DNumSliderBodygroup:SetValue(modifications.group ~= nil and modifications.group[k] or 0)
            DScrollPanel:AddItem(DNumSliderBodygroup)
        end
    end

    local DButton = vgui.Create("DButton")
    DButton:SetParent(DScrollPanel)
    DButton:SetText("")
    DButton:Dock(TOP)
    DButton:SetSize(40, 20)

    DButton.DoClick = function()
        self.OnChoose(self.BodyGroup, self.Skin)
        self:Close()
    end

    function DButton:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(123, 227, 149))
        draw.RoundedBox(0, 1, 1, w - 2, h - 2, Color(77, 209, 110))
        draw.SimpleText("Aplicar", "PS_CatName", w / 2, h / 2, ColorAlpha(color_white, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    DScrollPanel:AddItem(DButton)
end

function PANEL:Paint(w, h)
    Derma_DrawBackgroundBlur(self, self.StartTime)
    draw.RoundedBox(0, 0, 0, w, h, Color(57, 61, 72))
    draw.RoundedBox(0, 1, 1, w - 2, h - 2, ColorAlpha(color_white, 10))
    draw.RoundedBox(0, 2, 2, w - 4, h - 4, Color(57, 61, 72))
end

function PANEL:OnChoose()
    --loot at me, i'm useless, but necessary
end

vgui.Register("DPointShopBodygroupChooser", PANEL, "DFrame")