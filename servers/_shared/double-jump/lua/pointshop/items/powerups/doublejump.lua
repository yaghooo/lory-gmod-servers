ITEM.Name = "Pulo Duplo"
ITEM.Price = 1000
ITEM.Model = "models/props_junk/glassbottle01a.mdl"
ITEM.NoPreview = true

function ITEM:CanPlayerEquip(ply)
    if ply:PS_HasItemEquipped("bhop") then
        return "Item não pode ser equipado junto com bunny hop!"
    end

    return true
end