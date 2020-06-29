PRIZE.Title = "LOGIN DIÁRIO"
PRIZE.Description = "Ganha uma caixa aleatória"
PRIZE.Image = "calendar"

local function today()
    return os.date("%d/%m/%Y", os.time()
end

function PRIZE:GetStatus(ply)
    local lastRedemption = ply:GetPData("rewards:daily-login")
    if not lastRedemption or lastRedemption != today()) then
        return "RESGATAR"
    end

    return "RESGATADO"
end

function PRIZE:Redeem(ply)
    if ply:SetPData("rewards:daily-login", today()) then
        local loot = REWARDS:GetRandomLoot()
        ply:PS_GiveItem(loot.ID)
        ply:PS_Notify("Você resgatou seu bonus diario e ganhou uma " .. loot.Name .. "!")
        ulx.logString(ply:Nick() .. " received a " .. loot.Name .. " from daily login")
    end
end