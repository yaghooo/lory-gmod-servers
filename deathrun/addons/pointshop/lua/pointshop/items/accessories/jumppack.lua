ITEM.Name = "Jump Pack"
ITEM.Price = 1000
ITEM.Model = "models/xqm/jetengine.mdl"
ITEM.Bone = "ValveBiped.Bip01_Spine2"

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
    model:SetModelScale(0.5, 0)
    pos = pos + (ang:Right() * 7) + (ang:Forward() * 6)

    return model, pos, ang
end
