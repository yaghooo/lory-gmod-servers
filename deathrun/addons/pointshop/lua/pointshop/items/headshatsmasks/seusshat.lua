ITEM.Name = "Seuss Hat"
ITEM.Price = 2000
ITEM.Model = "models/gmod_tower/seusshat.mdl"
ITEM.Attachment = "eyes"

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
    ang:RotateAroundAxis(ang:Right(), 15)
    pos = pos + (ang:Forward() * -3) + (ang:Up() * 2)

    return model, pos, ang
end
