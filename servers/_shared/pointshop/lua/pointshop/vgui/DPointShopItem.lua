local ITEMMODEL = {}
local adminicon = Material("icon16/shield.png")
local equippedicon = Material("icon16/eye.png")
local groupicon = Material("icon16/group.png")
local titleColor = Color(40, 40, 40)

function ITEMMODEL:Init()
    self.Item = {}
    self.Info = ""
    self.InfoHeight = 14
end

function ITEMMODEL:SetItem(item, category, isInventory)
    self.Item = item
    self.Info = item.Name
    self.Category = category
    self.IsInventory = isInventory

    if item.Model then
        local model = vgui.Create("DModelPanel", self)
        model:SetModel(item.Model)
        model:GetEntity():SetSkin(item.Skin or 0)
        model:GetEntity():SetMaterial(item.PaintMaterial or nil)
        model:Dock(FILL)
        local prevMin, prevMax = model.Entity:GetRenderBounds()
        model:SetCamPos(prevMin:Distance(prevMax) * Vector(0.5, 0.5, 0.5))
        model:SetLookAt((prevMax + prevMin) / 2)

        function model:LayoutEntity(ent)
            if self:GetParent().Hovered then
                ent:SetAngles(Angle(0, ent:GetAngles().y + 2, 0))
            end

            local ITEM = PS.Items[item.ID]
            ITEM:ModifyClientsideModel(LocalPlayer(), ent, Vector(), Angle())
        end

        function model:DoClick()
            self:GetParent():DoClick()
        end

        function model:OnCursorEntered()
            self:GetParent():OnCursorEntered()
        end

        function model:OnCursorExited()
            self:GetParent():OnCursorExited()
        end
    else
        local DImageButton = vgui.Create("DImageButton", self)

        if item.ImgurImage then
            DImageButton:SetMaterial(PS.Materials["loading"])

            PS:GetImageMaterial(item.ImgurImage, function(material)
                DImageButton:SetMaterial(material)
            end)
        elseif item.Material then
            DImageButton:SetMaterial(item.Material)
        end

        if item.Color then
            DImageButton:SetColor(item.Color)
        end

        DImageButton:Dock(FILL)

        function DImageButton:DoClick()
            self:GetParent():DoClick()
        end

        function DImageButton:OnCursorEntered()
            self:GetParent():OnCursorEntered()
        end

        function DImageButton:OnCursorExited()
            self:GetParent():OnCursorExited()
        end
    end
end

function ITEMMODEL:Paint(w, h)
    draw.RoundedBox(0, 0, 0, w, h, THEME.Color.LightSecondary)
end

surface.CreateFont("PS_ItemName", {
    font = "calibri",
    size = 15
})

function ITEMMODEL:PaintOver()
    local client = LocalPlayer()

    if self.Item.AdminOnly then
        surface.SetMaterial(adminicon)
        surface.SetDrawColor(color_white)
        surface.DrawTexturedRect(5, 5, 16, 16)
    end

    if client:PS_HasItemEquipped(self.Item.ID) and not self.Item.SupressEquip then
        surface.SetMaterial(equippedicon)
        surface.SetDrawColor(color_white)
        surface.DrawTexturedRect(self:GetWide() - 5 - 16, 5, 16, 16)
    end

    if self.Item.AllowedUserGroups and #self.Item.AllowedUserGroups > 0 then
        surface.SetMaterial(groupicon)
        surface.SetDrawColor(color_white)
        surface.DrawTexturedRect(5, self:GetTall() - self.InfoHeight - 5 - 16, 16, 16)
    end

    surface.SetDrawColor(titleColor)
    surface.DrawRect(0, self:GetTall() - self.InfoHeight, self:GetWide(), self.InfoHeight)
    draw.SimpleText(self.Info, "PS_ItemName", self:GetWide() / 2, self:GetTall() - (self.InfoHeight / 2), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    if self.IsInventory and client.PS_Items[self.Item.ID] and client.PS_Items[self.Item.ID].Modifiers and client.PS_Items[self.Item.ID].Modifiers.color then
        surface.SetDrawColor(client.PS_Items[self.Item.ID].Modifiers.color)
        surface.DrawRect(self:GetWide() - 5 - 16, 26, 16, 16)
    end
end

function ITEMMODEL:OnCursorEntered()
    self.Hovered = true

    if self.IsInventory and LocalPlayer():PS_HasItem(self.Item.ID) then
        self.Info = "+" .. PS.Config.CalculateSellPrice(LocalPlayer(), self.Item)
    else
        self.Info = "-" .. PS.Config.CalculateBuyPrice(LocalPlayer(), self.Item)
    end
end

function ITEMMODEL:OnCursorExited()
    self.Hovered = false
    self.Info = self.Item.Name
end

vgui.Register("DPointShopItem", ITEMMODEL, "DPanel")