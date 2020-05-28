local PANEL = {}

function PANEL:Init()
end

function PANEL:SetData(wonItem, hasItem)
    self:SetSize(500, 600)
    self:MakePopup()
    local text = vgui.Create("DLabel", self)
    text:SetSize(280, 32)
    text:SetPos(self.ContainerPadding, 8)
    text:SetText("Você ganhou uma " .. wonItem.Name .. "!")
    local category = PS:FindCategoryByName(wonItem.Category)
    local itemContainer = vgui.Create("DPanel", self)
    itemContainer:SetPos(self.ContainerPadding, self.HeaderSize)
    itemContainer:SetSize(500 - self.ContainerPadding * 2, 500 - self.ContainerPadding * 2)
    itemContainer.Color = category.Color or Color(0, 0, 200)

    function itemContainer:Paint(w, h)
        surface.SetDrawColor(self.Color)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(color_white)
        surface.SetMaterial(PS.Materials["item_shadow"])
        surface.DrawTexturedRect(5, 5, w - 10, h - 10)
    end

    local itemModel = vgui.Create("DModelPanel", itemContainer)
    itemModel:SetSize(itemContainer:GetWide(), itemContainer:GetTall())
    itemModel:SetPos(0, 0)
    itemModel:SetFOV(60)
    itemModel:SetDirectionalLight(BOX_RIGHT, color_white)
    itemModel:SetDirectionalLight(BOX_LEFT, color_white)
    itemModel:SetAmbientLight(Vector())
    itemModel:SetModel(wonItem.Model)
    itemModel:GetEntity():SetSkin(wonItem.Skin or 0)
    itemModel:GetEntity():SetMaterial(wonItem.PaintMaterial or nil)
    itemModel.Angles = Angle()

    function itemModel:DragMousePress()
        self.PressX, self.PressY = gui.MousePos()
        self.Pressed = true
    end

    function itemModel:DragMouseRelease()
        self.Pressed = false
    end

    function itemModel:LayoutEntity(ent)
        if self.Pressed then
            local mx = gui.MousePos()
            self.Angles = ent:GetAngles() - Angle(0, (self.PressX or mx) - mx, 0)
            self.PressX, self.PressY = gui.MousePos()
            ent:SetAngles(self.Angles)
        else
            ent:SetAngles(Angle(0, ent:GetAngles().y + 2, 0))
        end
    end

    local min, max = itemModel.Entity:GetRenderBounds()
    itemModel:SetCamPos(min:Distance(max) * Vector() + Vector(0, 25, 0))
    itemModel:SetLookAt((max + min) / 2 + Vector(0, -25, 0))
    local sell = vgui.Create(THEME.Component.Button1, self)
    sell:SetSize(self:GetWide() - self.ContainerPadding * 2, 40)
    sell:SetPos(self.ContainerPadding, self:GetTall() - sell:GetTall() - self.ContainerPadding)
    sell:SetBackgroundColor(THEME.Color.Success)
    sell:SetDisabled(hasItem)

    if hasItem then
        sell:SetText("Você já possui! Vendido automaticamente.")
    else
        sell:SetText("Vender: " .. PS.Config.CalculateSellPrice(LocalPlayer(), wonItem) .. " " .. PS.Config.PointsName)
    end

    sell.DoClick = function()
        LocalPlayer():PS_SellItem(wonItem.ID)
        self:Close()
    end
end

vgui.Register("DPointshopUnboxItem", PANEL, THEME.Component.Page)