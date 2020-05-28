-- add cs lua all the cl_ or sh_ files
local folders = {(GM or GAMEMODE).Folder:sub(11) .. "/gamemode/"}

for k, folder in pairs(folders) do
    local files, subfolders = file.Find(folder .. "*", "LUA")

    for _, filename in pairs(files) do
        if filename:sub(1, 3) == "cl_" or filename:sub(1, 3) == "sh_" or filename == "shared.lua" or folder:match("/sh_") or folder:match("/cl_") then
            AddCSLuaFile(folder .. filename)
        end
    end

    for _, subfolder in pairs(subfolders) do
        table.insert(folders, folder .. subfolder .. "/")
    end
end

include("sh_translate.lua")
include("shared.lua")
include("weightedrandom.lua")
include("sv_player.lua")
include("sv_spectate.lua")
include("sv_spawns.lua")
include("sv_ragdoll.lua")
include("sv_respawn.lua")
include("sv_murderer.lua")
include("sv_rounds.lua")
include("sv_footsteps.lua")
include("sv_chattext.lua")
include("sv_loot.lua")
include("sv_taunt.lua")
include("sv_bystandername.lua")
include("sv_adminpanel.lua")
include("sv_tker.lua")
include("sv_flashlight.lua")
resource.AddFile("materials/thieves/footprint.vmt")
resource.AddFile("materials/murder/logo.png")
GM.ShowBystanderTKs = CreateConVar("mu_show_bystander_tks", 1, bit.bor(FCVAR_NOTIFY), "Should show name of killer in chat on a bystander team kill")
GM.MurdererFogTime = CreateConVar("mu_murderer_fogtime", 60 * 4, bit.bor(FCVAR_NOTIFY), "Time (in seconds) it takes for a Murderer to show fog for no kills, 0 to disable")
GM.TKPenaltyTime = CreateConVar("mu_tk_penalty_time", 20, bit.bor(FCVAR_NOTIFY), "Time (in seconds) for a bystander to be penalised for a team kill")
GM.LocalChat = CreateConVar("mu_localchat", 0, bit.bor(FCVAR_NOTIFY), "Local chat, when enabled only nearby players can hear other players")
GM.LocalChatRange = CreateConVar("mu_localchat_range", 550, bit.bor(FCVAR_NOTIFY), "The range at which you can hear other players")
GM.CanDisguise = CreateConVar("mu_disguise", 1, bit.bor(FCVAR_NOTIFY), "Whether the murderer can disguise as dead players")
GM.RemoveDisguiseOnKill = CreateConVar("mu_disguise_removeonkill", 1, bit.bor(FCVAR_NOTIFY), "Remove the murderer's disguise when he kills someone")
GM.AFKMoveToSpec = CreateConVar("mu_moveafktospectator", 1, bit.bor(FCVAR_NOTIFY), "Should we move AFK players to spectator on round end")
GM.FlashlightBattery = CreateConVar("mu_flashlight_battery", 10, bit.bor(FCVAR_NOTIFY), "How long the flashlight should last in seconds (0 for infinite)")
GM.Language = CreateConVar("mu_language", "", bit.bor(FCVAR_NOTIFY), "The language Murder should use")
-- replicated
GM.AdminPanelAllowed = CreateConVar("mu_allow_admin_panel", 1, bit.bor(FCVAR_NOTIFY), "Should allow admins to use mu_admin_panel")
GM.ShowSpectateInfo = CreateConVar("mu_show_spectate_info", 1, bit.bor(FCVAR_NOTIFY), "Should show players name and color to spectators")

function GM:Initialize()
    self:LoadSpawns()
    self.DeathRagdolls = {}
    self:StartNewRound()
    self:LoadLootData()
end

function GM:InitPostEntity()
    local canAdd = self:CountLootItems() <= 0

    for _, ent in pairs(ents.FindByClass("mu_loot")) do
        if canAdd then
            self:AddLootItem(ent)
        end
    end

    self:InitPostEntityAndMapCleanup()
end

function GM:InitPostEntityAndMapCleanup()
    for _, ent in ipairs(ents.GetAll()) do
        local class = ent:GetClass()

        if ent:IsWeapon() or class:match("^weapon_") or class:match("^item_") or class == "mu_loot" then
            ent:Remove()
        end
    end
    -- self:SpawnLoot()
end

function GM:Think()
    self:RoundThink()
    self:MurdererThink()
    self:LootThink()
    self:FlashlightThink()

    for _, ply in ipairs(player.GetAll()) do
        if ply:IsCSpectating() and IsValid(ply:GetCSpectatee()) and (not ply.LastSpectatePosSet or ply.LastSpectatePosSet < CurTime()) then
            ply.LastSpectatePosSet = CurTime() + 0.25
            ply:SetPos(ply:GetCSpectatee():GetPos())
        end

        if not ply.HasMoved then
            if ply:IsBot() or ply:KeyDown(IN_FORWARD) or ply:KeyDown(IN_JUMP) or ply:KeyDown(IN_ATTACK) or ply:KeyDown(IN_ATTACK2) or ply:KeyDown(IN_MOVELEFT) or ply:KeyDown(IN_MOVERIGHT) or ply:KeyDown(IN_BACK) or ply:KeyDown(IN_DUCK) then
                ply.HasMoved = true
            end
        end

        if ply.LastTKTime and ply.LastTKTime + self:GetTKPenaltyTime() < CurTime() then
            ply:SetTKer(false)
        end
    end
end

function GM:AllowPlayerPickup(ply, ent)
    return true
end

function GM:PlayerNoClip(ply)
    return ply:GetMoveType() == MOVETYPE_NOCLIP
end

function GM:OnEndRound()
end

function GM:OnStartRound()
end

function GM:EntityTakeDamage(ent, dmginfo)
    -- disable all prop damage
    if (IsValid(dmginfo:GetAttacker()) and (dmginfo:GetAttacker():GetClass() == "prop_physics" or dmginfo:GetAttacker():GetClass() == "prop_physics_multiplayer")) or (IsValid(dmginfo:GetInflictor()) and (dmginfo:GetInflictor():GetClass() == "prop_physics" or dmginfo:GetInflictor():GetClass() == "prop_physics_multiplayer")) then return true end
end

function file.ReadDataAndContent(path)
    return file.Read(path, "DATA")
end

util.AddNetworkString("reopen_round_board")

-- F2
function GM:ShowTeam(ply)
    net.Start("reopen_round_board")
    net.Send(ply)
end

function GM:MaxDeathRagdolls()
    return 20
end