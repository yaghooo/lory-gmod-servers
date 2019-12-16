local VipPoints = 50000

hook.Add("PlayerSay", "CheckPlayerCollectedVipPoints", function(ply, text, team)
    if text == "!coletar" and string.match(ply:GetUserGroup(), "vip") then
        local id = ULib.ucl.getUserRegisteredID(ply)

        if not id then
            id = ply:SteamID()
        end

        id = id:upper()
        local query1 = "SELECT * FROM vip_points WHERE date_collect > DATE('NOW') AND id = '" .. id .. "'"
        local res = sql.QueryRow(query1)

        if not res then
            local query2 = "INSERT INTO vip_points VALUES('" .. id .. "', '0', DATE('NOW', '+30 DAYS'))"
            ExecuteQueryWithDebug(query2)
            res = sql.QueryRow(query1)
        end

        if res.collected == "0" then
            if VipPoints ~= 0 then
                ply:PS_GivePoints(VipPoints)
                ply:PS_Notify("Você ganhou " .. VipPoints .. " " .. PS.Config.PointsName .. " por ser VIP!")
            end

            local query3 = "UPDATE vip_points SET collected = '1' WHERE id = '" .. id .. "'"
            ExecuteQueryWithDebug(query3)
            ply:ChatPrint("<hsv>Você coletou sua recompensa com sucesso!</hsv>")
        else
            local time = os.time{
                year = string.sub(res.date_collect, 1, 4),
                month = string.sub(res.date_collect, 6, 7),
                day = string.sub(res.date_collect, 9, 10)
            }

            local days = (time - os.time()) / 60 / 60 / 24
            ply:ChatPrint("Você já coletou sua recompensa! Espere " .. math.Round(days) .. " dias para coleta-la novamente.")
        end
    end
end)

function ExecuteQueryWithDebug(query)
    local queryReturn = sql.Query(query)

    if queryReturn == false then
        print("SQLITE ERROR!")
        print("QUERY --> '" .. query .. "'")
        print("ERROR --> '" .. sql.LastError() .. "'")
        debug.Trace()
    end

    return queryReturn
end

local query = "CREATE TABLE IF NOT EXISTS `vip_points` ( `id` STRING, `collected` BOOLEAN, `date_collect` DATE )"
ExecuteQueryWithDebug(query)