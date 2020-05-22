local function fuckingConvertEverything()
    local playerPoints = sql.Query("SELECT * FROM pointshop_points")

    for k, v in ipairs(playerPoints) do
        PS.DataProvider:GivePoints(v.sid64, v.points)
    end

    local playerItems = sql.Query("SELECT * FROM pointshop_items")

    for k, v in ipairs(playerItems) do
        local item = PS.Items[v.item_id]

        if item then
            local category = PS:FindCategoryByName(item.Category)

            if not category.CanHaveMultiples then
                PS.DataProvider:TakeItem(v.sid64, v.item_id)
            end
        end
    end

    for k, v in ipairs(playerItems) do
        local item = PS.Items[v.item_id]

        if item then
            PS.DataProvider:GiveItem(v.sid64, v.item_id)
        end
    end

    local marketplaceItems = sql.Query("SELECT * FROM pointshop_marketplace WHERE buyer_sid64 IS NULL")

    for k, v in ipairs(marketplaceItems) do
        PS.DataProvider:CreateAnnounce(v.seller_sid64, v.item_id, v.price)
    end
end

hook.Add("PlayerSay", "ConvertDatabase", function(ply, text)
    if ply:IsSuperAdmin() and text == "!migrate" then
        for k, ply2 in ipairs(player.GetAll()) do
            ply2:ChatPrint("Migração iniciada, vai lagar bastante...")
        end

        timer.Simple(1, function()
            fuckingConvertEverything()
        end)
    end
end)