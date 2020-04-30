CATEGORY.Name = "Skins"
CATEGORY.Icon = "user"
CATEGORY.AllowedEquipped = 1
CATEGORY.Order = 4

function CATEGORY:OnEquip(ply, modifications, item)
    if not ply.OldModel then
        ply.OldModel = ply:GetModel()
    end

    timer.Simple(1, function()
        ply:SetModel(item.Model)
        ply:SetupHands()

        if modifications.skin ~= nil then
            ply:SetSkin(modifications.skin)
        end

        if modifications.group ~= nil then
            for k, v in pairs(modifications.group) do
                ply:SetBodygroup(k, modifications.group[k])
            end
        end
    end)
end

function CATEGORY:OnHolster(ply)
    if ply.OldModel then
        ply:SetModel(ply.OldModel)
        ply:SetupHands()
    end
end

function CATEGORY:Modify(modifications, item)
    PS:ShowBodygroupChooser(item, modifications)
end

function CATEGORY:OnModify(ply, modifications, item)
    self:OnHolster(ply)
    self:OnEquip(ply, modifications, item)
end