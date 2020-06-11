PRIZE.Title = "ENTRE NO GRUPO STEAM ~ DIGITE !grupo"
PRIZE.Points = 5000
PRIZE.Description = "Ganha " .. PRIZE.Points .. " " .. PS.Config.PointsName .. " e uma caixa aleatória"
PRIZE.Image = "calendar"
PRIZE.GroupId = "lorybr"

function PRIZE:GetStatus(ply)
    local status = ply:GetPData("rewards:steam") or "RESGATAR"

    if status == "VERIFICANDO" and not ply.SteamPrizeSessionLock then
        ply:RemovePData("rewards:steam")
    end

    return status
end

function PRIZE:Redeem(ply)
    ply.SteamPrizeSessionLock = true
    ply:SetPData("rewards:steam", "VERIFICANDO")

    self:FindSteamUser(ply, 1, function()
        ply:SetPData("rewards:steam", "RESGATADO")

        local loot = REWARDS:GetRandomLoot()
        ply:PS_GiveItem(loot.ID)
        ply:PS_GivePoints(self.Points)
        ply:PS_Notify("Você resgatou " .. self.Points .. " " .. PS.Config.PointsName .. " e ganhou uma " .. loot.Name .. " por entrar no nosso grupo steam!")

        REWARDS:SendPrizes(ply)
    end, function()
        ply:RemovePData("rewards:steam")
    end)
end

function PRIZE:FindSteamUser(ply, page, onsuccess, onerror)
    local url = "https://steamcommunity.com/groups/" .. self.GroupId .. "/memberslistxml/?xml=1&p=" .. page .. "&c=" .. CurTime()
    local prize = self

    http.Fetch(url, function(body, len, headers, code)
        if code == 200 then
            local sid64Pattern = "<steamID64>(%d+)</steamID64>"
            local sid64 = ply:SteamID64()

            for k in string.gmatch(body, sid64Pattern) do
                if k == sid64 then
                    return onsuccess()
                end
            end

            if string.match(body, "nextPageLink") then
                prize:FindSteamUser(ply, page + 1, onsuccess, onerror)
            else
                onerror()
            end
        else
            error("Error when trying to get status for user on steam group " .. prize.GroupId .. " (Code: " .. code .. ")")
            onerror()
        end
    end, function(err)
        error("Error when trying to get status for user on steam group " .. prize.GroupId)
        onerror()
    end)
end