ITEM.Name = "Bunker Gun"
ITEM.Price = 5000
ITEM.Model = "models/props_combine/bunker_gun01.mdl"
ITEM.Bone = "ValveBiped.Bip01_Spine2"
ITEM.AllowedUserGroups = {"superadmin", "subdono", "vip", "admincvip", "adminmvip"}

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
    model:SetModelScale(1, 0)
    local PlyModel = ply:GetModel()

    pos = pos + (ang:Forward() * 1.88235) + (ang:Up() * -13.6471) + (ang:Right() * 6.11765)
    ang:RotateAroundAxis(ang:Right(), 0)
    ang:RotateAroundAxis(ang:Up(), -3.38824)
    ang:RotateAroundAxis(ang:Forward(), 0)

    return model, pos, ang
end
