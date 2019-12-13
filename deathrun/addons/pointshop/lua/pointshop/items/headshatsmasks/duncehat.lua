ITEM.Name = "Dunce Hat"
ITEM.Price = 2000
ITEM.Model = "models/duncehat/duncehat.mdl"
ITEM.Attachment = "eyes"

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
    --model:SetModelScale(1.6, 0)
    ang:RotateAroundAxis(ang:Right(), 25)
    pos = pos + (ang:Forward() * -2.8) + (ang:Up() * 2.5)

    return model, pos, ang
end
