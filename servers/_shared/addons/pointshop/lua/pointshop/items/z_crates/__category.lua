CATEGORY.Name = "Caixas"
CATEGORY.Icon = "folder_key"
CATEGORY.Order = 7
CATEGORY.CanHaveMultiples = true

function CATEGORY:OnEquip(ply, _, item)
    if ply:PS_HasItem(item.Key) then
        ply:PS_TakeItem(item.ID)
        ply:PS_TakeItem(PS.Items[item.Key].ID)
        local items = self:GetItemList(item)
        local hasItem = false
        local won = items[PS.Config.CrateItemQuantity - 3]

        if not string.StartWith(won, "points") then
            if ply:PS_HasItem(won) then
                hasItem = true
                ply:PS_SellItem(won)
            end

            ply:PS_GiveItem(won)
        else
            local points = string.Split(won, ":")[2]
            ply:PS_GivePoints(tonumber(points))
        end

        net.Start("PS_OpenCase")
        net.WriteBool(hasItem)
        net.WriteTable(items)
        net.Send(ply)
    else
        local keyName = PS.Items[item.Key].Name
        ply:PS_Notify("Você precisa do item " .. keyName .. " para abrir esta caixa.")
    end
end

function CATEGORY:GetItemList(case)
    if not case.TotalChance then
        local totalChance = 0

        for k, v in pairs(case.PossibleItems) do
            totalChance = totalChance + v
        end

        case.TotalChance = totalChance
    end

    local itemList = {}

    for i = 0, PS.Config.CrateItemQuantity do
        local num = math.random(1, case.TotalChance)
        local check = 0

        for k, v in pairs(case.PossibleItems) do
            if num >= check and num <= check + v then
                itemList[i] = k
                break
            end

            check = check + v
        end
    end

    return itemList
end

function CATEGORY:GetPrice(item)
    if item.PossibleItems then
        local total = 0
        for k, v in pairs(item.PossibleItems) do
            if not string.StartWith(k, "points:") then
                total = total + PS.Items[k].Price
            end
        end

        return math.Round(total / table.Count(item.PossibleItems) / 1000 / 2) * 100
    end

    return 5000
end