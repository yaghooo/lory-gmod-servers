ITEM.Name = "Super Velocidade"
ITEM.Price = 200
ITEM.Model = "models/props_junk/garbage_glassbottle002a.mdl"
ITEM.NoPreview = true
ITEM.SingleUse = true

function ITEM:OnBuy(ply)
    ply.CanGetRecord = false
    ply.OldWalkSpeed = ply:GetWalkSpeed()
    ply:SetRunSpeed(ply.OldWalkSpeed + 300)

    timer.Simple(20, function()
        ply:SetRunSpeed(ply.OldWalkSpeed)
        ply.OldWalkSpeed = nil
    end)
end

function ITEM:CanPlayerBuy(ply)
    return ply:Alive()
end