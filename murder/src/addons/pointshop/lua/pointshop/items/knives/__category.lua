CATEGORY.Name = "Facas"
CATEGORY.Icon = "bomb"
CATEGORY.Order = 5
CATEGORY.AllowedEquipped = 1
CATEGORY.Inspectable = true
CATEGORY.Color = Color(255, 215, 0)

function CATEGORY:OnEquip(ply, _, item)
    ply.MurderKnife = item.WeaponClass
end

function CATEGORY:OnHolster(ply)
    ply.MurderKnife = nil
end
