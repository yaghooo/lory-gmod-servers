function PS:GetPlayerPoints(ply)
    return self.DataProvider:GetPoints(ply:SteamID64())
end

function PS:SetPlayerPoints(ply, points)
    self.DataProvider:SetPoints(ply:SteamID64(), points)
end

function PS:GivePlayerPoints(ply, points)
    self.DataProvider:GivePoints(ply:SteamID64(), points)
end

function PS:TakePlayerPoints(ply, points)
    self.DataProvider:TakePoints(ply:SteamID64(), points)
end

function PS:GetPlayerItems(ply)
    local plainItems = self.DataProvider:GetItems(ply:SteamID64())
    local inventory = {}

    for k, v in ipairs(plainItems) do
        local ITEM = self.Items[v.item_id]

        if ITEM then
            local currentItem
            local canHaveMultiple = self:FindCategoryByName(ITEM.Category).CanHaveMultiples

            if canHaveMultiple then
                currentItem = inventory[v.item_id] or {}
                table.insert(currentItem, {})
            else
                currentItem = {}

                if v.equipped ~= nil then
                    currentItem.Equipped = tobool(v.equipped)
                end

                if v.modifiers ~= nil then
                    currentItem.Modifiers = util.JSONToTable(v.modifiers)
                end
            end

            inventory[v.item_id] = currentItem
        end
    end

    return inventory
end

function PS:GivePlayerItem(ply, item_id)
    self.DataProvider:GiveItem(ply:SteamID64(), item_id)
end

function PS:SetPlayerItemModifiers(ply, item_id, modifiers)
    self.DataProvider:SetItemModifiers(ply:SteamID64(), item_id, util.TableToJSON(modifiers))
end

function PS:SetPlayerItemEquipped(ply, item_id, equipped)
    self.DataProvider:SetItemEquipped(ply:SteamID64(), item_id, equipped)
end

function PS:TakePlayerItem(ply, item_id)
    self.DataProvider:TakeItem(ply:SteamID64(), item_id)
end