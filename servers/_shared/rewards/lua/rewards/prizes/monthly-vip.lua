PRIZE.Title = "VIP MENSAL"
PRIZE.Points = 60000
PRIZE.Description = "Ganha " .. PRIZE.Points .. " " .. PS.Config.PointsName
PRIZE.Image = "star"

local function currentMonth()
    return os.date("%m/%Y", os.time())
end

function PRIZE:GetStatus(ply)
    if not ply:IsUserGroup("vip") then
        return "COMPRE VIP"
    end

    local lastRedemption = ply:GetPData("rewards:monthly-vip")
    if not lastRedemption or lastRedemption != currentMonth() then
        return "RESGATAR"
    end

    return "RESGATADO"
end

function PRIZE:Redeem(ply)
    if ply:SetPData("rewards:monthly-vip", currentMonth()) then
        ply:PS_GivePoints(self.Points)
        ply:PS_Notify("Você resgatou seu bonus vip de " .. self.Points ..  " " .. PS.Config.PointsName .. "!")
    end
end
