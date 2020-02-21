ITEM.Name = "LOL Trail"
ITEM.Price = 3000
ITEM.Material = "trails/lol.vmt"
ITEM.AllowedUserGroups = {"superadmin", "vip", "admin", "operator"}
ITEM.NoPreview = true

function ITEM:OnEquip(ply, modifications)
    ply.LolTrail = util.SpriteTrail(ply, 0, modifications.color, false, 15, 1, 4, 0.125, self.Material)
end

function ITEM:OnHolster(ply)
    SafeRemoveEntity(ply.LolTrail)
end

function ITEM:Modify(modifications)
    PS:ShowColorChooser(self, modifications)
end

function ITEM:OnModify(ply, modifications)
    SafeRemoveEntity(ply.LolTrail)
    self:OnEquip(ply, modifications)
end
