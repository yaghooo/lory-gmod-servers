PRIZE.Title = "USE A TAG LORY NO NOME STEAM"
PRIZE.Description = "Ganhe o dobro de pontos e tenha o dobro de chance para dropar caixas"
PRIZE.Image = "clock"
PRIZE.Passive = true

function PRIZE:GetStatus(ply)
    if string.match(string.lower(ply:GetName()), "lory") then
        return "ELEGIVEL"
    else
        return "NÃO ELEGIVEL"
    end
end