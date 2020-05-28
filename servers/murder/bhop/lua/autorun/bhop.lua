AddCSLuaFile()

hook.Add("CreateMove", "Billard_Bhop", function(ucmd)
    local client = LocalPlayer()

    if ucmd:KeyDown(IN_JUMP) and PS and client:PS_HasItemEquipped("bhop") and client:WaterLevel() <= 1 and client:GetMoveType() ~= MOVETYPE_LADDER and not client:IsOnGround() then
        ucmd:RemoveKey(IN_JUMP)
    end
end)