ITEM.Name = "Cat Ears"
ITEM.Price = 2000
ITEM.Model = "models/gmod_tower/catears.mdl"
ITEM.Attachment = "eyes"

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
    --model:SetModelScale(1.6, 0)
    pos = pos + (ang:Forward() * -2.5) + (ang:Up() * 2.2)
    --ang:RotateAroundAxis(ang:Right(), 90)

    return model, pos, ang
end