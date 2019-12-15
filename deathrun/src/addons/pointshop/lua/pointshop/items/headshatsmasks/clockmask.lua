ITEM.Name = "Clock Mask"
ITEM.Price = 500
ITEM.Model = "models/props_c17/clock01.mdl"
ITEM.Attachment = "eyes"

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
    ang:RotateAroundAxis(ang:Right(), -90)

    return model, pos, ang
end
