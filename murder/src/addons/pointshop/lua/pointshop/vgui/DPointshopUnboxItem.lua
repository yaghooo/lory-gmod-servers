local PANEL = {}

function PANEL:Init()
    local panel_color = Color(30, 35, 39)

    self.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, panel_color)
        surface.SetDrawColor(color_black)
        surface.DrawOutlinedRect(0, 0, w, h)
    end
end

function PANEL:SetData(wonItem, hasItem, readonly)
    self:SetSize(300, readonly and 340 or 400)
    self:Center()
    self:SetVisible(true)
    self:MakePopup()
    self:SetDrawOnTop(true)

    if not readonly then
        local text = vgui.Create("DLabel", self)
        text:SetSize(280, 20)
        text:SetPos(10, 8)
        text:SetText("Você ganhou uma " .. wonItem.Name .. "!")
    end

    local category = PS:FindCategoryByName(wonItem.Category)
    local t = vgui.Create("DPanel", self)
    t:SetPos(10, readonly and 8 or 32)
    t:SetSize(280, 270)
    t.Color = category.Color or Color(0, 0, 200)

    function t:Paint(w, h)
        surface.SetDrawColor(self.Color)
        surface.DrawRect(0, 0, 280, 270)
        surface.SetDrawColor(color_white)
        surface.SetMaterial(PS.Materials["item_shadow"])
        surface.DrawTexturedRect(5, 5, 270, 260)
    end

    local DModelPanel = vgui.Create("DModelPanel", t)
    DModelPanel:SetSize(260, 260)
    DModelPanel:SetPos(0, 0)
    DModelPanel:SetFOV(60)
    DModelPanel:SetModel(wonItem.Model)
    DModelPanel:GetEntity():SetSkin(wonItem.Skin or 0)
    DModelPanel:GetEntity():SetMaterial(wonItem.PaintMaterial or nil)
    DModelPanel.Angles = Angle()

    function DModelPanel:DragMousePress()
        self.PressX, self.PressY = gui.MousePos()
        self.Pressed = true
    end

    function DModelPanel:DragMouseRelease()
        self.Pressed = false
    end

    function DModelPanel:LayoutEntity(ent)
        if self.Pressed then
            local mx = gui.MousePos()
            self.Angles = ent:GetAngles() - Angle(0, (self.PressX or mx) - mx, 0)
            self.PressX, self.PressY = gui.MousePos()
            ent:SetAngles(self.Angles)
        else
            ent:SetAngles(Angle(0, ent:GetAngles().y + 2, 0))
        end
    end

    local min, max = DModelPanel.Entity:GetRenderBounds()
    DModelPanel:SetCamPos(min:Distance(max) * Vector(0, 0, 0) + Vector(0, 25, 0))
    DModelPanel:SetLookAt((max + min) / 2 + Vector(0, -25, 0))

    if not readonly then
        local sell = vgui.Create("DButton", self)
        sell:SetText("")
        sell:SetPos(10, 270 + 20 + 20)
        sell:SetSize(280, 30)
        sell:SetDisabled(hasItem)

        sell.DoClick = function()
            LocalPlayer():PS_SellItem(wonItem.ID)
            self:SetVisible(false)
            self:Remove()
        end

        sell.SellText = "Vender: " .. PS.Config.CalculateSellPrice(LocalPlayer(), wonItem) .. " " .. PS.Config.PointsName

        function sell:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w, h, hasItem and Color(220, 220, 220) or Color(123, 227, 149))
            draw.RoundedBox(0, 1, 1, w - 2, h - 2, hasItem and Color(200, 200, 200) or Color(77, 209, 110))
            draw.SimpleText(hasItem and "Você já possui! Vendido automaticamente." or self.SellText, "PS_CatName", w / 2, h / 2, hasItem and Color(20, 20, 20, 180) or ColorAlpha(color_white, 180), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    local close = vgui.Create("DButton", self)
    close:SetText("")
    close:SetPos(10, 270 + 20 + (readonly and 0 or (20 + 30 + 20)))
    close:SetSize(280, 30)

    close.DoClick = function()
        self:SetVisible(false)
        self:Remove()
    end

    close.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(227, 123, 123))
        draw.RoundedBox(0, 1, 1, w - 2, h - 2, Color(209, 77, 77))
        draw.SimpleText("Fechar", "PS_CatName", w / 2, h / 2, ColorAlpha(color_white, 180), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

vgui.Register("DPointshopUnboxItem", PANEL)