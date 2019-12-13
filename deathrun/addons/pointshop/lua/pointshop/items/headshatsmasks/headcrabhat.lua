ITEM.Name = "Headcrab Hat"
ITEM.Price = 1000
ITEM.Model = "models/headcrabclassic.mdl"
ITEM.Attachment = "eyes"
ITEM.AdminOnly = true

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
    model:SetModelScale(0.7, 0)
    pos = pos + (ang:Forward() * 2)
    ang:RotateAroundAxis(ang:Right(), 20)

    return model, pos, ang
end
