ITEM.Name = "No Entry Mask"
ITEM.Price = 500
ITEM.Model = "models/props_c17/streetsign004f.mdl"
ITEM.Attachment = "eyes"

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
    model:SetModelScale(0.7, 0)
    pos = pos + (ang:Forward() * 3)
    ang:RotateAroundAxis(ang:Up(), -90)

    return model, pos, ang
end
