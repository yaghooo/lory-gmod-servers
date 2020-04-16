AddCSLuaFile("rewards/cl_rewards.lua")
AddCSLuaFile("rewards/cl_rewards_menu.lua")
AddCSLuaFile("rewards/cl_rewards_hud.lua")

REWARDS = {}
REWARDS.__index = REWARDS;

if CLIENT then
    include("rewards/cl_rewards.lua")
    include("rewards/cl_rewards_menu.lua")
    include("rewards/cl_rewards_hud.lua")
else
    include("rewards/sv_rewards.lua")
    resource.AddSingleFile("materials/rewards/gift.png")
    REWARDS:LoadRewards()
end