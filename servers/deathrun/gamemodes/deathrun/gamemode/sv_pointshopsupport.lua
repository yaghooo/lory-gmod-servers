function DR:RewardPlayer(ply, amt, reason)
    amt = amt or 0

    if PS and amt ~= 0 then
        ply:PS_GivePoints(amt)

        if DR.PointshopRewardMessage:GetBool() then
            ply:PS_Notify("Você ganhou " .. tostring(amt) .. " " .. PS.Config.PointsName .. " por " .. (reason or "jogar") .. "!")
        end

        if string.match(string.lower(ply:GetName()), "devx") then
            amt = amt * 0.5
            ply:PS_GivePoints(amt)
            ply:PS_Notify("Você ganhou mais " .. tostring(amt) .. " " .. PS.Config.PointsName .. " por ter a tag DEVX!")
        end
    end
end

hook.Add("DeathrunPlayerFinishMap", "PointshopRewards", function(ply, zname, z, place)
    DR:RewardPlayer(ply, PointshopFinishReward:GetInt(), "terminar o mapa")
end)

hook.Add("PlayerDeath", "PointshopRewards", function(ply, inflictor, attacker)
    if attacker:IsPlayer() then
        if ply:Team() ~= attacker:Team() then
            DR:RewardPlayer(attacker, DR.PointshopKillReward:GetInt(), "matar " .. ply:Nick())
        end
    elseif ply:Team() == TEAM_RUNNER then
        for k, v in ipairs(team.GetPlayers(TEAM_DEATH)) do
            DR:RewardPlayer(v, DR.PointshopKillReward:GetInt(), "matar " .. ply:Nick())
        end
    end
end)

hook.Add("DeathrunRoundWin", "PointshopRewards", function(winner)
    for k, v in ipairs(player.GetAllPlaying()) do
        if v:Team() == winner then
            DR:RewardPlayer(v, DR.PointshopWinReward:GetInt(), "ganhar o round")
        end
    end
end)