ITEM.Name = "Bunny hop"
ITEM.Price = 5000
ITEM.Model = "models/props_junk/garbage_glassbottle003a.mdl"
ITEM.NoPreview = true
ITEM.AllowedUserGroups = {"superadmin", "admin", "vip", "operator", "contributor"}

function ITEM:CanPlayerEquip(ply)
    if ply:PS_HasItemEquipped("doublejump") then
        return "Item não pode ser equipado junto com pulo duplo!"
    end

    return true
end