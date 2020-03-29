MENU = {}
-- Constants
MENU.Shop = "Loja"
MENU.Inventory = "Inventário"
MENU.Admin = "Admin"
MENU.Players = "Jogadores"
MENU.Skins = "Skins"
MENU.Settings = "Configurações"
MENU.OwnedItems = true
MENU.UnownedItems = false

MENU.AdminCategories = {
    {
        Name = MENU.Players
    }
}

function MENU:Init()
    -- Initial values
    self.CurrentTab = self.Shop
    self.TabHeight = 46
    self.ItemSize = 120
    self.ActionsHeight = 32
    self:SetSize(ScrW() - 200, ScrH() - 100)
    self:RenderPoints()
    self:RenderTitle()
    self:RenderCategories()
    self:RenderTabs()
    self.ContentWidth = self:GetWide() - self.CategoriesPanel:GetWide() - self.OutLineSize * 3 - 4 * 2
    self.ItemsContentWidth = (self.ContentWidth - self.ItemSize * 2 - self.ContentWidth % self.ItemSize) + 4 * 3
    self:RenderPreview()
    self:RenderActions()
    local oldPaint = MENU.Paint

    function self:Paint(w, h)
        oldPaint(self, w, h)
        surface.SetDrawColor(THEME.Color.Primary)
        surface.DrawRect(0, self.HeaderSize, w, self.OutLineSize)
    end
end

function MENU:RenderPoints()
    local point = vgui.Create("DLabel", self)
    point:SetPos(self.ContainerPadding * 2, self.ContainerPadding)
    point:SetFont(THEME.Font.Coolvetica24)
    point:SetTextColor(color_white)

    function point:Think()
        self:SetText(PS:GetPointsText(LocalPlayer():PS_GetPoints()))
        self:SetSize(self:GetTextSize(), 24)
    end
end

function MENU:RenderTitle()
    local title = vgui.Create("DLabel", self)
    title:SetText(PS.Config.CommunityName)
    title:SetPos(self:GetWide() / 2 - title:GetTextSize() / 2, self.ContainerPadding)
    title:SetFont(THEME.Font.Coolvetica28)
    title:SetSize(title:GetTextSize(), 28)
    title:SetTextColor(THEME.Color.Primary)
end

function MENU:RenderCategories()
    -- Remove before render again, to avoid memory leaks
    if self.CategoriesPanel then
        self.CategoriesPanel:Remove()
    end

    self.CategoriesPanel = vgui.Create("DPanel", self)
    self.CategoriesPanel:SetSize(ScrW() / 6, self:GetTall() - self.HeaderSize - self.OutLineSize * 2)
    self.CategoriesPanel:SetPos(self.OutLineSize, self.HeaderSize + self.OutLineSize)
    self.CategoriesPanel:SetBackgroundColor(THEME.Color.LightSecondary)
    self.CategoriesPanel.Menu = self
    local oldPaint = self.CategoriesPanel.Paint

    function self.CategoriesPanel:Paint(w, h)
        oldPaint(self, w, h)
        surface.SetDrawColor(THEME.Color.Primary)
        surface.DrawRect(w - self.Menu.OutLineSize, 0, self.Menu.OutLineSize, h)
    end

    local categoriesContainer = vgui.Create("DScrollPanel", self.CategoriesPanel)
    categoriesContainer:SetSize(self.CategoriesPanel:GetWide() - self.OutLineSize, self.CategoriesPanel:GetTall())
    local i = 0

    for k, v in self:GetCategories() do
        local btn = vgui.Create(THEME.Component.Button1, categoriesContainer)
        btn:SetPos(0, i * (50 + 2) + self.OutLineSize)
        btn:SetSize(categoriesContainer:GetWide(), 50)
        btn:SetText("")
        btn.Menu = self

        function btn:Think()
            if self.Menu.CurrentCategory == k then
                self:SetBackgroundColor(ColorAlpha(THEME.Color.Primary, 150))
            elseif self:IsHovered() then
                self:SetBackgroundColor(ColorAlpha(THEME.Color.Primary, 30))
            else
                self:SetBackgroundColor(THEME.Color.Secondary)
            end
        end

        function btn:DoClick()
            if self.Menu.CurrentCategory ~= k then
                self.Menu:SetCategory(k)
            end
        end

        local icon = v.Icon and Material("icon16/" .. v.Icon .. ".png")
        local btnOldPaint = btn.Paint

        function btn:Paint(w, h)
            btnOldPaint(self, w, h)
            local padding = self.Menu.ContainerPadding

            if icon then
                surface.SetDrawColor(color_white)
                surface.SetMaterial(icon)
                surface.DrawTexturedRect(padding, h / 2 / 2, 24, 24)
                padding = padding * 2 + 24
            end

            surface.SetFont(THEME.Font.Coolvetica18)
            surface.SetTextPos(padding, h / 2 - 18 / 2)
            surface.SetTextColor(color_white)
            surface.DrawText(v.Name)
        end

        i = i + 1
    end
end

function MENU:RenderTabs()
    local tabs = {self.Shop, self.Inventory}
    local canAccessAdminTab = (PS.Config.AdminCanAccessAdminTab and LocalPlayer():IsAdmin()) or LocalPlayer():IsSuperAdmin()

    if canAccessAdminTab then
        table.insert(tabs, self.Admin)
    end

    local categoriesSize = self.CategoriesPanel:GetWide()
    local btnSize = (self:GetWide() - categoriesSize - self.OutLineSize * 2) / #tabs

    for i, v in pairs(tabs) do
        local btn = vgui.Create(THEME.Component.Button1, self)
        btn:SetPos(categoriesSize + self.OutLineSize + btnSize * (i - 1), self.HeaderSize + self.OutLineSize)
        btn:SetSize(btnSize, self.TabHeight)
        btn:SetText(v)
        btn:SetFont(THEME.Font.Coolvetica24)
        btn.Menu = self

        function btn:Think()
            if self:GetText() == self.Menu.CurrentTab then
                self:SetBackgroundColor(THEME.Color.Primary)
            else
                self:SetBackgroundColor(THEME.Color.LightSecondary)
            end
        end

        function btn:DoClick()
            if self.Menu.CurrentTab ~= self:GetText() then
                self.Menu:SetTab(self:GetText())
            end
        end
    end
end

function MENU:RenderItems()
    local itemsGrid = vgui.Create("DGrid", self.ItemsContainer)
    itemsGrid:SetPos(0, 0)
    itemsGrid:SetCols(math.floor(self.ItemsContainer:GetWide() / self.ItemSize))
    itemsGrid:SetColWide(self.ItemSize)
    itemsGrid:SetRowHeight(self.ItemSize)
    local category = PS.Categories[self.CurrentCategory]

    if category then
        local client = LocalPlayer()
        local userItems = client:PS_GetItems()
        local isInventory = self.CurrentTab == self.Inventory

        local getState = function(item)
            if isInventory == client:PS_HasItem(item.ID) and not category.CanHaveMultiples then
                return true
            elseif isInventory then
                local currentItems = client:PS_GetItems()
                if category.CanHaveMultiples and currentItems[item.ID] then return #currentItems[item.ID] end
            end

            return false
        end

        local addItem = function(item)
            local model = vgui.Create("DPointShopItem")
            model:SetItem(item, category, isInventory, render)
            model:SetSize(self.ItemSize - 4, self.ItemSize - 4)
            model.Menu = self
            model.State = getState(item)

            function model:Think()
                local state = getState(item)

                if self:IsValid() and state ~= self.State then
                    self.Menu:RenderItemsContainer()
                    self.Menu:RenderItems()
                end
            end

            itemsGrid:AddItem(model)
        end

        for k, item in SortedPairsByMemberValue(PS.Items, PS.Config.SortItemsBy) do
            if item.Category == category.Name and (category.CanHaveMultiples or isInventory == client:PS_HasItem(k)) then
                if isInventory and category.CanHaveMultiples and client:PS_HasItem(k) then
                    for i = 1, #userItems[k] do
                        addItem(item)
                    end
                elseif not isInventory or not category.CanHaveMultiples then
                    addItem(item)
                end
            end
        end
    end
end

function MENU:RenderPreview()
    -- Remove before render again, to avoid memory leaks
    if self.Preview then
        self.Preview:Remove()
    end

    self.Preview = vgui.Create("DPointShopPreview", self)
    self.Preview:SetSize(self.ContentWidth - self.ItemsContentWidth - 4, self:GetTall() - self.HeaderSize - self.OutLineSize * 3 - self.ContainerPadding * 3 - self.ActionsHeight - 4 * 3)
    self.Preview:SetPos(self:GetWide() - (self.ContentWidth - self.ItemsContentWidth) - 4 * 2, self.HeaderSize + self.OutLineSize + self.TabHeight + 4)
    local oldPaint = self.Preview.Paint

    self.Preview.Paint = function(s, pw, ph)
        draw.RoundedBox(0, 0, 0, pw, ph, THEME.Color.LightSecondary)
        oldPaint(s, pw, ph)
    end

    function self.Preview:DragMousePress()
        self.PressX, self.PressY = gui.MousePos()
        self.Pressed = true
    end

    function self.Preview:DragMouseRelease()
        self.Pressed = false
        self.lastPressed = RealTime()
    end

    self.Preview.Angles = Angle()

    function self.Preview:LayoutEntity(thisEntity)
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
end

function MENU:RenderActions()
    if PS.Config.CanPlayersGivePoints then
        local giveButton = vgui.Create(THEME.Component.Button1, self)
        giveButton:SetText("Transferir " .. PS.Config.PointsName .. "s")
        giveButton:SetSize(self.Preview:GetWide(), 32)
        local previewX, previewY = self.Preview:GetPos()
        giveButton:SetPos(previewX, previewY + self.Preview:GetTall() + 4 * 3)

        giveButton.DoClick = function()
            vgui.Create("DPointShopGivePoints")
        end
    end
end

function MENU:RenderPlayers()
    local players = vgui.Create("DListView", self.ItemsContainer)
    players:SetSize(self.ItemsContainer:GetWide() - 4 * 2, self.ItemsContainer:GetTall() - 4 * 2)
    players:SetMultiSelect(false)
    players.Paint = function(ss, w, h) end

    local headerPaint = function(s, w, h)
        draw.RoundedBox(0, 1, 1, w - 2, h - 2, THEME.Color.Primary)
        draw.RoundedBox(0, 2, 2, w - 4, h - 4, ColorAlpha(color_white, 10))
    end

    local nameHeader = players:AddColumn("Nome")
    nameHeader.Header.Paint = headerPaint
    nameHeader.Header:SetTextColor(color_white)
    local pointsHeader = players:AddColumn("Pontos")
    pointsHeader:SetFixedWidth(60)
    pointsHeader.Header.Paint = headerPaint
    pointsHeader.Header:SetTextColor(color_white)
    local itemsHeader = players:AddColumn("Itens")
    itemsHeader:SetFixedWidth(60)
    itemsHeader.Header.Paint = headerPaint
    itemsHeader.Header:SetTextColor(color_white)

    for _, ply in pairs(player.GetAll()) do
        local line = players:AddLine(ply:GetName(), ply:PS_GetPoints(), table.Count(ply:PS_GetItems()))
        line.Player = ply

        function line:Think()
            line:SetValue(2, ply:PS_GetPoints())
            line:SetValue(3, table.Count(ply:PS_GetItems()))
        end

        for _, column in pairs(line.Columns) do
            column:SetColor(color_white)
        end
    end

    local function buildItemMenu(menu, ply, type, onClickItem)
        for categoryId, category in SortedPairsByMemberValue(PS.Categories, "Order") do
            local catmenu = menu:AddSubMenu(category.Name)

            for itemId, item in SortedPairsByMemberValue(PS.Items, PS.Config.SortItemsBy) do
                local shouldAppear = (type == self.OwnedItems) == ply:PS_HasItem(itemId)

                if item.Category == category.Name and shouldAppear then
                    catmenu:AddOption(item.Name, function()
                        onClickItem(itemId)
                    end)
                end
            end
        end
    end

    players.Menu = self

    function players:OnClickLine(line, selected)
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

        buildItemMenu(menu:AddSubMenu("Dar item"), ply, self.Menu.UnownedItems, function(item_id)
            net.Start("PS_GiveItem")
            net.WriteEntity(ply)
            net.WriteString(item_id)
            net.SendToServer()
        end)

        buildItemMenu(menu:AddSubMenu("Tirar item"), ply, self.Menu.OwnedItems, function(item_id)
            net.Start("PS_TakeItem")
            net.WriteEntity(ply)
            net.WriteString(item_id)
            net.SendToServer()
        end)

        menu:Open()
    end
end

function MENU:RenderItemsContainer()
    -- Remove before render again, to avoid memory leaks
    if self.ItemsContainer then
        self.ItemsContainer:Remove()
    end

    self.ItemsContainer = vgui.Create(THEME.Component.Scroll, self)
    local headerTabSize = self.HeaderSize + self.OutLineSize + self.TabHeight + 4
    self.ItemsContainer:SetSize(self.ItemsContentWidth, self:GetTall() - headerTabSize - self.OutLineSize)
    self.ItemsContainer:SetPos(self.CategoriesPanel:GetWide() + self.OutLineSize * 2 + 4, headerTabSize)
end

function MENU:SetTab(tab)
    self.CurrentTab = tab
    self:SetCategory()
    self:RenderCategories()
end

function MENU:SetCategory(category)
    self.CurrentCategory = category
    self:RenderItemsContainer()

    if self.CurrentTab == self.Admin then
        local currentCategoryName = self.CurrentCategory and self.AdminCategories[self.CurrentCategory].Name

        if currentCategoryName == self.Players then
            self:RenderPlayers()
        end
    else
        self:RenderItems()
    end
end

function MENU:GetCategories()
    if self.CurrentTab == self.Admin then return pairs(self.AdminCategories) end
    local categories = table.Copy(PS.Categories)

    if self.CurrentTab == self.Inventory then
        for k, v in pairs(categories) do
            if not self:UserHasItemOnCategory(v) then
                categories[k] = nil
            end
        end
    end

    return SortedPairsByMemberValue(categories, "Order", false)
end

function MENU:UserHasItemOnCategory(category)
    local userItems = LocalPlayer():PS_GetItems()

    if not category then
        return false
    end

    for k, item in pairs(userItems) do
        if PS.Items[k] and PS.Items[k].Category == category.Name then
            return true
        end
    end

    return false
end

vgui.Register("DPointShopMenu", MENU, THEME.Component.Page)