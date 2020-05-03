PRIZE.Title = "LOGIN DIÁRIO"
PRIZE.Description = "Ganha uma caixa aleatória"
PRIZE.Image = "calendar"

function PRIZE:GetStatus(ply)
    local lastRedemption = ply:GetPData("rewards:daily-login")
    if not lastRedemption or lastRedemption != os.date("%d/%m/%Y", os.time()) then
        return "RESGATAR"
    end

    return "RESGATADO"
end

function PRIZE:Redeem(ply)
    ply:SetPData("rewards:daily-login", os.date("%d/%m/%Y", os.time()))
    local loot = REWARDS:GetRandomLoot()
    ply:PS_GiveItem(loot.ID)
    ply:PS_Notify("Você resgatou seu bonus diario e ganhou uma " .. loot.Name .. "!")
end