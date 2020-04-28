CATEGORY.Name = "Trails"
CATEGORY.Icon = "rainbow"
CATEGORY.AllowedEquipped = 2
CATEGORY.Order = 5
CATEGORY.ShouldBeAlive = true

function CATEGORY:OnEquip(ply, modifications, item)
    if not ply.ActiveTrails then
        ply.ActiveTrails = {}
    end

    if GhostMode and ply:IsGhost() then
        return
    end

    local trail = util.SpriteTrail(ply, 0, modifications.color, false, 15, 1, 4, 0.125, item.Material)
    ply.ActiveTrails[item.Name] = trail
end

function CATEGORY:OnHolster(ply, modifications, item)
    if ply.ActiveTrails and ply.ActiveTrails[item.Name] then
        SafeRemoveEntity(ply.ActiveTrails[item.Name])
        ply.ActiveTrails[item.Name] = nil
    end
end

function CATEGORY:Modify(modifications, item)
    PS:ShowColorChooser(item, modifications)
end

function CATEGORY:OnModify(ply, modifications, item)
    self:OnHolster(ply, item)
    self:OnEquip(ply, modifications, item)
end