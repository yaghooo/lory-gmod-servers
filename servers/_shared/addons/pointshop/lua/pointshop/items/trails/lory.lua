ITEM.Name = "Lory"
ITEM.Price = 1000
ITEM.Material = "trails/lory.vmt"
ITEM.NoPreview = true

if SERVER then
    resource.AddFile("materials/" .. ITEM.Material)
end

function ITEM:OnEquip(ply, modifications)
    ply.LoryTrail = util.SpriteTrail(ply, 0, modifications.color, false, 15, 1, 4, 0.125, self.Material)
end

function ITEM:OnHolster(ply)
    SafeRemoveEntity(ply.LoryTrail)
end

function ITEM:Modify(modifications)
    PS:ShowColorChooser(self, modifications)
end

function ITEM:OnModify(ply, modifications)
    SafeRemoveEntity(ply.LoryTrail)
    self:OnEquip(ply, modifications)
end
