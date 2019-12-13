ITEM.Name = "Gentleman shoes"
ITEM.Price = 3000
ITEM.Material = "trails/shoes.vmt"
ITEM.NoPreview = true

function ITEM:OnEquip(ply, modifications)
    ply.ShoesTrail = util.SpriteTrail(ply, 0, modifications.color, false, 15, 1, 4, 0.125, self.Material)
end

function ITEM:OnHolster(ply)
    SafeRemoveEntity(ply.ShoesTrail)
end

function ITEM:Modify(modifications)
    PS:ShowColorChooser(self, modifications)
end

function ITEM:OnModify(ply, modifications)
    SafeRemoveEntity(ply.ShoesTrail)
    self:OnEquip(ply, modifications)
end
