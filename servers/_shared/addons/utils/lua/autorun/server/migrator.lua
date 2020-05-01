hook.Add("PlayerSay", "DiscordRegister", function(ply, text)
    if text == "!migrate" and ply:IsSuperAdmin() then
        ply:ChatPrint("Iniciando")
        local rows = sql.Query("SELECT * FROM pointshop_data")

        for k, row in ipairs(rows) do
            PS.DataProvider:SetPoints(row.sid64, row.points)
            local items = util.JSONToTable(row.items)

            for itemId, item in pairs(items) do
                if item[0] and istable(item[0]) then
                    for i = 0, #item do
                        PS.DataProvider:GiveItem(row.sid64, itemId)
                    end
                else
                    PS.DataProvider:GiveItem(row.sid64, itemId)
                    if item.Equipped then
                        PS.DataProvider:SetItemEquipped(row.sid64, itemId, true)
                    end

                    if istable(item.Modifiers) and #item.Modifiers > 0 then
                        PS.DataProvider:SetItemModifiers(row.sid64, itemId, util.TableToJSON(item.Modifiers))
                    end
                end
            end
        end

        ply:ChatPrint("Finalizado")
    end
end)