ITEM.Name = "Harpoon"
ITEM.Price = 4000
ITEM.Model = "models/props_junk/harpoon002a.mdl"
ITEM.Attachment = "eyes"

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
    model:SetModelScale(0.3, 0)
    pos = pos + (ang:Forward() * -3) + (ang:Up() * -0)
    ang:RotateAroundAxis(ang:Right(), 90)
    ang:RotateAroundAxis(ang:Up(), 108)

    return model, pos, ang
end