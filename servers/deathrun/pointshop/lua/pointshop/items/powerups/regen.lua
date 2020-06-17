ITEM.Name = "Regenerar"
ITEM.Price = 250
ITEM.Model = "models/props_combine/health_charger001.mdl"
ITEM.NoPreview = true
ITEM.SingleUse = true

function ITEM:OnBuy(ply)
    timer.Create("Regen_" .. ply:UniqueID(), 0.5, 65, function()
        local newHealth = ply:Health() + 1

        if newHealth <= 100 then
            ply:SetHealth(newHealth)
        end
    end)
end

function ITEM:CanPlayerBuy(ply)
    return ply:Alive()
end