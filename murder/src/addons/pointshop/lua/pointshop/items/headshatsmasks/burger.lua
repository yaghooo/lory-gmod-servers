ITEM.Name = "Burgar-Brain"
ITEM.Price = 1000
ITEM.Model = "models/food/burger.mdl"
ITEM.Attachment = "eyes"

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
    local Size = Vector(1.5, 1.5, 1.5)
    local mat = Matrix()
    mat:Scale(Size)
    model:EnableMatrix("RenderMultiply", mat)
    model:SetMaterial("")
    pos = pos + (ang:Forward() * -3) + (ang:Up() * -20)

    return model, pos, ang
end