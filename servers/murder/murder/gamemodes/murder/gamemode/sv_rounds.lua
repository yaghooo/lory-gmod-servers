util.AddNetworkString("SetRound")
util.AddNetworkString("DeclareWinner")
GM.RoundStage = 0

if GAMEMODE then
    GM.RoundStage = GAMEMODE.RoundStage
end

function GM:GetRound()
    return self.RoundStage or 0
end

function GM:SetRound(round)
    self.RoundStage = round
    self.RoundTime = CurTime()
    self.RoundSettings = {}
    self.RoundSettings.AdminPanelAllowed = self.AdminPanelAllowed:GetBool()
    self.RoundSettings.ShowSpectateInfo = self.ShowSpectateInfo:GetBool()
    self:NetworkRound()
end

function GM:NetworkRound(ply)
    net.Start("SetRound")
    net.WriteUInt(self.RoundStage, 8)
    net.WriteDouble(self.RoundTime)

    if self.RoundSettings then
        net.WriteBool(true)
        net.WriteBool(self.RoundSettings.AdminPanelAllowed)
        net.WriteBool(self.RoundSettings.ShowSpectateInfo)
    else
        net.WriteBool(false)
    end

    if ply == nil then
        net.Broadcast()
    else
        net.Send(ply)
    end
end

-- 0 not enough players
-- 1 playing
-- 2 round ended, about to restart
-- 4 waiting for map switch
function GM:RoundThink()
    local curTime = CurTime()
    if RoundLastThink and RoundLastThink > curTime - 0.5 then return end
    RoundLastThink = curTime
    local players = team.GetPlayers(2)

    if self.RoundStage == 0 and #players > 1 and (not self.LastPlayerSpawn or self.LastPlayerSpawn + 1 < curTime) then
        self:StartNewRound()
    elseif self.RoundStage == 1 then
        if not self.RoundLastDeath or self.RoundLastDeath < curTime then
            self:RoundCheckForWin()
        end

        if self.RoundUnFreezePlayers and self.RoundUnFreezePlayers < curTime then
            self.RoundUnFreezePlayers = nil

            for _, ply in pairs(players) do
                if ply:Alive() then
                    ply:Freeze(false)
                    ply.Frozen = false
                end
            end
        end

        -- after x minutes without a kill reveal the murderer
        local time = self.MurdererFogTime:GetFloat()

        if time > 0 and self.MurdererLastKill and self.MurdererLastKill + time < curTime then
            local murderer = self:GetMurderer()

            if murderer and not murderer:IsMurdererRevealed() then
                murderer:SetMurdererRevealed(true)
                self.MurdererLastKill = nil
            end
        end
    elseif self.RoundStage == 2 and self.RoundTime + 5 < curTime then
        self:StartNewRound()
    end
end

function GM:RoundCheckForWin()
    local players = team.GetPlayers(2)

    if #players <= 0 then
        self:SetRound(0)

        return
    end

    local table_insert = table.insert
    local murderers = {}
    local survivors = {}

    for _, v in pairs(players) do
        if v:IsMurderer() then
            table_insert(murderers, v)
        else
            if v:Alive() then
                table_insert(survivors, v)
            end
        end
    end

    -- check we have a murderer
    if #murderers == 0 then
        self:EndTheRound(3)
        -- has the murderer killed everyone?
    elseif #survivors < 1 then
        self:EndTheRound(1, murderers[1])
    else -- is the murderer dead?
        for k, murderer in ipairs(murderers) do
            if murderer:Alive() then return end -- keep playing.
        end

        self:EndTheRound(2, murderers[1])
    end
end

function GM:DoRoundDeaths(dead, attacker)
    if self.RoundStage == 1 then
        self.RoundLastDeath = CurTime() + 2
    end
end

-- 1 Murderer wins
-- 2 Murderer loses
-- 3 Murderer rage quit
function GM:EndTheRound(reason, murderer)
    if self.RoundStage ~= 1 then return end
    local players = team.GetPlayers(2)

    for _, ply in pairs(players) do
        ply:SetTKer(false)
        ply:SetMurdererRevealed(false)
        ply:UnMurdererDisguise()
    end

    if reason == 3 then
        if murderer then
            local msgs = Translator:AdvVarTranslate(translate.murdererDisconnectKnown, {
                murderer = {
                    text = murderer:Nick() .. ", " .. murderer:GetBystanderName(),
                    color = murderer:GetPlayerColor():ToColor()
                }
            })

            local ct = ChatText(msgs)
            ct:SendAll()
        else
            local ct = ChatText()
            ct:Add(translate.murdererDisconnect)
            ct:SendAll()
        end
    elseif reason == 2 then
        local msgs = Translator:AdvVarTranslate(translate.winBystandersMurdererWas, {
            murderer = {
                text = murderer:Nick() .. ", " .. murderer:GetBystanderName(),
                color = murderer:GetPlayerColor():ToColor()
            }
        })

        local ct = ChatText()
        ct:Add(translate.winBystanders, Color(20, 120, 255))
        ct:AddParts(msgs)
        ct:SendAll()
    elseif reason == 1 then
        local msgs = Translator:AdvVarTranslate(translate.winMurdererMurdererWas, {
            murderer = {
                text = murderer:Nick() .. ", " .. murderer:GetBystanderName(),
                color = murderer:GetPlayerColor():ToColor()
            }
        })

        local ct = ChatText()
        ct:Add(translate.winMurderer, Color(190, 20, 20))
        ct:AddParts(msgs)
        ct:SendAll()
    end

    net.Start("DeclareWinner")
    net.WriteInt(reason, 4)

    if murderer then
        net.WriteEntity(murderer)
        net.WriteVector(murderer:GetPlayerColor())
        net.WriteString(murderer:GetBystanderName())
    else
        net.WriteEntity(Entity(0))
        net.WriteVector(color_white:ToVector())
        net.WriteString("?")
    end

    for _, ply in pairs(team.GetPlayers(2)) do
        net.WriteBool(true)
        net.WriteEntity(ply)
        net.WriteVector(ply:GetPlayerColor())
        net.WriteString(ply:GetBystanderName())
    end

    net.WriteBool(false)
    net.Broadcast()

    for _, ply in pairs(players) do
        if not ply.HasMoved and not ply.Frozen and self.AFKMoveToSpec:GetBool() then
            local oldTeam = ply:Team()
            ply:SetTeam(TEAM_SPECTATOR)
            GAMEMODE:PlayerOnChangeTeam(ply, TEAM_SPECTATOR, oldTeam)

            local msgs = Translator:AdvVarTranslate(translate.teamMovedAFK, {
                player = {
                    text = ply:Nick(),
                    color = ply:GetPlayerColor():ToColor()
                },
                team = {
                    text = team.GetName(TEAM_SPECTATOR),
                    color = team.GetColor(2)
                }
            })

            local ct = ChatText()
            ct:AddParts(msgs)
            ct:SendAll()
        elseif ply:Alive() then
            ply:Freeze(false)
            ply.Frozen = false
        end
    end

    self.RoundUnFreezePlayers = nil
    self.MurdererLastKill = nil
    hook.Call("OnEndRound")
    hook.Run("OnEndRoundResult", reason)
    self:SetRound(2)
end

function GM:StartNewRound()
    local players = team.GetPlayers(2)

    if #players <= 1 then
        local ct = ChatText()
        ct:Add(translate.minimumPlayers, Color(255, 150, 50))
        ct:SendAll()
        self:SetRound(0)

        return
    end

    local ct = ChatText()
    ct:Add(translate.roundStarted)
    ct:SendAll()
    self:SetRound(1)
    self.RoundUnFreezePlayers = CurTime() + 10
    game.CleanUpMap()
    self:InitPostEntityAndMapCleanup()
    self:ClearAllFootsteps()
    local murderer

    -- allow admins to specify next murderer
    if self.ForceNextMurderer and IsValid(self.ForceNextMurderer) and self.ForceNextMurderer:Team() == 2 then
        murderer = self.ForceNextMurderer
        self.ForceNextMurderer = nil
    else
        -- get the weight multiplier
        local weightMul = self.MurdererWeight:GetFloat()
        -- pick a random murderer, weighted
        local rand = WeightedRandom()

        for _, ply in pairs(players) do
            rand:Add(ply.MurdererChance ^ weightMul, ply)
            ply.MurdererChance = ply.MurdererChance + 1
        end

        murderer = rand:Roll()
    end

    local table_insert = table.insert
    local noobs = {}

    for _, ply in pairs(players) do
        ply:UnSpectate()
        ply:StripWeapons()
        ply:KillSilent()
        ply:Spawn()
        ply:Freeze(true)

        if ply ~= murderer then
            ply:SetMurderer(false)
            table_insert(noobs, ply)
        else
            ply:SetMurderer(true)
        end

        local color = ply.PlayerColor or ColorRand()
        ply:SetPlayerColor(Vector(color.r / 255, color.g / 255, color.b / 255))
        ply.LootCollected = 0
        ply.HasMoved = false
        ply.Frozen = true
        ply:SetTKer(false)
        ply:CalculateSpeed()
        ply:GenerateBystanderName()
    end

    if self.ForceNextWeapon and self.ForceNextWeapon ~= murderer then
        self.ForceNextWeapon:Give("weapon_mu_magnum")
        self.ForceNextWeapon = nil
    else
        local magnum = table.Random(noobs)

        if IsValid(magnum) then
            magnum:Give("weapon_mu_magnum")
        end
    end

    self.MurdererLastKill = CurTime()
    hook.Call("OnStartRound")
end

function GM:PlayerLeavePlay(ply)
    if ply:HasWeapon("weapon_mu_magnum") then
        ply:DropWeapon(ply:GetWeapon("weapon_mu_magnum"))
    elseif self.RoundStage == 1 then
        if ply:IsMurderer() then
            self:EndTheRound(3, ply)
        end
    end
end

concommand.Add("mu_forcenextmurderer", function(ply, com, args)
    if not ply:IsAdmin() or #args < 1 then return end
    local ent = Entity(tonumber(args[1]) or -1)

    if not IsValid(ent) or not ent:IsPlayer() then
        ply:ChatPrint("not a player")

        return
    end

    GAMEMODE.ForceNextMurderer = ent

    local msgs = Translator:AdvVarTranslate(translate.adminMurdererSelect, {
        player = {
            text = ent:Nick(),
            color = team.GetColor(2)
        }
    })

    local ct = ChatText()
    ct:AddParts(msgs)
    ct:Send(ply)
end)

concommand.Add("mu_forcenextweapon", function(ply, com, args)
    if not ply:IsAdmin() or #args < 1 then return end
    local ent = Entity(tonumber(args[1]) or -1)

    if not IsValid(ent) or not ent:IsPlayer() then
        ply:ChatPrint("not a player")

        return
    end

    GAMEMODE.ForceNextWeapon = ent

    local msgs = Translator:AdvVarTranslate(translate.adminWeaponSelect, {
        player = {
            text = ent:Nick(),
            color = team.GetColor(2)
        }
    })

    local ct = ChatText()
    ct:AddParts(msgs)
    ct:Send(ply)
end)