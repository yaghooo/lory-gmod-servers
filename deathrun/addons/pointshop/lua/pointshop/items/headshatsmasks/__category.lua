CATEGORY.Name = "Chapéus, Cabeças e Máscaras"
CATEGORY.Icon = "emoticon_smile"
CATEGORY.AllowedEquipped = 2
CATEGORY.Order = 2

function CATEGORY:OnEquip(ply, modifications, item)
    ply:PS_AddClientsideModel(item.ID)
end

function CATEGORY:OnHolster(ply, _, item)
    ply:PS_RemoveClientsideModel(item.ID)
end
