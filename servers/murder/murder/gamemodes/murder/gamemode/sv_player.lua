util.AddNetworkString("mu_death")
local PlayerMeta = FindMetaTable("Player")
local EntityMeta = FindMetaTable("Entity")

local function generateSpawnEntities(spawnList)
    local function isValid()
        return true
    end

    local function getPos(self)
        return self.pos
    end

    local table_insert = table.insert
    local tbl = {}

    for _, pos in pairs(spawnList) do
        local t = {}
        t.IsValid = isValid
        t.GetPos = getPos
        t.pos = pos
        table_insert(tbl, t)
    end

    return tbl
end

function GM:PlayerInitialSpawn(ply)
    ply.LootCollected = 0
    ply.MurdererChance = 1

    timer.Simple(0, function()
        if IsValid(ply) then
            ply:KillSilent()
        end
    end)

    ply.HasMoved = true
    ply:SetTeam(2)
    self:NetworkRound(ply)
    self.LastPlayerSpawn = CurTime()
    ply:SetPlayerColor(Vector(0.5, 0.5, 0.5))
end

function GM:PlayerSpawn(ply)
    local team = ply:Team()

    -- If the player doesn't have a team
    -- then spawn him as a spectator
    if team == TEAM_SPECTATOR or team == TEAM_UNASSIGNED then
        GAMEMODE:PlayerSpawnAsSpectator(ply)

        return
    end

    -- Stop observer mode
    ply:UnCSpectate()
    ply:SetMurdererRevealed(false)
    ply:SetFlashlightCharge(1)
    player_manager.OnPlayerSpawn(ply)
    player_manager.RunClass(ply, "Spawn")

    timer.Simple(0.1, function()
        hook.Call("PlayerLoadout", GAMEMODE, ply)
        hook.Call("PlayerSetModel", GAMEMODE, ply)
    end)

    ply:CalculateSpeed()
    ply:SetupHands()
    self.MapSpawnPoints = generateSpawnEntities(TeamSpawns["spawns"])
    local spawnPoint = self:PlayerSelectTeamSpawn(team, ply)
    self.MapSpawnPoints = nil

    if IsValid(spawnPoint) then
        ply:SetPos(spawnPoint:GetPos())
    end
end

function GM:PlayerLoadout(ply)
    ply:Give("weapon_mu_hands")

    if ply:IsMurderer() then
        if team.NumPlayers(2) > 12 then
            ply.LastHadKnife = CurTime() - 15
        else
            ply:Give(ply:GetKnife())
        end
    end

    self.BaseClass:PlayerLoadout(ply)
end

local playerModels = {}

local function addModel(model, sex)
    local t = {}
    t.model = model
    t.sex = sex
    table.insert(playerModels, t)
end

addModel("male01", "male")
addModel("male02", "male")
addModel("male03", "male")
addModel("male04", "male")
addModel("male05", "male")
addModel("male06", "male")
addModel("male07", "male")
addModel("male08", "male")
addModel("male09", "male")
addModel("male10", "male")
addModel("male11", "male")
addModel("male12", "male")
addModel("male13", "male")
addModel("male14", "male")
addModel("male15", "male")
addModel("male16", "male")
addModel("male17", "male")
addModel("male18", "male")
addModel("female01", "female")
addModel("female02", "female")
addModel("female03", "female")
addModel("female04", "female")
addModel("female05", "female")
addModel("female06", "female")
addModel("female07", "female")
addModel("female08", "female")
addModel("female09", "female")
addModel("female10", "female")
addModel("female11", "female")
addModel("female12", "female")
addModel("medic01", "male")
addModel("medic02", "male")
addModel("medic03", "male")
addModel("medic04", "male")
addModel("medic05", "male")
addModel("medic06", "male")
addModel("medic07", "male")
addModel("medic08", "male")
addModel("medic09", "male")
addModel("medic10", "female")
addModel("medic11", "female")
addModel("medic12", "female")
addModel("medic13", "female")
addModel("medic14", "female")
addModel("medic15", "female")
addModel("refugee01", "male")
addModel("refugee02", "male")
addModel("refugee03", "male")
addModel("refugee04", "male")
addModel("hostage01", "male")
addModel("hostage02", "male")
addModel("hostage03", "male")
addModel("hostage04", "male")

function GM:PlayerSetModel(ply)
    local modelname = ply.CustomModel
    local modelsex = ply.CustomModelSex

    if not modelname then
        local playerModel = table.Random(playerModels)
        modelname = player_manager.TranslatePlayerModel(playerModel.model)
        modelsex = playerModel.sex
    end

    ply.ModelSex = modelsex
    ply:SetModel(modelname)
end

function GM:DoPlayerDeath(ply, attacker, dmginfo)
    if ply:HasWeapon("weapon_mu_magnum") then
        ply:DropWeapon(ply:GetWeapon("weapon_mu_magnum"))
    end

    ply:UnMurdererDisguise()
    ply:Freeze(false) -- why?, *sigh*
    ply:CreateRagdoll()
    local ent = ply:GetNWEntity("DeathRagdoll")

    if IsValid(ent) then
        ply:CSpectate(OBS_MODE_CHASE, ent)
        ent:SetBystanderName(ply:GetBystanderName())
    end

    ply:AddDeaths(1)

    if attacker:IsValid() and attacker:IsPlayer() then
        if attacker == ply then
            attacker:AddFrags(-1)
        else
            attacker:AddFrags(1)
        end
    end
end

function PlayerMeta:CalculateSpeed()
    -- set the defaults
    local walk, run, canrun = 250, 310, self:IsMurderer()
    local jumppower = 200

    if self:GetTKer() then
        walk = walk * 0.5
        run = run * 0.5
        jumppower = jumppower * 0.5
    end

    local wep = self:GetActiveWeapon()

    if IsValid(wep) and wep.GetCarrying and wep:GetCarrying() then
        walk = walk * 0.3
        run = run * 0.3
        jumppower = jumppower * 0.3
    end

    -- set out new speeds
    self:SetRunSpeed(canrun and run or walk)
    self:SetWalkSpeed(walk)
    self:SetJumpPower(jumppower)
end

function GM:PlayerSelectTeamSpawn(teamId, ply)
    if not self.MapSpawnPoints or table.Count(self.MapSpawnPoints) == 0 then return end

    local spawnPointKey = math.random(#self.MapSpawnPoints)
    local chosenSpawnPoint = table.remove(self.MapSpawnPoints, spawnPointKey)

    if GAMEMODE:IsSpawnpointSuitable(ply, chosenSpawnPoint, false) then
        return chosenSpawnPoint
    end
end

function GM:PlayerDeathSound()
    -- don't play sound
    return true
end

function GM:ScalePlayerDamage(ply, hitgroup, dmginfo)
    -- Don't scale it depending on hitgroup
end

function GM:PlayerDeath(ply, Inflictor, attacker)
    self:DoRoundDeaths(ply, attacker)

    if not ply:IsMurderer() then
        self.MurdererLastKill = CurTime()
        local murderer = self:GetMurderer()

        if IsValid(murderer) then
            murderer:SetMurdererRevealed(false)
        end

        if IsValid(attacker) and attacker:IsPlayer() then
            if attacker:IsMurderer() then
                if self.RemoveDisguiseOnKill:GetBool() then
                    attacker:UnMurdererDisguise()
                end
            elseif attacker ~= ply then
                if self.ShowBystanderTKs:GetBool() then
                    local msgs = Translator:AdvVarTranslate(translate.killedTeamKill, {
                        player = {
                            text = attacker:Nick() .. ", " .. attacker:GetBystanderName(),
                            color = attacker:GetPlayerColor():ToColor()
                        }
                    })

                    local ct = ChatText()
                    ct:AddParts(msgs)
                    ct:SendAll()
                end

                if self:GetRound() ~= 2 and (not PowerRounds or not PowerRounds.CurrentPR or not PowerRounds.CurrentPR.AllowRDM) then
                    local wep = attacker:GetWeapon("weapon_mu_magnum")

                    if IsValid(wep) then
                        attacker:DropWeapon(wep)
                    end

                    if AWarn then
                        AWarn:CreateWarningID(attacker:SteamID64(), nil, "RDM")
                    end

                    attacker:SetTKer(true)
                end
            end
        end
    else
        if attacker ~= ply and IsValid(attacker) and attacker:IsPlayer() then
            local msgs = Translator:AdvVarTranslate(translate.killedMurderer, {
                player = {
                    text = attacker:Nick() .. ", " .. attacker:GetBystanderName(),
                    color = attacker:GetPlayerColor():ToColor()
                }
            })

            local ct = ChatText()
            ct:AddParts(msgs)
            ct:SendAll()
        else
            local ct = ChatText()
            ct:Add(translate.murdererDeathUnknown)
            ct:SendAll()
        end
    end

    local curTime = CurTime()
    ply.NextSpawnTime = curTime + 5
    ply.DeathTime = curTime
    ply.SpectateTime = curTime + 4
    net.Start("mu_death")
    net.WriteUInt(4, 4)
    net.Send(ply)
end

function GM:PlayerDeathThink(ply)
    if self:CanRespawn(ply) then
        ply:Spawn()
    else
        self:ChooseSpectatee(ply)
    end
end

function EntityMeta:GetPlayerColor()
    return self.playerColor or Vector()
end

function EntityMeta:SetPlayerColor(color)
    self.playerColor = color
    self:SetNWVector("playerColor", color)
end

function GM:PlayerFootstep(ply, pos, foot, sound, volume, filter)
    self:FootstepsOnFootstep(ply, pos, foot, sound, volume, filter)
end

function GM:PlayerCanPickupWeapon(ply, wep)
    local wepClass = wep:GetClass()
    if ply:HasWeapon(wepClass) then return false end

    if wepClass == "weapon_mu_magnum" then
        if ply:IsMurderer() then
            return false
        elseif ply:GetTKer() then
            if ply.TempGiveMagnum then
                ply.TempGiveMagnum = nil

                return true
            end

            return false
        end
    elseif string.find(wepClass, "csgo") and not ply:IsMurderer() then
        return false
    end

    return true
end

function GM:PlayerCanHearPlayersVoice(listener, talker)
    return IsValid(talker) and self:PlayerCanHearChatVoice(listener, talker, "voice")
end

function GM:PlayerCanHearChatVoice(listener, talker, typ)
    if self.RoundStage ~= 1 then
        return true
    elseif self.LocalChat:GetBool() then
        if not talker:Alive() or talker:Team() ~= 2 then return not listener:Alive() or listener:Team() ~= 2 end
        local ply = listener

        -- listen as if spectatee when spectating
        if listener:IsCSpectating() and IsValid(listener:GetCSpectatee()) then
            ply = listener:GetCSpectatee()
        end

        local dis = ply:GetPos():Distance(talker:GetPos())
        if dis < self.LocalChatRange:GetFloat() then return true end

        return false
    else
        if not listener:Alive() or listener:Team() ~= 2 then return true end
        if talker:Team() ~= 2 or not talker:Alive() then return false end

        return true
    end
end

function GM:PlayerDisconnected(ply)
    self:PlayerLeavePlay(ply)
end

function GM:PlayerOnChangeTeam(ply, newTeam, oldTeam)
    if oldTeam == 2 then
        self:PlayerLeavePlay(ply)
    end

    ply:SetMurderer(false)
    ply.HasMoved = true
    ply:KillSilent()
end

concommand.Add("mu_jointeam", function(ply, com, args)
    if ply.LastChangeTeam and ply.LastChangeTeam + 5 > CurTime() then return end
    ply.LastChangeTeam = CurTime()
    local curTeam = ply:Team()
    local newTeam = tonumber(args[1] or "") or 0

    if newTeam ~= curTeam then
        ply:SetTeam(newTeam)
        GAMEMODE:PlayerOnChangeTeam(ply, newTeam, curTeam)

        local msgs = Translator:AdvVarTranslate(translate.changeTeam, {
            player = {
                text = ply:Nick(),
                color = team.GetColor(curTeam)
            },
            team = {
                text = team.GetName(newTeam),
                color = team.GetColor(newTeam)
            }
        })

        local ct = ChatText()
        ct:AddParts(msgs)
        ct:SendAll()
    end
end)

concommand.Add("mu_movetospectate", function(ply, com, args)
    if not ply:IsAdmin() then return end
    if #args < 1 then return end
    local ent = Entity(tonumber(args[1]) or -1)
    if not IsValid(ent) or not ent:IsPlayer() then return end
    local curTeam = ent:Team()

    if 1 ~= curTeam then
        ent:SetTeam(TEAM_SPECTATOR)
        GAMEMODE:PlayerOnChangeTeam(ent, TEAM_SPECTATOR, curTeam)

        local msgs = Translator:AdvVarTranslate(translate.teamMoved, {
            player = {
                text = ent:Nick(),
                color = team.GetColor(curTeam)
            },
            team = {
                text = team.GetName(TEAM_SPECTATOR),
                color = team.GetColor(TEAM_SPECTATOR)
            }
        })

        local ct = ChatText()
        ct:AddParts(msgs)
        ct:SendAll()
    end
end)

concommand.Add("mu_spectate", function(ply, com, args)
    if not ply:IsAdmin() or #args < 1 then return end
    local ent = Entity(tonumber(args[1]) or -1)
    if not IsValid(ent) or not ent:IsPlayer() then return end

    if ply:Alive() and ply:Team() ~= 1 then
        local ct = ChatText()
        ct:Add(translate.spectateFailed)
        ct:Send(ply)

        return
    end

    ply:CSpectate(OBS_MODE_IN_EYE, ent)
end)

function GM:PlayerCanSeePlayersChat(text, teamOnly, listener, speaker)
    return IsValid(speaker) and self:PlayerCanHearChatVoice(listener, speaker)
end

function GM:GetTKPenaltyTime()
    return math.max(0, self.TKPenaltyTime:GetFloat())
end

function GM:PlayerUse(ply, ent)
    return true
end

local function pressedUse(ply)
    local tr = ply:GetEyeTraceNoCursor()

    -- press e on windows to break them
    if IsValid(tr.Entity) and tr.HitPos:Distance(tr.StartPos) < 50 then
        if tr.Entity:GetClass() == "func_breakable" then
            local dmg = DamageInfo()
            dmg:SetAttacker(game.GetWorld())
            dmg:SetInflictor(game.GetWorld())
            dmg:SetDamage(10)
            dmg:SetDamageType(DMG_BULLET)
            dmg:SetDamageForce(ply:GetAimVector() * 500)
            dmg:SetDamagePosition(tr.HitPos)
            tr.Entity:TakeDamageInfo(dmg)

            return
        elseif tr.Entity:GetClass() == "func_breakable_surf" then
            tr.Entity:Fire("shatter", "0.5 0.5 4", 0)
        end
    end

    -- disguise as ragdolls
    if IsValid(tr.Entity) and tr.Entity:GetClass() == "prop_ragdoll" and tr.HitPos:Distance(tr.StartPos) < 80 and ply:IsMurderer() and ply:GetLootCollected() >= 1 and (tr.Entity:GetBystanderName() ~= ply:GetBystanderName() or tr.Entity:GetPlayerColor() ~= ply:GetPlayerColor()) then
        ply:MurdererDisguise(tr.Entity)
        ply:SetLootCollected(ply:GetLootCollected() - 1)

        return
    end

    if ply:IsMurderer() then
        -- find closest button to cursor with usable range
        local dot, but

        for _, lbut in pairs(ents.FindByClass("ttt_traitor_button")) do
            if lbut.TraitorButton then
                local vec = lbut:GetPos() - ply:GetShootPos()
                local ldis, ldot = vec:Length(), vec:GetNormal():Dot(ply:GetAimVector())

                if (ldis < lbut:GetUsableRange() and ldot > 0.95) and (not but or ldot > dot) then
                    dis = ldis
                    dot = ldot
                    but = lbut
                end
            end
        end

        if but then
            but:TraitorButtonPressed(ply)

            return
        end
    end
end

function GM:KeyPress(ply, key)
    if key == IN_USE then
        pressedUse(ply)
    end
end

function PlayerMeta:MurdererDisguise(copyent)
    if not self.Disguised then
        self.DisguiseColor = self:GetPlayerColor()
        self.DisguiseName = self:GetBystanderName()
        self.DisguiseModel = self:GetModel()
    end

    if GAMEMODE.CanDisguise:GetBool() then
        self.Disguised = true
        self.DisguisedStart = CurTime()
        self:SetBystanderName(copyent:GetBystanderName())
        self:SetPlayerColor(copyent:GetPlayerColor())
        self:SetModel(copyent:GetModel())
        self:SetupHands()
    else
        self:UnMurdererDisguise()
    end
end

function PlayerMeta:UnMurdererDisguise()
    if self.Disguised then
        self:SetPlayerColor(self.DisguiseColor)
        self:SetBystanderName(self.DisguiseName)
        self:SetModel(self.DisguiseModel)
        self:SetupHands()
    end

    self.Disguised = false
end

function PlayerMeta:IsMurdererDisguised()
    return self.Disguised and true or false
end