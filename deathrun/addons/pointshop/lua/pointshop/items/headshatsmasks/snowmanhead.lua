ITEM.Name = "Snowman Head"
ITEM.Price = 2000
ITEM.Model = "models/props/cs_office/Snowman_face.mdl"
ITEM.Attachment = "eyes"

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
    pos = pos + (ang:Forward() * -2.2)
    ang:RotateAroundAxis(ang:Up(), -90)

    return model, pos, ang
end

function ITEM:CanPlayerBuy(ply)
    return os.date("%m") == "12" and true or false, "It's not winter!"
end
