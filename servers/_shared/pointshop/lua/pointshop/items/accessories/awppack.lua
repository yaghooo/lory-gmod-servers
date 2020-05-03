ITEM.Name = "Awp Backpack"
ITEM.Price = 5000
ITEM.Model = "models/weapons/w_snip_awp.mdl"
ITEM.Bone = "ValveBiped.Bip01_Spine2"
ITEM.AllowedUserGroups = {"superadmin", "vip", "admin", "operator"}

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
    model:SetModelScale(0.8, 0)
    pos = pos + (ang:Forward() * 0) + (ang:Up() * 2) + (ang:Right() * 5)
    ang:RotateAroundAxis(ang:Right(), -30)

    return model, pos, ang
end