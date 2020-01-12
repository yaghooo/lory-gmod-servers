PRIZE.Title = "ENTRE NO GRUPO STEAM"
PRIZE.Description = "Ganha 3.000 pedras e uma caixa aleatória"
PRIZE.Image = "calendar"
PRIZE.GroupId = "lorybr"
PRIZE.Points = 3000

function PRIZE:GetStatus(ply)
    return ply:GetPData("rewards:steam") or "RESGATAR"
end

function PRIZE:Redeem(ply)
    ply:SetPData("rewards:steam", "VERIFICANDO")

    self:FindSteamUser(ply, 1, function()
        ply:SetPData("rewards:steam", "RESGATADO")

        local loot = REWARDS:GetRandomLoot()
        ply:PS_GiveItem(loot.ID)
        ply:PS_GivePoints(self.Points)
        ply:PS_Notify("Você resgatou " .. self.Points .. " " .. PS.Config.PointsName .. " e ganhou uma " .. loot.Name .. " por entrar no nosso grupo steam!")

        REWARDS:SendPrizes(ply)
    end)
end

function PRIZE:FindSteamUser(ply, page, callback)
    local url = "https://steamcommunity.com/groups/" .. self.GroupId .. "/memberslistxml/?xml=1&p=" .. page .. "&c=" .. CurTime()

    http.Fetch(url, function(body, len, headers, code)
        if code == 200 then
            local sid64Pattern = "<steamID64>(%d+)</steamID64>"
            local sid64 = ply:SteamID64()

            for k in string.gmatch(body, sid64Pattern) do
                if k == sid64 then
                    return callback()
                end
            end

            if string.match(body, "nextPageLink") then
                self:FindSteamUser(ply, page + 1)
            end
        else
            error("Error when trying to get status for user on steam group " .. self.GroupId .. " (Code: " .. code .. ")")
        end
    end, function(err)
        error("Error when trying to get status for user on steam group " .. self.GroupId)
    end)
end