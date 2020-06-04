PRIZE.Title = "VIP MENSAL"
PRIZE.Points = 60000
PRIZE.Description = "Ganha " .. PRIZE.Points .. " " .. PS.Config.PointsName
PRIZE.Image = "star"

function PRIZE:GetStatus(ply)
    if not ply:IsUserGroup("vip") then
        return "COMPRE VIP"
    end

    local lastRedemption = ply:GetPData("rewards:monthly-vip")
    if not lastRedemption or lastRedemption != os.date("%m/%Y", os.time()) then
        return "RESGATAR"
    end

    return "RESGATADO"
end

function PRIZE:Redeem(ply)
    ply:SetPData("rewards:monthly-vip", os.date("%m/%Y", os.time()))
    ply:PS_GivePoints(self.Points)
    ply:PS_Notify("Você resgatou seu bonus vip de " .. self.Points ..  " " .. PS.Config.PointsName .. "!")
end
