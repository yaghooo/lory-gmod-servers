AddCSLuaFile("rewards/cl_rewards.lua")
AddCSLuaFile("rewards/cl_rewards_menu.lua")

REWARDS = {}
REWARDS.__index = REWARDS;

if CLIENT then
    include("rewards/cl_rewards.lua")
    include("rewards/cl_rewards_menu.lua")
else
    include("rewards/sv_rewards.lua")
    REWARDS:LoadRewards()
end