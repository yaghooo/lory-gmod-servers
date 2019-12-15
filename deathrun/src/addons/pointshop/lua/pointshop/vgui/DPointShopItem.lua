local PANEL = {}

local adminicon = Material("icon16/shield.png")
local equippedicon = Material("icon16/eye.png")
local groupicon = Material("icon16/group.png")

local canbuycolor = Color(42, 46, 47)
local cantbuycolor = Color(214, 139, 139, 5)
local ownedcolor = Color(139, 214, 143, 5)

function PANEL:Init()
    self.Info = ""
    self.InfoHeight = 14
end

function PANEL:DoClick()
    local client = LocalPlayer()

    local points = PS.Config.CalculateBuyPrice(client, self.Data)

    if not self.IsInventory and not client:PS_HasPoints(points) then
        notification.AddLegacy("Você não tem " .. PS.Config.PointsName .. " suficiente!", NOTIFY_GENERIC, 5)
    end

    local menu = DermaMenu(self)
    menu:AddOption(self.Data.Name)

    if self.Category.Inspectable then
        menu:AddSpacer()
        menu:AddOption(
            "Inspecionar",
            function()
                local unboxItem = vgui.Create("DPointshopUnboxItem")
                unboxItem:SetData(self.Data, nil, true)
            end
        )
        menu:AddSpacer()
    end

    if self.IsInventory then
        menu:AddSpacer()
        menu:AddOption(
            "Vender",
            function()
                Derma_Query(
                    "Tem certeza que quer vender " .. self.Data.Name .. "?",
                    "Vender item",
                    "Yes",
                    function()
                        client:PS_SellItem(self.Data.ID)
                    end,
                    "No",
                    function()
                    end
                )
            end
        )

        if PS.Config.CanPlayersGiveItems then
            menu:AddSpacer()
            menu:AddOption(
                "Enviar Presente",
                function()
                    local giveItemPanel = vgui.Create("DPointShopGiveItem")
                    giveItemPanel:SetData(self.Data)
                end
            )
        end
    elseif client:PS_HasPoints(points) then
        menu:AddSpacer()
        menu:AddOption(
            "Comprar",
            function()
                Derma_Query(
                    "Tem certeza que quer comprar " .. self.Data.Name .. "?",
                    "Comprar item",
                    "Yes",
                    function()
                        client:PS_BuyItem(self.Data.ID)
                    end,
                    "No",
                    function()
                    end
                )
            end
        )
    end

    if self.IsInventory and self.Data.CanPlayerEquip then
        menu:AddSpacer()

        if client:PS_HasItemEquipped(self.Data.ID) then
            menu:AddOption(
                self.Data.EquipLabel or "Desequipar",
                function()
                    client:PS_HolsterItem(self.Data.ID)
                end
            )
        else
            menu:AddOption(
                self.Data.EquipLabel or "Equipar",
                function()
                    client:PS_EquipItem(self.Data.ID)
                end
            )
        end

        if client:PS_HasItemEquipped(self.Data.ID) and (self.Data.Modify or self.Category.Modify) then
            menu:AddSpacer()
            menu:AddOption(
                "Modificar...",
                function()
                    local item = PS.Items[self.Data.ID]

                    if item.Modify then
                        item:Modify(client.PS_Items[self.Data.ID].Modifiers)
                    elseif self.Category.Modify then
                        self.Category:Modify(client.PS_Items[self.Data.ID].Modifiers, item)
                    end
                end
            )
        end
    end

    menu:Open()
end

function PANEL:SetData(data, category, isInventory)
    self.Data = data
    self.Info = data.Name
    self.Category = category
    self.IsInventory = isInventory

    if data.Model then
        local DModelPanel = vgui.Create("DModelPanel", self)
        DModelPanel:SetModel(data.Model, data.Skin or 0)
        DModelPanel:GetEntity():SetSkin(data.Skin or 0)
        DModelPanel:GetEntity():SetMaterial(data.PaintMaterial or nil)
        DModelPanel:Dock(FILL)

        local PrevMins, PrevMaxs = DModelPanel.Entity:GetRenderBounds()
        DModelPanel:SetCamPos(PrevMins:Distance(PrevMaxs) * Vector(0.5, 0.5, 0.5))
        DModelPanel:SetLookAt((PrevMaxs + PrevMins) / 2)

        function DModelPanel:LayoutEntity(ent)
            if self:GetParent().Hovered then
                ent:SetAngles(Angle(0, ent:GetAngles().y + 2, 0))
            end

            local ITEM = PS.Items[data.ID]

            ITEM:ModifyClientsideModel(LocalPlayer(), ent, Vector(), Angle())
        end

        function DModelPanel:DoClick()
            self:GetParent():DoClick()
        end

        function DModelPanel:OnCursorEntered()
            self:GetParent():OnCursorEntered()
        end

        function DModelPanel:OnCursorExited()
            self:GetParent():OnCursorExited()
        end

        local oldPaint = DModelPanel.Paint

        function DModelPanel:Paint(...)
            local x, y = self:LocalToScreen(0, 0)
            local w, h = self:GetSize()

            local sl, st, sr, sb = x, y, x + w, y + h

            local p = self
            while p:GetParent() do
                p = p:GetParent()
                local pl, pt = p:LocalToScreen(0, 0)
                local pr, pb = pl + p:GetWide(), pt + p:GetTall()
                sl = sl < pl and pl or sl
                st = st < pt and pt or st
                sr = sr > pr and pr or sr
                sb = sb > pb and pb or sb
            end

            render.SetScissorRect(sl, st, sr, sb, true)
            oldPaint(self, ...)
            render.SetScissorRect(0, 0, 0, 0, false)
        end
    else
        local DImageButton = vgui.Create("DImageButton", self)

        if data.ImgurImage then
            DImageButton:SetMaterial(PS.Materials["loading"])

            PS:GetImageMaterial(
                data.ImgurImage,
                function(material)
                    DImageButton:SetMaterial(material)
                end
            )
        elseif data.Material then
            DImageButton:SetMaterial(data.Material)
        end

        if data.Color then
            DImageButton:SetColor(data.Color)
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

    if self.Description then
        self:SetTooltip(data.Description)
    end
end

surface.CreateFont("PS_ItemName", {font = "calibri", size = 15})

function PANEL:PaintOver()
    local client = LocalPlayer()

    if self.Data.AdminOnly then
        surface.SetMaterial(adminicon)
        surface.SetDrawColor(color_white)
        surface.DrawTexturedRect(5, 5, 16, 16)
    end

    if client:PS_HasItemEquipped(self.Data.ID) and not self.Data.SupressEquip then
        surface.SetMaterial(equippedicon)
        surface.SetDrawColor(color_white)
        surface.DrawTexturedRect(self:GetWide() - 5 - 16, 5, 16, 16)
    end

    if self.Data.AllowedUserGroups and #self.Data.AllowedUserGroups > 0 then
        surface.SetMaterial(groupicon)
        surface.SetDrawColor(color_white)
        surface.DrawTexturedRect(5, self:GetTall() - self.InfoHeight - 5 - 16, 16, 16)
    end

    local points = PS.Config.CalculateBuyPrice(client, self.Data)

    surface.SetDrawColor(canbuycolor)
    surface.DrawRect(0, self:GetTall() - self.InfoHeight, self:GetWide(), self.InfoHeight)

    draw.SimpleText(
        self.Info,
        "PS_ItemName",
        self:GetWide() / 2,
        self:GetTall() - (self.InfoHeight / 2),
        color_white,
        TEXT_ALIGN_CENTER,
        TEXT_ALIGN_CENTER
    )

    if
        client.PS_Items and client.PS_Items[self.Data.ID] and client.PS_Items[self.Data.ID].Modifiers and
            client.PS_Items[self.Data.ID].Modifiers.color
     then
        surface.SetDrawColor(client.PS_Items[self.Data.ID].Modifiers.color)
        surface.DrawRect(self:GetWide() - 5 - 16, 26, 16, 16)
    end
end

function PANEL:OnCursorEntered()
    self.Hovered = true

    if self.IsInventory and LocalPlayer():PS_HasItem(self.Data.ID) then
        self.Info = "+" .. PS.Config.CalculateSellPrice(LocalPlayer(), self.Data)
    else
        self.Info = "-" .. PS.Config.CalculateBuyPrice(LocalPlayer(), self.Data)
    end

    PS:SetHoverItem(self.Data.ID)
end

function PANEL:OnCursorExited()
    self.Hovered = false
    self.Info = self.Data.Name

    PS:RemoveHoverItem()
end

vgui.Register("DPointShopItem", PANEL, "DPanel")
