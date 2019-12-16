ITEM.Name = "Life Preserver"
ITEM.Price = 3000
ITEM.Model = "models/props/de_nuke/LifePreserver.mdl"
ITEM.Bone = "ValveBiped.Bip01_Spine"

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
    model:SetModelScale(0.55, 0)
    pos = pos + (ang:Right() * -2) + (ang:Up() * 0) + (ang:Forward() * 0)

    return model, pos, ang
end