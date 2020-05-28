ITEM.Name = "Foguete"
ITEM.Price = 6250
ITEM.Model = "models/props_phx/rocket1.mdl"
ITEM.Bone = "ValveBiped.Bip01_Pelvis"
ITEM.AllowedUserGroups = {"superadmin", "admin", "vip", "operator", "contributor"}

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
    local Size = Vector(0.10000000149012, 0.10000000149012, 0.10000000149012)
    local mat = Matrix()
    mat:Scale(Size)
    model:EnableMatrix("RenderMultiply", mat)
    model:SetMaterial("")
    local MAngle = Angle(100.16999816895, 0, 178.42999267578)
    local MPos = Vector(1, 10.430000305176, -13.039999961853)
    pos = pos + (ang:Forward() * MPos.x) + (ang:Up() * MPos.z) + (ang:Right() * MPos.y)
    ang:RotateAroundAxis(ang:Forward(), MAngle.p)
    ang:RotateAroundAxis(ang:Up(), MAngle.y)
    ang:RotateAroundAxis(ang:Right(), MAngle.r)

    return model, pos, ang
end