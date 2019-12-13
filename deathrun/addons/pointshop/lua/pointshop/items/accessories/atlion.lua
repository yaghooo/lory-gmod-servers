ITEM.Name = "Antlion"
ITEM.Price = 1000
ITEM.Model = "models/Gibs/Antlion_gib_Large_2.mdl"
ITEM.Bone = "ValveBiped.Bip01_Spine2"

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
    model:SetModelScale(0.8, 0)
    pos = pos + (ang:Right() * 5) + (ang:Up() * 0) + (ang:Forward() * 6)
    ang:RotateAroundAxis(ang:Forward(), 90)

    return model, pos, ang
end
