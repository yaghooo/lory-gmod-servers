ITEM.Name = "Player Paint"
ITEM.Price = 20000
ITEM.Model = "models/props_junk/metal_paintcan001a.mdl"
ITEM.NoPreview = true

function ITEM:OnEquip(ply, modifications)
    ply.OldColor = ply:GetPlayerColor()

    timer.Simple(1, function()
        if modifications and modifications.color ~= nil then
            newcolor = modifications.color
            ply:SetPlayerColor(Vector(newcolor.r / 255, newcolor.g / 255, newcolor.b / 255))
        end
    end)
end

function ITEM:OnHolster(ply)
    if ply.OldColor then
        ply:SetPlayerColor(ply.OldColor)
    end
end

function ITEM:Modify(modifications)
    PS:ShowColorChooser(self, modifications)
end

function ITEM:OnModify(ply, modifications)
    self:OnHolster(ply)
    self:OnEquip(ply, modifications)
end