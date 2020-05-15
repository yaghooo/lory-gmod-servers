local BODYGROUP = {}

function BODYGROUP:Init()
    self.BodyGroup = {}
    self.Skin = 0
end

function BODYGROUP:SetData(item, modifications)
    self:SetSize(540, 525)
    self:MakePopup()
    local model = vgui.Create("DModelPanel", self)
    model:SetSize(self:GetWide() - 250, self:GetTall())
    model:SetFOV(30)
    model:SetCamPos(Vector())
    model:SetDirectionalLight(BOX_RIGHT, Color(255, 160, 80))
    model:SetDirectionalLight(BOX_LEFT, Color(80, 160, 255))
    model:SetAmbientLight(Vector(-64, -64, -64))
    model:SetAnimated(true)
    model.Angles = Angle()
    model:SetLookAt(Vector(-100, 0, -22))
    model:SetModel(item.Model)
    model.Entity:SetPos(Vector(-100, 0, -61))

    function model:DragMousePress()
        self.PressX, self.PressY = gui.MousePos()
        self.Pressed = true
    end

    function model:DragMouseRelease()
        self.Pressed = false
    end

    function model:LayoutEntity(Entity)
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

    local bodyGroupsContainer = vgui.Create(THEME.Component.Scroll, self)
    bodyGroupsContainer:SetSize(self:GetWide() - model:GetWide() - 20, self:GetTall() - self.HeaderSize - 20)
    bodyGroupsContainer:SetPos(self:GetWide() - (self:GetWide() - model:GetWide()), self.HeaderSize)

    local function addChooser(text, max)
        local chooser = vgui.Create("DNumSlider", bodyGroupsContainer)
        chooser:GetTextArea():SetTextColor(color_white)
        chooser:Dock(TOP)
        chooser:SetText(text)
        chooser:SetTall(50)
        chooser:SetDecimals(0)
        chooser:SetMax(max)
        chooser.BodyGroup = self
        bodyGroupsContainer:AddItem(chooser)

        return chooser
    end

    local skinsQuantity = model.Entity:SkinCount()

    if skinsQuantity > 1 then
        local chooser = addChooser("Skin", skinsQuantity - 1)

        chooser.OnValueChanged = function(s, value)
            self.Skin = math.Round(value)
            model.Entity:SetSkin(self.Skin)
        end

        chooser:SetValue(modifications.skin or 0)
    end

    for k = 0, model.Entity:GetNumBodyGroups() do
        local bodyGroupQuantity = model.Entity:GetBodygroupCount(k)

        if bodyGroupQuantity > 1 then
            local chooser = addChooser(model.Entity:GetBodygroupName(k), bodyGroupQuantity - 1)

            chooser.OnValueChanged = function(s, value)
                self.BodyGroup[k] = math.Round(value)
                model.Entity:SetBodygroup(k, self.BodyGroup[k])
            end

            model.Entity:SetBodygroup(k, modifications and modifications.group ~= nil and modifications.group[k] or 0)
            chooser:SetValue(modifications and modifications.group ~= nil and modifications.group[k] or 0)
        end
    end
end

function BODYGROUP:OnClose()
    self.OnChoose(self.BodyGroup, self.Skin)
end

function BODYGROUP:OnChoose()
    --loot at me, i'm useless, but necessary
end

vgui.Register("DPointShopBodygroupChooser", BODYGROUP, THEME.Component.Page)