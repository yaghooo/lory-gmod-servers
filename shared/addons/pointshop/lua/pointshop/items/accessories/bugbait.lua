ITEM.Name = "Bosta"
ITEM.Price = 15000
ITEM.Model = "models/weapons/w_bugbait.mdl"
ITEM.WeaponClass = "weapon_bugbait"

function ITEM:OnBuy(ply)
    ply:Give(self.WeaponClass)
    ply:SelectWeapon(self.WeaponClass)
end

function ITEM:OnEquip(ply)
    timer.Simple(1, function()
        ply:Give(self.WeaponClass)
    end)
end

function ITEM:OnSell(ply)
    ply:StripWeapon(self.WeaponClass)
end

function ITEM:OnHolster(ply)
    ply:StripWeapon(self.WeaponClass)
end