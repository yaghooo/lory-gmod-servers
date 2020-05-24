include("sh_init.lua")
util.AddNetworkString("DeathrunChatMessage")
util.AddNetworkString("DeathrunSyncMutelist")
util.AddNetworkString("DeathrunForceSpectator")
local playermodels = {"models/player/group01/male_01.mdl", "models/player/group01/male_02.mdl", "models/player/group01/male_03.mdl", "models/player/group01/male_04.mdl", "models/player/group01/male_05.mdl", "models/player/group01/male_06.mdl", "models/player/group01/male_07.mdl", "models/player/group01/male_08.mdl", "models/player/group01/male_09.mdl", "models/player/group01/female_01.mdl", "models/player/group01/female_02.mdl", "models/player/group01/female_03.mdl", "models/player/group01/female_04.mdl", "models/player/group01/female_05.mdl", "models/player/group01/female_06.mdl"}

hook.Add("PlayerInitialSpawn", "DeathrunPlayerInitialSpawn", function(ply)
    if ROUND:GetTimer() > DR.RoundDuration:GetInt() - DR.RespawnDuration:GetInt() then
        ply:SetTeam(TEAM_RUNNER)
        ply:Spawn()
    else
        ply.FirstSpawn = true
        ply:SetTeam(TEAM_SPECTATOR)
    end
end)

hook.Add("PlayerSpawn", "DeathrunSetPlayerModels", function(ply)
    if ply:Team() == TEAM_DEATH then
        local mdl = DR.DeathModel:GetString()

        if string.sub(mdl, -4, -1) == ".mdl" then
            ply:SetModel(mdl)
        else
            print("The default death model is not a valid .mdl file ('" .. mdl .. "'). Please change the deathrun_death_model ConVar.")
        end
    elseif ply:Team() == TEAM_RUNNER then
        ply:SetModel(table.Random(playermodels))
    end

    local mdl = hook.Call("ChangePlayerModel", nil, ply)

    if mdl then
        ply:SetModel(mdl)
    else
        -- don't override the current set model if there is one
        if not ply:GetModel() or ply:GetModel() == "models/player.mdl" then
            ply:SetModel(table.Random(playermodels))
        end
    end
end)

local function SpawnSpectator(ply)
    ply:KillSilent()
    ply:SetTeam(TEAM_SPECTATOR)
    ply:BeginSpectate()

    return GAMEMODE:PlayerSpawnAsSpectator(ply)
end

hook.Add("PlayerSpawn", "DeathrunPlayerSpawn", function(ply)
    if ply:Team() == TEAM_GHOST then
        ply:ConCommand("deathrun_spectate_only 0")
        ply:StopSpectate()

        return
    end

    if ply:ShouldStaySpectating() then return SpawnSpectator(ply) end
    ply:SetRenderMode(RENDERMODE_TRANSALPHA)
    ply:AllowFlashlight(true)
    ply:SetMoveType(MOVETYPE_WALK)
    ply:SetNoCollideWithTeammates(true) -- so we don't block eachother's bhopes

    if ply.FirstSpawn == true then
        ply.FirstSpawn = false

        if ROUND:GetCurrent() == ROUND_ACTIVE or ROUND:GetCurrent() == ROUND_OVER then
            return SpawnSpectator(ply)
        else
            ply:SetTeam(TEAM_RUNNER)
        end

        hook.Run("PlayerLoadout", ply)
    elseif ply.JustDied == true then
        ply:BeginSpectate()
    elseif ply:ShouldStaySpectating() then
        return SpawnSpectator(ply)
    else
        ply:StopSpectate()
        hook.Run("PlayerLoadout", ply)
    end

    if ply:Team() ~= TEAM_RUNNER and ply:Team() ~= TEAM_DEATH and ply:Team() ~= TEAM_SPECTATOR then
        ply:SetTeam(TEAM_RUNNER)
    end

    local spawns = team.GetSpawnPoints(ply:Team()) or {}

    if #spawns > 0 then
        ply:SetPos(table.Random(spawns):GetPos())
    end
end)

-- if ply:GetSpectate() or ply:Team() == TEAM_SPECTATOR or ply:GetObserverMode() ~= OBS_MODE_NONE then
-- 	return SpawnSpectator( ply )
-- end
function GM:PlayerSpawn(ply)
    return self.BaseClass:PlayerSpawn(ply)
end

function GM:PlayerLoadout(ply)
    ply:StripWeapons()
    ply:StripAmmo()
    ply:Give("weapon_crowbar")

    if ply.CustomKnife then
        ply:Give(ply.CustomKnife)
        ply:SelectWeapon(ply.CustomKnife)
    end

    local teamcol = team.GetColor(ply:Team())
    --print(teamcol)
    local playercol = Vector(teamcol.r / 255, teamcol.g / 255, teamcol.b / 255)
    ply:SetPlayerColor(playercol)
    -- run speeds and jump powah
    ply:SetRunSpeed(250)
    ply:SetWalkSpeed(250)
    ply:SetJumpPower(290)
    ply:SetGravity(1)

    if ply:Team() == TEAM_DEATH then
        ply:SetRunSpeed(650)
    end

    ply:DrawViewModel(true)
    hook.Call("DeathrunPlayerLoadout", self, ply)

    return self.BaseClass:PlayerLoadout(ply)
end

hook.Add("AcceptInput", "DeathrunKillers", function(ent, input, activator, caller)
    ent.LastCaller = caller
end)

function GM:PlayerDeath(ply, inflictor, attacker)
    ply:Extinguish()
    -- some death sounds
    local deathsounds = {"vo/npc/male01/myarm01.wav", "vo/npc/male01/myarm02.wav", "vo/npc/male01/mygut02.wav", "vo/npc/male01/myleg01.wav", "vo/npc/male01/myleg02.wav", "vo/npc/male01/no01.wav", "vo/npc/male01/no02.wav", "vo/npc/male01/ohno.wav", "vo/npc/male01/ow01.wav", "vo/npc/male01/ow02.wav", "vo/npc/male01/pain04.wav", "vo/npc/male01/pain07.wav", "vo/npc/male01/pain08.wav", "vo/npc/male01/pain08.wav", "vo/npc/male01/hacks02.wav"}
    ply:EmitSound(table.Random(deathsounds), 400, 100, 1)
    ply:SetupHands(nil)
    ply:DrawViewModel(false)

    if ply:Team() == TEAM_SPECTATOR then
        ply:Spawn()
        ply:BeginSpectate()

        return
    end

    local shouldRespawn = ROUND:GetTimer() > DR.RoundDuration:GetInt() - DR.RespawnDuration:GetInt()

    timer.Simple(shouldRespawn and 1 or 5, function()
        if not IsValid(ply) then return end -- incase they die and disconnect, prevents console errors.

        if not ply:Alive() then
            if shouldRespawn then
                ply:Spawn()
            else
                ply.JustDied = true
                ply:BeginSpectate()
                local pool = {}

                for k, ply2 in ipairs(player.GetAll()) do
                    if ply2:Alive() and not ply2:GetSpectate() then
                        table.insert(pool, ply2)
                    end
                end

                if #pool > 0 then
                    local randplay = table.Random(pool)
                    ply:SpectateEntity(randplay)
                    ply:SetupHands(randplay)
                    ply:SetObserverMode(OBS_MODE_IN_EYE)
                    ply:SetPos(randplay:GetPos())
                end

                ply.JustDied = nil
                hook.Call("DeathrunDeadToSpectator", GAMEMODE, ply)
            end
        end
    end)
end

function GM:PlayerDeathThink(ply)
    return false
end

function GM:CanPlayerSuicide(ply)
    if not ply:Alive() or ply:GetSpectate() then return false end -- don't let dead players or spectators suicide
    if ply:Team() == TEAM_DEATH or ply:Team() == TEAM_GHOST then return false end -- never allow suicide on death or ghost team
    if ROUND:GetCurrent() == ROUND_PREP then return false end -- players cannot suicide during round prep time

    return self.BaseClass:CanPlayerSuicide(ply)
end

-- damage hooks
function GM:EntityTakeDamage(target, dmginfo)
    local ply = target
    local attacker = dmginfo:GetAttacker()

    if target:IsPlayer() and ROUND:GetCurrent() == ROUND_WAITING or ROUND:GetCurrent() == ROUND_PREP and target.DeathrunChatPrint then
        target:DeathrunChatPrint("Você tomou " .. tostring(dmginfo:GetDamage()) .. " de dano.")
        dmginfo:SetDamage(0)
    end

    if target:IsPlayer() and attacker:IsPlayer() and target:Team() == attacker:Team() and target ~= attacker then
        local od = dmginfo:GetDamage()
        dmginfo:SetDamage(0)
        hook.Call("DeathrunTeamDamage", self, attacker, target, dmginfo, od)
    end

    --damage sounds
    local dmg = dmginfo:GetDamage()

    if dmg > 0 and dmginfo:GetDamageType() == DMG_DROWN then
        local drownsounds = {"player/pl_drown1.wav", "player/pl_drown2.wav", "player/pl_drown3.wav"}
        ply:EmitSound(table.Random(drownsounds), 400, 100, 1)
    end
end

-- player muting
function GM:PlayerCanHearPlayersVoice(listener, talker)
    listener.mutelist = listener.mutelist or {}
    -- dont transmit voices which are on the mutelist

    return not table.HasValue(listener.mutelist, talker:SteamID())
end

-- end player muting
concommand.Add("deathrun_toggle_mute", function(ply, cmd, args)
    local id = args[1]
    if not id then return end
    ply.mutelist = ply.mutelist or {}

    if table.HasValue(ply.mutelist, id) then
        for k, v in ipairs(ply.mutelist) do
            if v == id then
                table.remove(ply.mutelist, k)
                ply:DeathrunChatPrint("Player was unmuted.")
            end
        end
    else
        table.insert(ply.mutelist, id)
        ply:DeathrunChatPrint("Player was muted.")
    end

    net.Start("DeathrunSyncMutelist")
    net.WriteTable(ply.mutelist)
    net.Send(ply)
end)

concommand.Add("strip", function(ply)
    ply:StripWeapons()
end)

function GM:GetFallDamage(ply, speed)
    if ply:Team() == TEAM_GHOST or ply:Team() == TEAM_DEATH then return false end
    local damage = math.max(0, math.ceil(0.2418 * speed - 141.75))

    return damage
end

function GM:OnPlayerHitGround(ply, inWater, onFloater, speed)
    if ply:Team() == TEAM_GHOST then return true end
end

-- Function Key Binds
hook.Add("ShowTeam", "DeathrunSettingsBind", function(ply)
    ply:ConCommand("deathrun_open_settings")
end)

function DR:CanPlayerDropWeapon(ply, class)
    return class ~= weapon_crowbar
end

concommand.Add("deathrun_dropweapon", function(ply, cmd, args)
    local currentWeapon = ply:GetActiveWeapon()

    if ply:Alive() and currentWeapon ~= nil and IsValid(currentWeapon) and DR:CanPlayerDropWeapon(ply, currentWeapon:GetClass()) then
        ply:DropWeapon(currentWeapon)
    end
end)

-- stop people whoring the weapons
hook.Add("PlayerCanPickupWeapon", "StopWeaponAbuseAustraliaSaysNo", function(ply, wep)
    if ply:Team() == TEAM_GHOST then return false end
    local class = wep:GetClass()
    local weps = ply:GetWeapons()
    local wepsclasses = {}
    local slot1, slot3 = 0, 0

    for k, v in ipairs(weps) do
        table.insert(wepsclasses, v:GetClass())

        if v.Slot ~= nil then
            if v.Slot == 1 then
                slot1 = slot1 + 1
            end

            if v.Slot == 3 then
                slot3 = slot3 + 1
            end
        end
    end

    if wep.Slot == 1 and slot1 > 0 then return false end
    if wep.Slot == 3 and slot3 > 0 then return false end
    if table.HasValue(wepsclasses, class) then return false end
end)

-- Something to check how long it's been since the player last did something
hook.Add("SetupMove", "DeathrunIdleCheck", function(ply, mv)
    ply.LastActiveTime = ply.LastActiveTime or CurTime()
    -- when the player stands still, mv:GetButtons() == 0, at least in binary
    -- so we can check when no keys are being pressed, or when they keys haven't changed for a while
    ply.LastButtons = ply.LastButtons or mv:GetButtons()

    if (mv:GetButtons() ~= ply.LastButtons) or (ply:GetObserverMode() ~= OBS_MODE_NONE) then
        -- if there's a change in buttons, then they must not be afk.
        -- sometimes they can type +forward, but we know they are afk because it's constant +forward and no other keys
        ply.LastActiveTime = CurTime()
    end

    ply.LastButtons = mv:GetButtons()
end)

net.Receive("DeathrunForceSpectator", function(len, ply)
    if DR:CanAccessCommand(ply, "deathrun_force_spectate") then
        local targID = net.ReadString()
        local targ = nil

        for _, v in ipairs(player.GetAll()) do
            if targID == v:SteamID() then
                targ = v
            end
        end

        if targ ~= nil then
            targ:ConCommand("deathrun_spectate_only 1")
            ply:DeathrunChatPrint("Forced " .. targ:Nick() .. " to the spectator team!")
        end
    else
        ply:DeathrunChatPrint("Você não tem permissão para isso.")
    end
end)

local removeSpeed = CreateConVar("deathrun_disable_default_deathspeed", 0, defaultFlags, "Removes the player_speedmod entities from maps to disable the default deathspeed.")

function DR:RemoveSpeedMods()
    if removeSpeed:GetBool() == true then
        for k, v in ipairs(ents.FindByClass("player_speedmod")) do
            SafeRemoveEntity(v)
        end
    end
end

hook.Add("PostCleanupMap", "RemoveSpeedMods", function()
    DR:RemoveSpeedMods()
end)

hook.Add("InitPostEntity", "RemoveSpeedMods", function()
    DR:RemoveSpeedMods()
end)