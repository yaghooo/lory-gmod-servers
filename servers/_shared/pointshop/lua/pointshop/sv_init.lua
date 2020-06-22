function PS:LoadSounds()
    local sounds = {"case_tick", "case_opened1", "case_opened2"}

    for _, v in pairs(sounds) do
        resource.AddFile("sound/pointshop/" .. v .. ".mp3")
    end
end

-- net hooks
net.Receive("PS_BuyMarketplaceItem", function(lenght, ply)
    ply:PS_BuyMarketplaceItem(net.ReadInt(32))
end)

net.Receive("PS_BuyItem", function(length, ply)
    ply:PS_BuyItem(net.ReadString())
end)

net.Receive("PS_SellItem", function(length, ply)
    ply:PS_SellItem(net.ReadString())
end)

net.Receive("PS_EquipItem", function(length, ply)
    ply:PS_EquipItem(net.ReadString())
end)

net.Receive("PS_HolsterItem", function(length, ply)
    ply:PS_HolsterItem(net.ReadString())
end)

net.Receive("PS_ModifyItem", function(length, ply)
    ply:PS_ModifyItem(net.ReadString(), net.ReadTable())
end)

-- player to player
net.Receive("PS_SendPoints", function(length, ply)
    local other = net.ReadEntity()
    local points = math.Clamp(net.ReadInt(32), 0, 1000000)
    if not PS.Config.CanPlayersGivePoints then return end
    if not points or points == 0 then return end
    if not other or not IsValid(other) or not other:IsPlayer() then return end
    if not ply or not IsValid(ply) or not ply:IsPlayer() then return end

    if not ply:PS_HasPoints(points) then
        ply:PS_Notify("Você não tem ", points, " ", PS.Config.PointsName, ".")

        return
    end

    ply.PS_LastGavePoints = ply.PS_LastGavePoints or 0

    if ply.PS_LastGavePoints + 5 > CurTime() then
        ply:PS_Notify("Acalme-se! Você não pode enviar pontos tão rápido.")

        return
    end

    ply:PS_TakePoints(points)
    ply:PS_Notify("Você deu a ", other:Nick(), " ", points, " ", PS.Config.PointsName, ".")
    other:PS_GivePoints(points)
    other:PS_Notify(ply:Nick(), " deu a você ", points, " ", PS.Config.PointsName, ".")
    ply.PS_LastGavePoints = CurTime()
end)

net.Receive("PS_SendItem", function(length, ply)
    local other = net.ReadEntity()
    local item_id = net.ReadString()
    if not PS.Config.CanPlayersGiveItems then return end
    if not item_id then return end
    if not other or not IsValid(other) or not other:IsPlayer() then return end
    if not ply or not IsValid(ply) or not ply:IsPlayer() then return end

    if not ply:PS_HasItem(item_id) then
        ply:PS_Notify("Você não tem esse item.")

        return
    end

    local item = PS.Items[item_id]
    local category = PS:FindCategoryByName(item.Category)

    if not category.CanHaveMultiples and other:PS_HasItem(item_id) then
        ply:PS_Notify(other:Nick(), " já possui este item!")

        return
    end

    ply.PS_LastGavePoints = ply.PS_LastGavePoints or 0

    if ply.PS_LastGavePoints + 5 > CurTime() then
        ply:PS_Notify("Acalme-se! Você não pode enviar pontos/items tão rápido.")

        return
    end

    ply:PS_TakeItem(item_id)
    ply:PS_Notify("Você deu ", item.Name, " a ", other:Nick(), ".")
    other:PS_GiveItem(item_id)
    other:PS_Notify(ply:Nick(), " deu ", item.Name, " a você.")
    ply.PS_LastGavePoints = CurTime()
end)

net.Receive("PS_CreateMarketplace", function(lenght, ply)
    local item_id = net.ReadString()
    local price = net.ReadInt(32)

    if not item_id or price <= 0 then return end

    PS.DataProvider:CreateAnnounce(ply:SteamID64(), item_id, price)
    ply:PS_TakeItem(item_id)
end)

-- admin points
net.Receive("PS_GivePoints", function(length, ply)
    local other = net.ReadEntity()
    local points = net.ReadInt(32)
    local allowed = PS.Config.AdminCanAccessAdminTab and ply:IsAdmin() or ply:IsSuperAdmin()

    if allowed and other and points and IsValid(other) and other:IsPlayer() then
        other:PS_GivePoints(points)
        other:PS_Notify(ply:Nick(), " deu a você ", points, " ", PS.Config.PointsName, ".")

        ulx.logString(ply:Nick() .. " gave " .. points .. " " .. PS.Config.PointsName .. " to " .. other:Nick() .. "(" .. ply:SteamID64() .. ", " .. other:SteamID64() .. ")")
    end
end)

net.Receive("PS_TakePoints", function(length, ply)
    local other = net.ReadEntity()
    local points = net.ReadInt(32)
    local allowed = PS.Config.AdminCanAccessAdminTab and ply:IsAdmin() or ply:IsSuperAdmin()

    if allowed and other and points and IsValid(other) and other:IsPlayer() then
        other:PS_TakePoints(points)
        other:PS_Notify(ply:Nick(), " pegou ", points, " ", PS.Config.PointsName, " de você.")

        ulx.logString(ply:Nick() .. " took " .. points .. " " .. PS.Config.PointsName .. " of " .. other:Nick() .. "(" .. ply:SteamID64() .. ", " .. other:SteamID64() .. ")")
    end
end)

net.Receive("PS_SetPoints", function(length, ply)
    local other = net.ReadEntity()
    local points = net.ReadInt(32)
    local allowed = PS.Config.AdminCanAccessAdminTab and ply:IsAdmin() or ply:IsSuperAdmin()

    if allowed and other and points and IsValid(other) and other:IsPlayer() then
        other:PS_SetPoints(points)
        other:PS_Notify(ply:Nick(), " setou seu saldo de ", PS.Config.PointsName, " para ", points, ".")

        ulx.logString(ply:Nick() .. " set to " .. points .. " " .. PS.Config.PointsName .. " on " .. other:Nick() .. "(" .. ply:SteamID64() .. ", " .. other:SteamID64() .. ")")
    end
end)

-- admin items
net.Receive("PS_GiveItem", function(length, ply)
    local other = net.ReadEntity()
    local item_id = net.ReadString()
    local allowed = PS.Config.AdminCanAccessAdminTab and ply:IsAdmin() or ply:IsSuperAdmin()

    if allowed and other and item_id and PS.Items[item_id] and IsValid(other) and other:IsPlayer() and not other:PS_HasItem(item_id) then
        other:PS_GiveItem(item_id)

        ulx.logString(ply:Nick() .. " gave " .. item_id .. " to " .. other:Nick() .. "(" .. ply:SteamID64() .. ", " .. other:SteamID64() .. ")")
    end
end)

net.Receive("PS_TakeItem", function(length, ply)
    local other = net.ReadEntity()
    local item_id = net.ReadString()
    local allowed = PS.Config.AdminCanAccessAdminTab and ply:IsAdmin() or ply:IsSuperAdmin()

    if allowed and other and item_id and PS.Items[item_id] and IsValid(other) and other:IsPlayer() and other:PS_HasItem(item_id) then
        -- holster it first without notificaiton
        other.PS_Items[item_id].Equipped = false
        local ITEM = PS.Items[item_id]
        local CATEGORY = PS:FindCategoryByName(ITEM.Category)

        if ITEM.OnHolster then
            ITEM:OnHolster(other)
        elseif CATEGORY.OnHolster then
            CATEGORY:OnHolster(other, nil, ITEM)
        end

        other:PS_TakeItem(item_id)
        ulx.logString(ply:Nick() .. " took " .. item_id .. " of " .. other:Nick() .. "(" .. ply:SteamID64() .. ", " .. other:SteamID64() .. ")")
    end
end)

-- admin requests
net.Receive("PS_PlayersData", function(length, ply)
    local allowed = PS.Config.AdminCanAccessAdminTab and ply:IsAdmin() or ply:IsSuperAdmin()

    if allowed then
        local data = {}

        for k, v in pairs(player.GetAll()) do
            if ply ~= v then
                table.insert(data, {
                    ply = v,
                    points = v.PS_Points,
                    items = v.PS_Items
                })
            end
        end

        net.Start("PS_PlayersData")
        net.WriteTable(data)
        net.Send(ply)
    end
end)

net.Receive("PS_ItemsData", function(length, ply)
    local allowed = PS.Config.AdminCanAccessAdminTab and ply:IsAdmin() or ply:IsSuperAdmin()

    if allowed then
        PS.DataProvider:GetItemsStats(function(itemsData)
            local keyed = {}
            itemsData = itemsData or {}

            for k, v in ipairs(itemsData) do
                if PS.Items[v.item_id] then
                    keyed[v.item_id] = true
                    itemsData[k].itemName = PS.Items[v.item_id].Name
                    itemsData[k].category = PS.Items[v.item_id].Category
                    itemsData[k].item_id = nil
                end
            end

            for item_id, item in pairs(PS.Items) do
                if not keyed[item_id] then
                    table.insert(itemsData, {
                        itemName = item.Name,
                        category = item.Category,
                        total = 0,
                        equipped = 0
                    })
                end
            end

            net.Start("PS_ItemsData")
            net.WriteTable(itemsData)
            net.Send(ply)
        end)
    end
end)

net.Receive("PS_MarketplaceItems", function(lenght, ply)
    PS.DataProvider:GetBuyableAnnounces(function(announces)
        net.Start("PS_MarketplaceItems")
        net.WriteTable(announces)
        net.Send(ply)
    end)
end)

-- hooks
hook.Add("PlayerSpawn", "PS_PlayerSpawn", function(ply)
    ply:PS_PlayerSpawn()
end)

hook.Add("PlayerDeath", "PS_PlayerDeath", function(ply)
    ply:PS_PlayerDeath()
end)

hook.Add("PlayerInitialSpawn", "PS_PlayerInitialSpawn", function(ply)
    ply:PS_PlayerInitialSpawn()
end)

hook.Add("PlayerDisconnected", "PS_PlayerDisconnected", function(ply)
    ply:PS_PlayerDisconnected()
end)

timer.Create("PS_Loots", 60 * PS.Config.LootDropDelay, 0, function()
    local lootables = {}

    for _, v in pairs(PS.Items) do
        if v.Lootable then
            table.insert(lootables, v)
        end
    end

    for _, v in pairs(player.GetAll()) do
        if not IsValid(v) or v:Team() == TEAM_SPECTATOR then return end
        local chance = PS.Config.LootChance

        if v:PS_IsElegibleForDouble() then
            chance = chance * 1.5
        end

        local drop = math.random() <= chance

        if drop then
            local loot = table.Random(lootables)
            v:PS_GiveItem(loot.ID)
            v:ChatPrint("<hsv>Parabéns! Você ganhou uma " .. loot.Name .. ".</hsv>")
        end
    end
end)

if PS.Config.PointsOverTime then
    timer.Create("PS_PointsOverTime", PS.Config.PointsOverTimeDelay * 60, 0, function()
        for _, ply in ipairs(player.GetAll()) do
            if not IsValid(ply) or ply:Team() == TEAM_SPECTATOR then return end

            local amt = PS.Config.PointsOverTimeAmount

            ply:PS_GivePoints(amt)
            ply:PS_Notify("Você ganhou ", amt, " ", PS.Config.PointsName, " por jogar!")

            if ply:PS_IsElegibleForDouble() then
                ply:PS_GivePoints(amt)
                ply:PS_Notify("Você ganhou mais ", amt, " ", PS.Config.PointsName, " por ter a tag LORY!")
            end

            if ply:IsUserGroup("vip") then
                ply:PS_GivePoints(amt)
                ply:PS_Notify("Você ganhou mais ", amt, " ", PS.Config.PointsName, " por ser vip!")
            end
        end
    end)
end

-- ugly networked strings
util.AddNetworkString("PS_Items")
util.AddNetworkString("PS_Points")
util.AddNetworkString("PS_CreateMarketplace")
util.AddNetworkString("PS_PlayersData")
util.AddNetworkString("PS_ItemsData")
util.AddNetworkString("PS_MarketplaceItems")
util.AddNetworkString("PS_BuyMarketplaceItem")
util.AddNetworkString("PS_BuyItem")
util.AddNetworkString("PS_SellItem")
util.AddNetworkString("PS_EquipItem")
util.AddNetworkString("PS_HolsterItem")
util.AddNetworkString("PS_ModifyItem")
util.AddNetworkString("PS_SendPoints")
util.AddNetworkString("PS_SendItem")
util.AddNetworkString("PS_GivePoints")
util.AddNetworkString("PS_TakePoints")
util.AddNetworkString("PS_SetPoints")
util.AddNetworkString("PS_GiveItem")
util.AddNetworkString("PS_TakeItem")
util.AddNetworkString("PS_AddClientsideModel")
util.AddNetworkString("PS_RemoveClientsideModel")
util.AddNetworkString("PS_SendClientsideModels")
util.AddNetworkString("PS_SendNotification")
util.AddNetworkString("PS_OpenCase")