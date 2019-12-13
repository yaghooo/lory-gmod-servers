ITEM.Name = "GBalloon"
ITEM.Price = 2000
ITEM.Model = "models/maxofs2d/balloon_gman.mdl"
ITEM.Attachment = "eyes"

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
    model:SetModelScale(1.0, 0)
    pos = pos + (ang:Forward() * -4.5) + (ang:Up() * -12)
    --	ang:RotateAroundAxis(ang:Right(), 90)

    return model, pos, ang
end
