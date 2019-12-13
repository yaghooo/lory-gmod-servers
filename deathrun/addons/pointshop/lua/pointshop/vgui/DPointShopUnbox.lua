local PANEL = {}

function PANEL:Init()
    self:SetDrawOnTop(true)
    self:SetSize(620, 142)
    self:SetBackgroundBlur(true)
    self:Center()
    self:SetVisible(true)
    self:MakePopup()

    self.TapePosition = 10
    self.ItemPanSize = 110
    self.TapePans = {}
    self.DefaultItemColor = Color(0, 0, 200)
    self.StartTime = CurTime()
    self.Time = 0
    self.PrevItemValue = 0
    self.TapeWillStopAt =
        (self.ItemPanSize * (PS.Config.CrateItemQuantity - 5) * -1) +
        (self.ItemPanSize - 30) * math.Truncate(math.random(), 4)

    self.Spinning = true
end

function PANEL:Paint(w, h)
    Derma_DrawBackgroundBlur(self, self.StartTime)
    draw.RoundedBox(0, 0, 0, w, h, Color(30, 35, 39))
    surface.SetDrawColor(color_black)
    surface.DrawOutlinedRect(0, 0, w, h)
end

function PANEL:SetData(items, hasItem)
    self.HasItem = hasItem

    local innerPanel = vgui.Create("DPanel", self)
    innerPanel:SetSize(600, 142)
    innerPanel:Center()
    innerPanel.Paint = self.Paint

    for k, v in pairs(items) do
        local item, isPoints

        if not string.StartWith(v, "points") then
            item = PS.Items[v]
            if k == PS.Config.CrateItemQuantity - 3 then
                self.WonItem = item
            end
        else
            local points = string.Split(v, ":")[2]
            item = {Name = points .. " Points"}
            isPoints = true
            if k == PS.Config.CrateItemQuantity - 3 then
                self.WonPoints = true
            end
        end

        local itemPanel = vgui.Create("DPanel", innerPanel)
        itemPanel:SetPos(self.ItemPanSize * k, 6)
        itemPanel:SetSize(100, 130)
        itemPanel.item = item
        itemPanel.color = not isPoints and PS:FindCategoryByName(item.Category).Color or self.DefaultItemColor
        function itemPanel:Paint(w, h)
            surface.SetDrawColor(color_white)
            surface.SetMaterial(PS.Materials["item_shadow"])
            surface.DrawTexturedRect(0, 0, 100, 100)

            surface.SetDrawColor(self.color)
            surface.DrawRect(0, 100, 100, 30)

            surface.SetDrawColor(color_black)
            surface.DrawOutlinedRect(0, 0, 100, 130)
            surface.DrawOutlinedRect(1, 1, 98, 128)
            surface.DrawOutlinedRect(0, 100, 100, 1)

            draw.SimpleText(self.item.Name, "DermaDefault", 5, 105, color_white, 0, 0)
        end

        if not isPoints then
            local itemModel = vgui.Create("DModelPanel", itemPanel)
            itemModel:SetSize(100, 100)
            itemModel:SetPos(0, 0)
            itemModel:SetModel(item.Model)
            itemModel:GetEntity():SetSkin(item.Skin or 0)
            itemModel:GetEntity():SetMaterial(item.PaintMaterial or nil)
            itemModel:SetAnimated(true)
            function itemModel:LayoutEntity(Entity)
                if self.bAnimated then
                    self:RunAnimation()
                end
            end

            local min, max = itemModel.Entity:GetRenderBounds()
            itemModel:SetCamPos(min:Distance(max) * Vector(0, 0.5, 0))
            itemModel:SetLookAt((max + min) / 2)
        else
            local pointImage = vgui.Create("DImage", itemPanel)
            pointImage:SetSize(100, 100)
            pointImage:SetPos(0, 0)
            pointImage:SetMaterial(PS.Materials["money"])
        end

        self.TapePans[k] = itemPanel
    end

    local marker = vgui.Create("DPanel", innerPanel)
    marker:SetSize(innerPanel:GetSize())
    marker.Paint = function(s, w, h)
        local posX, posY = innerPanel:GetPos()
        surface.SetDrawColor(255, 255, 0)
        surface.DrawRect(posX + w / 2, posY, 5, h)
    end
end

function PANEL:Think()
    if self.Spinning then
        local frameTime = RealFrameTime()

        self.Time = self.Time + frameTime
        self.TapePosition = Lerp(0.8 * frameTime, self.TapePosition, self.TapeWillStopAt)

        for i = 0, #self.TapePans do
            local v = self.TapePans[i]
            if IsValid(v) then
                v:SetPos(self.TapePosition + (self.ItemPanSize * i), 6)
            end
        end

        local curItemValue = math.floor((self.TapePosition + self.ItemPanSize) / self.ItemPanSize)
        if curItemValue ~= self.PrevItemValue then
            self.PrevItemValue = curItemValue

            if self.Time > 0.1 then
                LocalPlayer():EmitSound("pointshop/case_tick.wav")
                self.Time = 0
            end
        end

        if math.floor(self.TapePosition) <= self.TapeWillStopAt then
            self.Spinning = false

            if IsValid(self) then
                if self.WonItem or self.WonPoints then
                    LocalPlayer():EmitSound("pointshop/case_opened.wav")

                    if self.WonItem then
                        local unboxItem = vgui.Create("DPointshopUnboxItem")
                        unboxItem:SetData(self.WonItem, self.HasItem)
                    end
                end

                self:SetVisible(false)
                self:Remove()
            end
        end
    end
end

vgui.Register("DPointShopUnbox", PANEL, "DFrame")
