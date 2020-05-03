ITEM.Name = "Kleiner Glasses"
ITEM.Price = 2000
ITEM.Model = "models/gmod_tower/klienerglasses.mdl"
ITEM.Attachment = "eyes"

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
    --model:SetModelScale(1.6, 0)
    pos = pos + (ang:Forward() * -1.6)
    --ang:RotateAroundAxis(ang:Right(), 90)

    return model, pos, ang
end