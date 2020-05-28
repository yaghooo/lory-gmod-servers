ITEM.Name = "GyroHat"
ITEM.Price = 10000
ITEM.Model = "models/maxofs2d/hover_rings.mdl"
ITEM.Attachment = "eyes"

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
    pos = pos + (ang:Forward() * -3) + (ang:Up() * 2)
    ang:RotateAroundAxis(ang:Right(), 180)

    return model, pos, ang
end