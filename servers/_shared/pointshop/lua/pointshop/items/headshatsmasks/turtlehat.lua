ITEM.Name = "Turtle Hat"
ITEM.Price = 1000
ITEM.Model = "models/props/de_tides/Vending_turtle.mdl"
ITEM.Attachment = "eyes"
ITEM.AllowedUserGroups = {"superadmin", "admin", "vip", "operator", "contributor"}

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
    pos = pos + (ang:Forward() * -3)
    ang:RotateAroundAxis(ang:Up(), -90)

    return model, pos, ang
end
