print("Loaded pointshop support...")

local defaultFlags = FCVAR_SERVER_CAN_EXECUTE + FCVAR_REPLICATED + FCVAR_NOTIFY + FCVAR_ARCHIVE
local PointshopFinishReward = CreateConVar("deathrun_pointshop_finish_reward", 10, defaultFlags, "How many points to award the player when he finishes the map.")
local PointshopKillReward = CreateConVar("deathrun_pointshop_kill_reward", 5, defaultFlags, "How many points to award the player when they kill another player.")
local PointshopWinReward = CreateConVar("deathrun_pointshop_win_reward", 3, defaultFlags, "How many points to award the player when their team wins.")
local PointshopRewardMessage = CreateConVar("deathrun_pointshop_notify", 1, defaultFlags, "Enable chat messages or notifications when rewards are received")

if SERVER then
    function DR:RewardPlayer(ply, amt, reason)
        amt = amt or 0
        ply:PS_GivePoints(amt)

        if PointshopRewardMessage:GetBool() then
            ply:PS_Notify("You were given " .. tostring(amt) .. " points for " .. (reason or "playing") .. "!")
        end
    end

    hook.Add("DeathrunPlayerFinishMap", "PointshopRewards", function(ply, zname, z, place)
        DR:RewardPlayer(ply, PointshopFinishReward:GetInt(), "finishing the map")
    end)

    hook.Add("PlayerDeath", "PointshopRewards", function(ply, inflictor, attacker)
        if attacker:IsPlayer() and ply:Team() ~= attacker:Team() then
            DR:RewardPlayer(attacker, PointshopKillReward:GetInt(), "killing " .. ply:Nick())
        end
    end)

    hook.Add("DeathrunRoundWin", "PointshopRewards", function(winner)
        for k, v in ipairs(player.GetAllPlaying()) do
            if v:Team() == winner then
                DR:RewardPlayer(v, PointshopWinReward:GetInt(), "winning the round")
            end
        end
    end)
end