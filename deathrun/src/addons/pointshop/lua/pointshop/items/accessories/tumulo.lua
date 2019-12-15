ITEM.Name = "Tumulo"
ITEM.Price = 2000
ITEM.Model = "models/props_c17/gravestone_cross001a.mdl"
ITEM.Bone = "ValveBiped.Bip01_Spine2"

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
    model:SetModelScale(0.264706, 0)
    local PlyModel = ply:GetModel()

    pos = pos + (ang:Forward() * 1) + (ang:Up() * 0) + (ang:Right() * 6.11765)
    ang:RotateAroundAxis(ang:Right(), -90)
    ang:RotateAroundAxis(ang:Up(), 90)
    ang:RotateAroundAxis(ang:Forward(), 0)

    return model, pos, ang
end
