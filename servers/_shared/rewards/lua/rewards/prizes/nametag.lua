PRIZE.Title = "USE A TAG LORY NO NOME STEAM OU COMPRE \"" .. PS.Config.PointsName .. " em Dobro\""
PRIZE.Description = "Ganhe o dobro de " .. PS.Config.PointsName .. " e tenha o dobro de chance para dropar caixas"
PRIZE.Image = "clock"
PRIZE.Passive = true

function PRIZE:GetStatus(ply)
    if ply:PS_IsElegibleForDouble() then
        return "ELEGIVEL"
    else
        return "NÃO ELEGIVEL"
    end
end

hook.Add("PS_ItemUpdated", "PlayerEquippedDoublePoints", function(ply, item_id, type)
    if item_id == "doublepoints" and type == PS_ITEM_EQUIP and not ply.SentNameTag then
        REWARDS:SendPrizes(ply)
        ply.SentNameTag = true
    end
end)