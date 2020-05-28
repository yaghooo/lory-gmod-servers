MENU = {}
-- Constants
MENU.Shop = "Loja"
MENU.Inventory = "Inventário"
MENU.Miscellaneous = "Variados"
MENU.Players = "Jogadores"
MENU.ItemsStatistics = "Estatisticas dos items"
MENU.Skins = "Skins"
MENU.Settings = "Configurações"
MENU.Marketplace = "Mercado [BETA]"
MENU.OwnedItems = true
MENU.UnownedItems = false

local function canAccessAdminTab()
    return (PS.Config.AdminCanAccessAdminTab and LocalPlayer():IsAdmin()) or LocalPlayer():IsSuperAdmin()
end

MENU.MiscCategories = {
    [MENU.Players] = {
        CanAccess = canAccessAdminTab
    },
    [MENU.ItemsStatistics] = {
        CanAccess = canAccessAdminTab
    },
    [MENU.Marketplace] = {
        CanAccess = function() return PS.Config.IsMarketplaceEnabled end
    }
}

function MENU:Init()
    PS:RemoveHoverItem()
    -- Initial values
    self.CurrentTab = self.Shop
    self.TabHeight = 46
    self.ItemSize = 120
    self.ActionsHeight = 32
    local screenHeight = ScrH()
    local screenWidth = ScrW()

    if screenHeight > 800 and screenWidth > 1000 then
        screenHeight = screenHeight - 100
        screenWidth = screenWidth - 200
    end

    self:SetSize(screenWidth, screenHeight)
    self:RenderPoints()
    self:RenderTitle()
    self:RenderCategories()
    self:RenderTabs()
    self.ContentWidth = self:GetWide() - self.CategoriesPanel:GetWide() - self.OutLineSize * 3 - 4 * 2
    self.ItemsContentWidth = (self.ContentWidth - self.ItemSize * 2 - self.ContentWidth % self.ItemSize) + 4 * 3
    self:RenderActionsContainer()
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

function MENU:RenderTabs()
    local tabs = {self.Shop, self.Inventory, self.Miscellaneous}
    local categoriesSize = self.CategoriesPanel:GetWide()
    local btnSize = (self:GetWide() - categoriesSize - self.OutLineSize * 3) / #tabs

    for i, v in pairs(tabs) do
        local btn = vgui.Create(THEME.Component.Button1, self)
        btn:SetPos(categoriesSize + self.OutLineSize + (btnSize + 1) * (i - 1), self.HeaderSize + self.OutLineSize)
        btn:SetSize(btnSize + 2, self.TabHeight)
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
            surface.DrawText(v.Name or k)
        end

        i = i + 1
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
            model:SetItem(item, isInventory)
            model:SetSize(self.ItemSize - 4, self.ItemSize - 4)
            model.Menu = self
            model.State = getState(item)

            function model:DoClick()
                if self.Menu.CurrentItem ~= item then
                    self.Menu.CurrentItem = item
                    PS:SetHoverItem(item.ID)
                else
                    self.Menu.CurrentItem = nil
                    PS:RemoveHoverItem()
                end
            end

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

    self.Preview = vgui.Create("DPointShopPreview", self.ActionsContainer)
    self.Preview:Dock(FILL)
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
    local client = LocalPlayer()
    self.ActionButtons = {}

    local createButton = function(text, callback, enabled)
        local button = vgui.Create(THEME.Component.Button1, self.ActionsContainer)
        button:SetText(text)
        button:SetSize(self.ActionsContainer:GetWide(), 32)
        button.DoClick = callback
        button:Dock(BOTTOM)
        button:DockMargin(0, 8, 0, 0)

        if enabled == false then
            button:SetDisabled(true)
        end

        table.insert(self.ActionButtons, button)
    end

    local lastItemState = nil

    function self:Think()
        local isInventory = self.CurrentTab == self.Inventory
        local newItemState = not self.CurrentItem or isInventory and client.PS_Items[self.CurrentItem.ID] or self.CurrentItem.ID

        if lastItemState ~= newItemState then
            lastItemState = newItemState

            -- Remove before render again, to avoid memory leaks
            if self.ActionButtons then
                for k, v in ipairs(self.ActionButtons) do
                    v:Remove()
                end
            end

            self.ActionButtons = {}

            if PS.Config.CanPlayersGivePoints then
                createButton("Transferir " .. PS.Config.PointsName .. "s", function()
                    vgui.Create("DPointShopGivePoints")
                end)
            end

            if self.CurrentItem then
                if isInventory then
                    local price = PS.Config.CalculateSellPrice(client, self.CurrentItem)

                    createButton("Vender " .. self.CurrentItem.Name .. " (" .. price .. ")", function()
                        Derma_Query("Tem certeza que quer vender " .. self.CurrentItem.Name .. "?", "Vender item", "Sim", function()
                            client:PS_SellItem(self.CurrentItem.ID)
                            self.CurrentItem = nil
                        end, "Não", function() end)
                    end)

                    if PS.Config.CanPlayersGiveItems then
                        createButton("Enviar de presente", function()
                            local giveItemPanel = vgui.Create("DPointShopGiveItem")
                            giveItemPanel:SetItem(self.CurrentItem)
                        end, not client:PS_HasItemEquipped(self.CurrentItem.ID))
                    end

                    if PS.Config.IsMarketplaceEnabled then
                        createButton("Anunciar no mercado", function()
                            local createMarketplace = vgui.Create("DPointShopCreateMarketplace")
                            createMarketplace:SetItemId(self.CurrentItem.ID)
                        end, not client:PS_HasItemEquipped(self.CurrentItem.ID))
                    end
                else
                    local price = self.CurrentCategory == self.Marketplace and self.CurrentPrice or PS.Config.CalculateBuyPrice(client, self.CurrentItem)

                    createButton("Comprar " .. self.CurrentItem.Name .. " (" .. price .. ")", function()
                        Derma_Query("Tem certeza que quer comprar " .. self.CurrentItem.Name .. "?", "Comprar item", "Sim", function()
                            if self.AnnounceId and self.CurrentCategory == self.Marketplace then
                                client:PS_BuyMarketplaceItem(self.AnnounceId)
                            else
                                client:PS_BuyItem(self.CurrentItem.ID)
                            end
                            self.CurrentItem = nil
                        end, "Não", function() end)
                    end, client:PS_HasPoints(price) and not client:PS_HasItem(self.CurrentItem.ID))
                end

                if isInventory and self.CurrentItem.CanPlayerEquip then
                    if self.CurrentItem.Modify or PS.Categories[self.CurrentCategory].Modify then
                        createButton("Modificar", function()
                            if self.CurrentItem.Modify then
                                self.CurrentItem:Modify(client.PS_Items[self.CurrentItem.ID].Modifiers)
                            elseif PS.Categories[self.CurrentCategory].Modify then
                                PS.Categories[self.CurrentCategory]:Modify(client.PS_Items[self.CurrentItem.ID].Modifiers, self.CurrentItem)
                            end
                        end)
                    end

                    if not self.CurrentItem.EquipLabel and client:PS_HasItemEquipped(self.CurrentItem.ID) then
                        createButton("Desequipar", function()
                            client:PS_HolsterItem(self.CurrentItem.ID)
                        end)
                    else
                        createButton(self.CurrentItem.EquipLabel or "Equipar", function()
                            client:PS_EquipItem(self.CurrentItem.ID)
                        end)
                    end
                end
            end
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

    for _, ply in ipairs(player.GetAll()) do
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

function MENU:RenderItemsStatistics()
    local itemsData = vgui.Create("DListView", self.ItemsContainer)
    itemsData:SetSize(self.ItemsContainer:GetWide() - 4 * 2, self.ItemsContainer:GetTall() - 4 * 2)
    itemsData:SetMultiSelect(false)
    itemsData.Paint = function(ss, w, h) end

    local headerPaint = function(s, w, h)
        draw.RoundedBox(0, 1, 1, w - 2, h - 2, THEME.Color.Primary)
        draw.RoundedBox(0, 2, 2, w - 4, h - 4, ColorAlpha(color_white, 10))
    end

    local itemNameHeader = itemsData:AddColumn("Item")
    itemNameHeader.Header.Paint = headerPaint
    itemNameHeader.Header:SetTextColor(color_white)
    local categoryNameHeader = itemsData:AddColumn("Categoria")
    categoryNameHeader.Header.Paint = headerPaint
    categoryNameHeader.Header:SetTextColor(color_white)
    local totalHeader = itemsData:AddColumn("Quantidade de compras")
    totalHeader.Header.Paint = headerPaint
    totalHeader.Header:SetTextColor(color_white)
    local equippedHeader = itemsData:AddColumn("Quantidade equipada")
    equippedHeader.Header.Paint = headerPaint
    equippedHeader.Header:SetTextColor(color_white)

    local addItemsData = function()
        for _, itemData in ipairs(PS.ItemsData) do
            local line = itemsData:AddLine(itemData.itemName, itemData.category, tonumber(itemData.total), tonumber(itemData.equipped))

            for _, column in pairs(line.Columns) do
                column:SetColor(color_white)
            end
        end
    end

    local thinked = false

    function itemsData:Think()
        if PS.ItemsData and not thinked then
            thinked = true
            addItemsData()
        end
    end

    itemsData.Menu = self
end

function MENU:RenderMarketplace()
    local itemsGrid = vgui.Create("DGrid", self.ItemsContainer)
    itemsGrid:SetPos(0, 0)
    itemsGrid:SetCols(math.floor(self.ItemsContainer:GetWide() / self.ItemSize))
    itemsGrid:SetColWide(self.ItemSize)
    itemsGrid:SetRowHeight(self.ItemSize)

    local addItems = function()
        local addItem = function(item)
            local model = vgui.Create("DPointShopItem")
            model:SetItem(PS.Items[item.item_id], false, item.price)
            model:SetSize(self.ItemSize - 4, self.ItemSize - 4)
            model.Menu = self

            function model:DoClick()
                if self.Menu.CurrentItem ~= PS.Items[item.item_id] then
                    self.Menu.CurrentItem = PS.Items[item.item_id]
                    self.Menu.CurrentPrice = tonumber(item.price)
                    self.Menu.AnnounceId = item.id
                    PS:SetHoverItem(item.item_id)
                else
                    self.Menu.CurrentItem = nil
                    self.Menu.CurrentPrice = nil
                    self.Menu.AnnounceId = nil
                    PS:RemoveHoverItem()
                end
            end

            itemsGrid:AddItem(model)
        end

        for k, item in ipairs(PS.MarketplaceItems) do
            addItem(item)
        end
    end

    local thinked = false

    function itemsGrid:Think()
        if PS.MarketplaceItems and not thinked then
            thinked = true
            addItems()
        end
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

function MENU:RenderActionsContainer()
    -- Remove before render again, to avoid memory leaks
    if self.ActionsContainer then
        self.ActionsContainer:Remove()
    end

    self.ActionsContainer = vgui.Create("EditablePanel", self)
    self.ActionsContainer:SetSize(self.ContentWidth - self.ItemsContentWidth - 4, self:GetTall() - self.HeaderSize - self.OutLineSize * 3 - self.ContainerPadding * 3)
    self.ActionsContainer:SetPos(self:GetWide() - (self.ContentWidth - self.ItemsContentWidth) - 4 * 2, self.HeaderSize + self.OutLineSize + self.TabHeight + 4)
end

function MENU:SetTab(tab)
    self.CurrentItem = nil
    PS:RemoveHoverItem()
    self.CurrentTab = tab
    self:SetCategory()
    self:RenderCategories()
end

function MENU:SetCategory(category)
    self.CurrentCategory = category
    self:RenderItemsContainer()

    if self.CurrentTab == self.Miscellaneous then
        if self.CurrentCategory == self.Players then
            net.Start("PS_PlayersData")
            net.SendToServer()
            self:RenderPlayers()
        elseif self.CurrentCategory == self.ItemsStatistics then
            net.Start("PS_ItemsData")
            net.SendToServer()
            self:RenderItemsStatistics()
        elseif self.CurrentCategory == self.Marketplace then
            PS.MarketplaceItems = nil
            net.Start("PS_MarketplaceItems")
            net.SendToServer()
            self:RenderMarketplace()
        end
    else
        self:RenderItems()
    end
end

function MENU:GetCategories()
    if self.CurrentTab == self.Miscellaneous then
        local availableCategories = {}

        for k, v in pairs(self.MiscCategories) do
            if not v.CanAccess or v.CanAccess() then
                availableCategories[k] = v
            end
        end

        return pairs(availableCategories)
    end

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
    if not category then return false end

    for k, item in pairs(userItems) do
        if PS.Items[k] and PS.Items[k].Category == category.Name then return true end
    end

    return false
end

vgui.Register("DPointShopMenu", MENU, THEME.Component.Page)