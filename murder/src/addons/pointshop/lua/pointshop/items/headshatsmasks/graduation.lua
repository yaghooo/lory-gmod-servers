ITEM.Name = "Graduation Cap"
ITEM.Price = 1000
ITEM.Model = "models/player/items/humans/graduation_cap.mdl"
ITEM.Attachment = "eyes"

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
    pos = pos + (ang:Forward() * -4) + (ang:Up() * -0.5)
    --	ang:RotateAroundAxis(ang:Right(), 180)

    return model, pos, ang
end