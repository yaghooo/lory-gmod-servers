function PS:LoadSounds()
    local sounds = {"case_tick", "case_opened"}

    for _, v in pairs(sounds) do
        resource.AddFile("sound/pointshop/" .. v .. ".wav")
    end
end

-- net hooks
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

-- admin points
net.Receive("PS_GivePoints", function(length, ply)
    local other = net.ReadEntity()
    local points = net.ReadInt(32)
    local allowed = PS.Config.AdminCanAccessAdminTab and ply:IsAdmin() or ply:IsSuperAdmin()

    if allowed and other and points and IsValid(other) and other:IsPlayer() then
        other:PS_GivePoints(points)
        other:PS_Notify(ply:Nick(), " deu a você ", points, " ", PS.Config.PointsName, ".")
        ply:Log("Gave %s points to %s with steamid %s", points, other:Nick(), other:SteamID())
    end
end)

net.Receive("PS_TakePoints", function(length, ply)
    local other = net.ReadEntity()
    local points = net.ReadInt(32)
    local allowed = PS.Config.AdminCanAccessAdminTab and ply:IsAdmin() or ply:IsSuperAdmin()

    if allowed and other and points and IsValid(other) and other:IsPlayer() then
        other:PS_TakePoints(points)
        other:PS_Notify(ply:Nick(), " pegou ", points, " ", PS.Config.PointsName, " de você.")
        ply:Log("Take %s points from %s with steamid %s", points, other:Nick(), other:SteamID())
    end
end)

net.Receive("PS_SetPoints", function(length, ply)
    local other = net.ReadEntity()
    local points = net.ReadInt(32)
    local allowed = PS.Config.AdminCanAccessAdminTab and ply:IsAdmin() or ply:IsSuperAdmin()

    if allowed and other and points and IsValid(other) and other:IsPlayer() then
        other:PS_SetPoints(points)
        other:PS_Notify(ply:Nick(), " setou seu saldo de ", PS.Config.PointsName, " para ", points, ".")
        ply:Log("Set points for %s with steamid %s to %s", other:Nick(), other:SteamID(), points)
    end
end)

-- admin items
net.Receive("PS_GiveItem", function(length, ply)
    local other = net.ReadEntity()
    local item_id = net.ReadString()
    local allowed = PS.Config.AdminCanAccessAdminTab and ply:IsAdmin() or ply:IsSuperAdmin()

    if allowed and other and item_id and PS.Items[item_id] and IsValid(other) and other:IsPlayer() and not other:PS_HasItem(item_id) then
        other:PS_GiveItem(item_id)
        ply:Log("Gave item %s to %s with steamid %s", PS.Items[item_id].Name, other:Nick(), other:SteamID())
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
        ply:Log("Take item %s from %s with steamid %s", ITEM.Name, other:Nick(), other:SteamID())
    end
end)

-- hooks
-- Ability to use any button to open pointshop.
hook.Add("PlayerButtonDown", "PS_ToggleKey", function(ply, btn)
    if PS.Config.ShopKey and PS.Config.ShopKey ~= "" then
        local psButton = _G["KEY_" .. string.upper(PS.Config.ShopKey)]

        if psButton and psButton == btn then
            ply:PS_ToggleMenu()
        end
    end
end)

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

timer.Create("PS_Loots", 60 * 3, 0, function()
    local lootables = {}

    for _, v in pairs(PS.Items) do
        if v.Lootable then
            table.insert(lootables, v)
        end
    end

    for _, v in pairs(player.GetAll()) do
        if not IsValid(v) or v.Spectating then return end

        local chance = PS.Config.LootChance
        if v:PS_IsElegibleForDouble() then
            chance = chance * 1.5
        end

        local drop = math.random() <= PS.Config.LootChance

        if drop then
            local loot = table.Random(lootables)
            v:PS_GiveItem(loot.ID)
            v:ChatPrint("<hsv>Parabéns! Você ganhou uma " .. loot.Name .. ".</hsv>")
        end
    end
end)

hook.Add("PlayerSay", "PS_PlayerSay", function(ply, text)
    if string.len(PS.Config.ShopChatCommand) > 0 and string.sub(text, 0, string.len(PS.Config.ShopChatCommand)) == PS.Config.ShopChatCommand then
        ply:PS_ToggleMenu()

        return ""
    end
end)

-- ugly networked strings
util.AddNetworkString("PS_Items")
util.AddNetworkString("PS_Points")
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
util.AddNetworkString("PS_ToggleMenu")
util.AddNetworkString("PS_OpenCase")

-- console commands
concommand.Add(PS.Config.ShopCommand, function(ply, cmd, args)
    ply:PS_ToggleMenu()
end)

-- data providers
function PS:LoadDataProvider()
    local path = "pointshop/providers/" .. self.Config.DataProvider .. ".lua"

    if not file.Exists(path, "LUA") then
        error("Pointshop data provider not found. " .. path)
    end

    PROVIDER = {}
    PROVIDER.__index = {}
    PROVIDER.ID = self.Config.DataProvider
    include(path)
    self.DataProvider = PROVIDER
    PROVIDER = nil
end

function PS:GetPlayerData(ply, callback)
    self.DataProvider:GetData(ply, function(points, items)
        callback(PS:ValidatePoints(tonumber(points)), PS:ValidateItems(items))
    end)
end

function PS:SetPlayerData(ply, points, items)
    self.DataProvider:SetData(ply, points, items)
end

function PS:SetPlayerPoints(ply, points)
    self.DataProvider:SetPoints(ply, points)
end

function PS:GivePlayerPoints(ply, points)
    self.DataProvider:GivePoints(ply, points, items)
end

function PS:TakePlayerPoints(ply, points)
    self.DataProvider:TakePoints(ply, points)
end

function PS:SavePlayerItem(ply, item_id, data)
    self.DataProvider:SaveItem(ply, item_id, data)
end

function PS:GivePlayerItem(ply, item_id, data)
    self.DataProvider:GiveItem(ply, item_id, data)
end

function PS:TakePlayerItem(ply, item_id)
    self.DataProvider:TakeItem(ply, item_id)
end