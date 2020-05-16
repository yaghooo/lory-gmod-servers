CATEGORY.Name = "Facas"
CATEGORY.Icon = "bomb"
CATEGORY.Order = 6
CATEGORY.AllowedEquipped = 1
CATEGORY.Color = Color(255, 215, 0)

function CATEGORY:OnEquip(ply, _, item)
    ply.CustomKnife = item.WeaponClass
end

function CATEGORY:OnHolster(ply)
    ply.CustomKnife = nil
end
