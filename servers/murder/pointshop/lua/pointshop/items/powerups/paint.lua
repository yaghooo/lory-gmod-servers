ITEM.Name = "Player Paint"
ITEM.Price = 20000
ITEM.Model = "models/props_junk/metal_paintcan001a.mdl"
ITEM.NoPreview = true
ITEM.AllowedUserGroups = {"superadmin", "admin", "vip", "operator"}

function ITEM:OnEquip(ply, modifications)
    if modifications and modifications.color ~= nil then
        ply.PlayerColor = modifications.color
    end
end

function ITEM:OnHolster(ply)
    ply.PlayerColor = nil
end

function ITEM:Modify(modifications)
    PS:ShowColorChooser(self, modifications)
end

function ITEM:OnModify(ply, modifications)
    self:OnHolster(ply)
    self:OnEquip(ply, modifications)
end