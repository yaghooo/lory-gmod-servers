ITEM.Name = "Laser Shades"
ITEM.Price = 1000
ITEM.Model = "models/props_wasteland/panel_leverHandle001a.mdl"
ITEM.Attachment = "eyes"

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
    model:SetModelScale(1.0, 0)
    pos = pos + (ang:Forward() * -7) + (ang:Up() * 1.8)
    ang:RotateAroundAxis(ang:Right(), -90)

    return model, pos, ang
end