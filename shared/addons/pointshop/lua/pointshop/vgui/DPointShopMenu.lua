local GrayColorTop = Color(40, 40, 40)
local GrayColorBottom = Color(50, 50, 50)
local ColorTheme = Color(255, 68, 80)
local PointshopWidth = 1120

surface.CreateFont("PS_Heading", {
    font = "coolvetica",
    size = 35
})

surface.CreateFont("PS_Heading2", {
    font = "coolvetica",
    size = 16
})

surface.CreateFont("PS_Heading3", {
    font = "coolvetica",
    size = 19
})

surface.CreateFont("PS_PlayerName", {
    font = "calibri",
    size = 19
})

surface.CreateFont("PS_SmallerText", {
    font = "calibri",
    size = 16
})

surface.CreateFont("PS_CatName", {
    font = "calibri",
    size = 15
})

local ALL_ITEMS = 1
local OWNED_ITEMS = 2
local UNOWNED_ITEMS = 3
local SHOP_STORE = 1
local SHOP_INVENTORY = 2
local SHOP_ADMIN = 3
local grad_up = surface.GetTextureID("vgui/gradient_up")
local grad_dw = surface.GetTextureID("vgui/gradient_down")
PANEL_HELPER = {}

function PANEL_HELPER:Init()
    self.CAN_ACCESS_ADMIN_TAB = (PS.Config.AdminCanAccessAdminTab and LocalPlayer():IsAdmin()) or (PS.Config.SuperAdminCanAccessAdminTab and LocalPlayer():IsSuperAdmin())
    self.SHOP_TABS = {"SHOP", "INVENTÁRIO"}

    if self.CAN_ACCESS_ADMIN_TAB then
        table.insert(self.SHOP_TABS, "ADMIN")
    end
end

function PANEL_HELPER:BuildItemMenu(menu, ply, itemstype, callback)
    local plyitems = ply:PS_GetItems()

    for category_id, CATEGORY in SortedPairsByMemberValue(PS.Categories, "Order") do
        local catmenu = menu:AddSubMenu(CATEGORY.Name)

        for item_id, ITEM in SortedPairsByMemberValue(PS.Items, PS.Config.SortItemsBy) do
            if ITEM.Category == CATEGORY.Name and (itemstype == ALL_ITEMS or (itemstype == OWNED_ITEMS and plyitems[item_id]) or (itemstype == UNOWNED_ITEMS and not plyitems[item_id])) then
                catmenu:AddOption(ITEM.Name, function()
                    callback(item_id)
                end)
            end
        end
    end
end

function PANEL_HELPER:ShopGetCategoryOwnedCount(panel, cat)
    local userItems = panel.UserItems

    for _, item in pairs(PS.Items) do
        if item.Category == cat.Name and userItems[_] then return true end
    end

    return false
end

function PANEL_HELPER:RemoveElemList(panel)
    if IsValid(panel.SideScroll) then
        panel.SideScroll:Remove()
    end

    if IsValid(panel.Scroll) then
        panel.Scroll:Remove()
    end
end

function PANEL_HELPER:CreateAdminMenu(panel)
    panel.Scroll = vgui.Create("DScrollPanel", panel)
    panel.Scroll:SetSize(panel:GetWide() - 260 - 210, panel:GetTall() - 210)
    panel.Scroll:SetPos(255, 105)

    panel.Scroll.VBar.Paint = function(s, w, h)
        draw.RoundedBox(4, 3, 13, 8, h - 24, ColorAlpha(color_black, 70))
    end

    panel.Scroll.VBar.btnUp.Paint = function(s, w, h) end
    panel.Scroll.VBar.btnDown.Paint = function(s, w, h) end

    panel.Scroll.VBar.btnGrip.Paint = function(s, w, h)
        draw.RoundedBox(4, 5, 0, 4, h + 22, ColorAlpha(color_black, 70))
    end

    panel.ClientsList = vgui.Create("DListView", panel.Scroll)
    panel.ClientsList:SetSize(panel:GetWide() - 260 - 210, panel:GetTall() - 210)

    local tableHeaders = function(s, w, h)
        draw.RoundedBox(0, 1, 1, w - 2, h - 2, Color(57, 61, 72))
        draw.RoundedBox(0, 2, 2, w - 4, h - 4, ColorAlpha(color_white, 10))
    end

    panel.ClientsList:SetMultiSelect(false)
    local firstHeader = panel.ClientsList:AddColumn("Nome")
    local secondHeader = panel.ClientsList:AddColumn("Pontos")
    local thirdHeader = panel.ClientsList:AddColumn("Itens")
    secondHeader:SetFixedWidth(60)
    thirdHeader:SetFixedWidth(60)
    firstHeader.Header.Paint = tableHeaders
    secondHeader.Header.Paint = tableHeaders
    thirdHeader.Header.Paint = tableHeaders
    firstHeader.Header:SetTextColor(color_white)
    secondHeader.Header:SetTextColor(color_white)
    thirdHeader.Header:SetTextColor(color_white)
    panel.ClientsList.Paint = function(ss, w, h) end

    panel.ClientsList.OnClickLine = function(parent, line, selected)
        local ply = line.Player
        local menu = DermaMenu()

        menu:AddOption("Definir " .. PS.Config.PointsName .. "...", function()
            Derma_StringRequest("Definir " .. PS.Config.PointsName .. " para " .. ply:GetName(), "Definir " .. PS.Config.PointsName .. " para...", "", function(str)
                if not str or not tonumber(str) then return end
                net.Start("PS_SetPoints")
                net.WriteEntity(ply)
                net.WriteInt(tonumber(str), 32)
                net.SendToServer()
            end)
        end)

        menu:AddOption("Dar " .. PS.Config.PointsName .. "...", function()
            Derma_StringRequest("Dar " .. PS.Config.PointsName .. " para " .. ply:GetName(), "Dar " .. PS.Config.PointsName .. "...", "", function(str)
                if not str or not tonumber(str) then return end
                net.Start("PS_GivePoints")
                net.WriteEntity(ply)
                net.WriteInt(tonumber(str), 32)
                net.SendToServer()
            end)
        end)

        menu:AddOption("Tirar " .. PS.Config.PointsName .. "...", function()
            Derma_StringRequest("Tirar " .. PS.Config.PointsName .. " de " .. ply:GetName(), "Tirar " .. PS.Config.PointsName .. "...", "", function(str)
                if not str or not tonumber(str) then return end
                net.Start("PS_TakePoints")
                net.WriteEntity(ply)
                net.WriteInt(tonumber(str), 32)
                net.SendToServer()
            end)
        end)

        menu:AddSpacer()

        self:BuildItemMenu(menu:AddSubMenu("Dar item"), ply, UNOWNED_ITEMS, function(item_id)
            net.Start("PS_GiveItem")
            net.WriteEntity(ply)
            net.WriteString(item_id)
            net.SendToServer()
        end)

        self:BuildItemMenu(menu:AddSubMenu("Tirar item"), ply, OWNED_ITEMS, function(item_id)
            net.Start("PS_TakeItem")
            net.WriteEntity(ply)
            net.WriteString(item_id)
            net.SendToServer()
        end)

        menu:Open()
    end

    panel.Scroll:AddItem(panel.ClientsList)
end

function PANEL_HELPER:CreateItemList(panel, inv)
    local CATEGORY = PS.Categories[panel.CurrentCat]

    if CATEGORY then
        panel.Scroll = vgui.Create("DScrollPanel", panel)
        panel.Scroll:SetSize(panel:GetWide() - 460, panel:GetTall() - 110)
        panel.Scroll:SetPos(255, 105)

        panel.Scroll.VBar.Paint = function(s, w, h)
            draw.RoundedBox(4, 3, 13, 8, h - 24, ColorAlpha(color_black, 60))
        end

        panel.Scroll.VBar.btnUp.Paint = function(s, w, h) end
        panel.Scroll.VBar.btnDown.Paint = function(s, w, h) end

        panel.Scroll.VBar.btnGrip.Paint = function(s, w, h)
            draw.RoundedBox(4, 5, 0, 4, h + 22, ColorAlpha(color_black, 100))
        end

        local _c = math.floor((panel:GetWide() - 455) / 92)
        panel.Grid = vgui.Create("DGrid", panel)
        panel.Grid:SetPos(0, 0)
        panel.Grid:SetCols(_c)
        panel.Grid:SetColWide(92)
        panel.Grid:SetRowHeight(92)
        panel.Scroll:AddItem(panel.Grid)
        local client = LocalPlayer()

        local addItem = function(item, category)
            local model = vgui.Create("DPointShopItem", panel.Grid)
            model:SetData(item, category, inv)
            model:SetSize(90, 90)
            model.OldMultipleQuantity = inv and category.CanHaveMultiples and #panel.UserItems[item.ID]

            model.Paint = function(s, w, h)
                draw.RoundedBox(0, 0, 0, w, h, GrayColorBottom)
            end

            model.Think = function(s)
                local hasItem = client:PS_HasItem(s.Data.ID)

                if IsValid(model) and ((not inv and hasItem and not s.Category.CanHaveMultiples) or (inv and not hasItem) or (inv and s.Category.CanHaveMultiples and (s.OldMultipleQuantity ~= #client:PS_GetItems()[item.ID]))) then
                    PANEL_HELPER:SetShopTab(panel)
                end
            end

            panel.Grid:AddItem(model)
        end

        for k, item in SortedPairsByMemberValue(PS.Items, PS.Config.SortItemsBy) do
            if item.Category == CATEGORY.Name and (CATEGORY.CanHaveMultiples or ((inv and panel.UserItems[k]) or (not inv and not panel.UserItems[k]))) then
                if inv and CATEGORY.CanHaveMultiples and panel.UserItems[k] then
                    for i = 1, #panel.UserItems[k] do
                        addItem(item, CATEGORY)
                    end
                elseif not inv or not CATEGORY.CanHaveMultiples then
                    addItem(item, CATEGORY)
                end
            end
        end
    end
end

function PANEL_HELPER:CreateShopSideBar(panel, inv, admin)
    panel.SideScroll = vgui.Create("DScrollPanel", panel)
    panel.SideScroll:SetSize(250, panel:GetTall() - 150)
    panel.SideScroll:SetPos(0, 150)

    panel.SideScroll.VBar.Paint = function(s, w, h)
        draw.RoundedBox(4, 3, 13, 8, h - 24, ColorAlpha(color_black, 70))
    end

    panel.SideScroll.VBar.btnUp.Paint = function(s, w, h) end
    panel.SideScroll.VBar.btnDown.Paint = function(s, w, h) end

    panel.SideScroll.VBar.btnGrip.Paint = function(s, w, h)
        draw.RoundedBox(4, 5, 0, 4, h + 22, ColorAlpha(color_black, 70))
    end

    if admin then
        local btn = vgui.Create("DButton", panel.SideScroll)
        btn:SetPos(0, 0)
        btn:SetSize(250, 50)
        btn:SetText("")

        btn.Paint = function(s, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(52, 56, 67, 50))
            surface.SetDrawColor(0, 0, 0, 70)
            surface.SetTexture(grad_dw)
            surface.DrawTexturedRect(0, 0, w, h / 5)
            surface.SetDrawColor(0, 0, 0, 70)
            surface.SetTexture(grad_up)
            surface.DrawTexturedRect(0, h - h / 5, w, h / 5)
            draw.SimpleText("Players", "PS_CatName", 29, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.RoundedBox(0, 0, 0, w, 1, Color(64, 68, 80))
            draw.RoundedBox(0, 0, h - 1, w, 1, Color(64, 68, 80))
        end
    else
        local i = 0

        for k, cat in SortedPairsByMemberValue(PS.Categories, "Order") do
            if not ((inv and not self:ShopGetCategoryOwnedCount(panel, cat)) or (cat.CanPlayerSee and not cat:CanPlayerSee(LocalPlayer()))) then
                local btn = vgui.Create("DButton", panel.SideScroll)
                btn:SetPos(0, i * 49)
                btn:SetSize(250, 50)
                btn:SetText("")

                btn.OnCursorEntered = function(s)
                    s.hovering = true
                end

                btn.OnCursorExited = function(s)
                    s.hovering = false
                end

                btn.Paint = function(s, w, h)
                    if k == panel.CurrentCat then
                        draw.RoundedBox(0, 0, 0, w, h, ColorAlpha(ColorTheme, 10))
                        surface.SetDrawColor(0, 0, 0, 70)
                        surface.SetTexture(grad_dw)
                        surface.DrawTexturedRect(0, 0, w, h / 5)
                        surface.SetDrawColor(0, 0, 0, 70)
                        surface.SetTexture(grad_up)
                        surface.DrawTexturedRect(0, h - h / 5, w, h / 5)
                    elseif s.hovering then
                        draw.RoundedBox(0, 0, 0, w, h, ColorAlpha(ColorTheme, 20))
                        surface.SetDrawColor(0, 0, 0, 30)
                        surface.SetTexture(grad_dw)
                        surface.DrawTexturedRect(0, 0, w, h / 5)
                        surface.SetDrawColor(0, 0, 0, 30)
                        surface.SetTexture(grad_up)
                        surface.DrawTexturedRect(0, h - h / 5, w, h / 5)
                    else
                        draw.RoundedBox(0, 0, 0, w, h, GrayColorTop)
                    end

                    surface.SetDrawColor(color_white)
                    surface.SetMaterial(Material("icon16/" .. cat.Icon .. ".png"))
                    surface.DrawTexturedRect(10, h / 2 - 8, 16, 16)
                    draw.SimpleText(string.upper(cat.Name), "PS_CatName", 32, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    draw.RoundedBox(0, 0, 0, w, 1, ColorAlpha(color_white, 5))
                    draw.RoundedBox(0, 0, h - 1, w, 1, ColorAlpha(color_white, 5))
                end

                btn.DoClick = function()
                    if panel.CurrentCat ~= k then
                        panel.CurrentCat = k
                        PANEL_HELPER:SetShopTab(panel)
                    end
                end

                i = i + 1
            end
        end
    end
end

function PANEL_HELPER:SetShopTab(panel)
    panel.UserItems = LocalPlayer():PS_GetItems()
    self:RemoveElemList(panel)

    if panel.ShopPage == SHOP_STORE then
        self:CreateShopSideBar(panel)
        self:CreateItemList(panel)
    elseif panel.ShopPage == SHOP_INVENTORY then
        self:CreateShopSideBar(panel, true)
        self:CreateItemList(panel, true)
    elseif panel.ShopPage == SHOP_ADMIN and self.CAN_ACCESS_ADMIN_TAB then
        self:CreateShopSideBar(panel, true, true)
        self:CreateAdminMenu(panel)
    end
end

local PANEL = {}

function PANEL:Init()
    PANEL_HELPER:Init()
    PS:RemoveHoverItem()
    local client = LocalPlayer()
    local w, h = ScrW(), ScrH()
    self:SetSize(math.min(PointshopWidth, w), math.min(720, h))
    self:SetPos((w / 2) - (self:GetWide() / 2), (h / 2) - (self:GetTall() / 2))
    self.ShopPage = self.ShopPage or SHOP_STORE
    self.CurrentAdmin = self.CurrentAdmin or 1
    self.SelectedPlayer = self.SelectedPlayer or 1
    local ava = vgui.Create("AvatarImage", self)
    ava:SetPlayer(client, 64)
    ava:SetSize(64, 64)
    ava:SetPos(23, 50 - 32)
    local name = vgui.Create("DLabel", self)
    name:SetText(client:Nick())
    name:SetPos(23 + 64 + 6, (50 - 32) + 5)
    name:SetSize(150, 20)
    name:SetFont("PS_PlayerName")
    name:SetTextColor(color_white)
    local point = vgui.Create("DLabel", self)
    point:SetText(string.Comma(client:PS_GetPoints()) .. " " .. PS.Config.PointsName)
    point:SetPos(23 + 64 + 6, 50 - 12)
    point:SetSize(150, 20)
    point:SetFont("PS_SmallerText")
    point:SetTextColor(ColorAlpha(color_white, 50))

    point.Think = function()
        point:SetText(string.Comma(client:PS_GetPoints()) .. " " .. PS.Config.PointsName)
    end

    local steamid = vgui.Create("DLabel", self)
    steamid:SetText(client:SteamID())
    steamid:SetPos(23 + 64 + 6, 50 + 3)
    steamid:SetSize(150, 20)
    steamid:SetFont("PS_SmallerText")
    steamid:SetTextColor(ColorAlpha(color_white, 50))
    local close = vgui.Create("DButton", self)
    close:SetPos(self:GetWide() - 70, -5)
    close:SetSize(60, 25)
    close:SetText("")

    close.Paint = function(s, cw, ch)
        draw.RoundedBox(0, 0, 0, cw, ch, GrayColorBottom)
        draw.RoundedBox(0, 1, 1, cw - 2, ch - 2, ColorAlpha(color_white, 10))
        draw.RoundedBox(0, 2, 2, cw - 4, ch - 4, GrayColorBottom)
        draw.SimpleText("FECHAR", "PS_CatName", cw / 2, ch / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    close.DoClick = function()
        PS:ToggleMenu()
    end

    for i, tab in pairs(PANEL_HELPER.SHOP_TABS) do
        local btn = vgui.Create("DButton", self)
        btn:SetPos(250 + (self:GetWide() - 250) / #PANEL_HELPER.SHOP_TABS * (i - 1), 60)
        btn:SetSize((self:GetWide() - 250) / #PANEL_HELPER.SHOP_TABS, 40)
        btn:SetText("")

        btn.Paint = function(s, bw, bh)
            draw.SimpleText(string.upper(tab), "PS_CatName", bw / 2, bh / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            if i == self.ShopPage then
                surface.SetFont("PS_CatName")
                local _w, _h = surface.GetTextSize(string.upper(tab))
                draw.RoundedBox(0, (bw / 2 - _w / 2) - 1, bh / 2 + _h / 2, _w, 1, color_white)
            end
        end

        btn.DoClick = function()
            if self.ShopPage ~= i then
                self.ShopPage = i
                PANEL_HELPER:SetShopTab(self)
            end
        end
    end

    local preview = vgui.Create("DPointShopPreview", self)
    preview:SetSize(200, 340)
    preview:SetPos(self:GetWide() - 205, 105)
    local oldpaint = preview.Paint

    preview.Paint = function(s, pw, ph)
        draw.RoundedBox(0, 0, 0, pw, ph, GrayColorBottom)
        oldpaint(s, pw, ph)
    end

    function preview:DragMousePress()
        self.PressX, self.PressY = gui.MousePos()
        self.Pressed = true
    end

    function preview:DragMouseRelease()
        self.Pressed = false
        self.lastPressed = RealTime()
    end

    preview.Angles = Angle()

    function preview:LayoutEntity(thisEntity)
        if self.bAnimated then
            self:RunAnimation()
        end

        if self.Pressed then
            local mx = gui.MousePos()
            self.Angles = self.Angles - Angle(0, (self.PressX or mx) - mx, 0)
            self.PressX, self.PressY = gui.MousePos()
        end

        if (RealTime() - (self.lastPressed or 0)) < 4 or self.Pressed then
            thisEntity:SetAngles(self.Angles)
        else
            self.Angles.y = math.NormalizeAngle(self.Angles.y + (RealFrameTime() * 21))
            thisEntity:SetAngles(Angle(0, self.Angles.y, 0))
        end
    end

    if PS.Config.CanPlayersGivePoints then
        local giveButton = vgui.Create("DButton", self)
        giveButton:SetText("")
        giveButton:SetSize(200, 20)
        giveButton:SetPos(self:GetWide() - 205, 105 + 345)

        giveButton.Paint = function(s, gw, gh)
            draw.RoundedBox(0, 0, 0, gw, gh, GrayColorTop)
            draw.SimpleText("Dar " .. PS.Config.PointsName, "PS_CatName", gw / 2, gh / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        giveButton.DoClick = function()
            vgui.Create("DPointShopGivePoints")
        end
    end

    PANEL_HELPER:SetShopTab(self)
end

function PANEL:Think()
    if self.ShopPage == SHOP_ADMIN and IsValid(self.ClientsList) then
        local lines = self.ClientsList:GetLines()

        for _, ply in pairs(player.GetAll()) do
            local found = false

            for _, line in pairs(lines) do
                if line.Player == ply then
                    found = true
                    break
                end
            end

            if not found then
                self.ClientsList:AddLine(ply:GetName(), ply:PS_GetPoints(), table.Count(ply:PS_GetItems())).Player = ply
            end
        end

        for i, line in pairs(lines) do
            if IsValid(line.Player) then
                local ply = line.Player
                line:SetValue(1, ply:GetName())
                line:SetValue(2, ply:PS_GetPoints())
                line:SetValue(3, table.Count(ply:PS_GetItems()))
            else
                self.ClientsList:RemoveLine(i)
            end
        end
    end
end

function PANEL:Paint(w, h)
    draw.RoundedBox(0, 0, 0, w, h, color_white)
    draw.RoundedBox(0, 0, 0, 250, h, GrayColorBottom)
    draw.RoundedBox(0, 0, 0, 250, 100, GrayColorTop)
    draw.RoundedBox(0, 0, 99, 250, 1, ColorTheme)
    -- Gray bar
    draw.RoundedBox(0, 250, 0, w - 250, 60, GrayColorTop)
    draw.RoundedBox(0, 250, 60, w - 250, 40, GrayColorBottom)
    surface.SetFont("PS_Heading")
    local _w, _h = surface.GetTextSize(PS.Config.CommunityName)
    draw.SimpleText(PS.Config.CommunityName, "PS_Heading", 250 + ((w - 250) / 2 - _w), 12, ColorTheme)
    local title = ""

    if self.ShopPage == SHOP_STORE then
        title = "LOJA DO JOGADOR"
    elseif self.ShopPage == SHOP_ADMIN then
        title = "ADMINISTRAÇÃO"
    else
        title = "INVENTÁRIO"
    end

    draw.SimpleText(title, "PS_CatName", 125, 125, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

hook.Add("RenderScreenspaceEffects", "ps.draw.nicebgblur", function()
    if PS.ShopMenu and PS.ShopMenu:IsVisible() then
        DrawToyTown(10, ScrH())
    end
end)

vgui.Register("DPointShopMenu", PANEL)