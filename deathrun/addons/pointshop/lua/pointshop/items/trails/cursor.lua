ITEM.Name = "Mouse Cursor"
ITEM.Price = 3000
ITEM.Material = "trails/cursor.vmt"
ITEM.NoPreview = true

function ITEM:OnEquip(ply, modifications)
    ply.CursorTrail = util.SpriteTrail(ply, 0, modifications.color, false, 15, 1, 4, 0.125, self.Material)
end

function ITEM:OnHolster(ply)
    SafeRemoveEntity(ply.CursorTrail)
end

function ITEM:Modify(modifications)
    PS:ShowColorChooser(self, modifications)
end

function ITEM:OnModify(ply, modifications)
    SafeRemoveEntity(ply.CursorTrail)
    self:OnEquip(ply, modifications)
end
