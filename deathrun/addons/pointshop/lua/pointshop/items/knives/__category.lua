CATEGORY.Name = "Facas"
CATEGORY.Icon = "bomb"
CATEGORY.Order = 6
CATEGORY.AllowedEquipped = 1
CATEGORY.Inspectable = true
CATEGORY.Color = Color(255, 215, 0)

function CATEGORY:OnEquip(ply, _, item)
    ply.CustomWeapon = item.WeaponClass
end

function CATEGORY:OnHolster(ply)
    ply.CustomWeapon = nil
end
