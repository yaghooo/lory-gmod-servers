function PS:GetPlayerPoints(ply, callback)
    self.DataProvider:GetPoints(ply:SteamID64(), function(points)
        callback(points)
    end)
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

function PS:GetPlayerItems(ply, callback)
    self.DataProvider:GetItems(ply:SteamID64(), function(plainItems)
        local inventory = {}

        for k, v in ipairs(plainItems) do
            local ITEM = self.Items[v.item_id]

            if ITEM then
                local currentItem
                local canHaveMultiple = self:FindCategoryByName(ITEM.Category).CanHaveMultiples

                if canHaveMultiple then
                    currentItem = inventory[v.item_id] or {}
                    table.insert(currentItem, {
                        ID = v.id
                    })
                else
                    currentItem = {
                        ID = v.id
                    }

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

        callback(inventory)
    end)
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