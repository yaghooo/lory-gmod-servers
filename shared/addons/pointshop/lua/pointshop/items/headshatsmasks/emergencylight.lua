ITEM.Name = "Emergency Hat"
ITEM.Price = 1000
ITEM.Model = "models/props/de_nuke/emergency_lighta.mdl"
ITEM.Attachment = "eyes"

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
    local Size = Vector(0.5, 0.5, 0.5)
    local mat = Matrix()
    mat:Scale(Size)
    model:EnableMatrix("RenderMultiply", mat)
    model:SetMaterial("")
    pos = pos + (ang:Forward() * -4) + (ang:Up() * 8)
    --	ang:RotateAroundAxis(ang:Right(), 180)

    return model, pos, ang
end