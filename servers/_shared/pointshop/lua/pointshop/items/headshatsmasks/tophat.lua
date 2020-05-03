ITEM.Name = "Top Hat"
ITEM.Price = 2000
ITEM.Model = "models/gmod_tower/tophat.mdl"
ITEM.Attachment = "eyes"

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
    model:SetModelScale(1.05, 0)
    ang:RotateAroundAxis(ang:Right(), 15)
    pos = pos + (ang:Forward() * -3.5) + (ang:Up() * 2)

    return model, pos, ang
end
