CATEGORY.Name = "Acessórios"
CATEGORY.Icon = "bell"
CATEGORY.AllowedEquipped = 2
CATEGORY.Order = 1

function CATEGORY:OnEquip(ply, modifications, item)
    ply:PS_AddClientsideModel(item.ID)
end

function CATEGORY:OnHolster(ply, _, item)
    ply:PS_RemoveClientsideModel(item.ID)
end