PRIZE.Title = "REGISTRE-SE NO DISCORD ~ DIGITE !registrar"
PRIZE.Points = 5000
PRIZE.Description = "Ganha " .. PRIZE.Points .. " " .. PS.Config.PointsName .. " e uma caixa aleatória"
PRIZE.Image = "discord"

function PRIZE:GetStatus(ply)
    return ply:GetPData("rewards:discord") or (ply.DiscordPrizeSessionLock and "NÃO REGISTRADO") or "RESGATAR"
end

function PRIZE:Redeem(ply)
    ply.DiscordPrizeSessionLock = true
    local isRegistered = DISCORD:IsRegistered(ply:SteamID64())

    if isRegistered then
        ply:SetPData("rewards:discord", "RESGATADO")
        local loot = REWARDS:GetRandomLoot()
        ply:PS_GiveItem(loot.ID)
        ply:PS_GivePoints(self.Points)
        ply:PS_Notify("Você resgatou " .. self.Points .. " " .. PS.Config.PointsName .. " e ganhou uma " .. loot.Name .. " por entrar no nosso grupo steam!")
    end
end

hook.Add("DISCORD_Register", "PlayerRegisteredPrizeReset", function(sid64)
    local ply = player.GetBySteamID64(sid64)

    if IsValid(ply) then
        ply.DiscordPrizeSessionLock = nil
        REWARDS:SendPrizes(ply)
    end
end)