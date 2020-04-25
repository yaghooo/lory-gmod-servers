local Player = FindMetaTable("Player")

function Player:BeginSpectate()
    self.Spectating = true
    self.ObsMode = 0
    self:Spectate(OBS_MODE_IN_EYE)
    self.VoluntarySpec = false

    if PS then
        self:PS_PlayerDeath()
    end
end

-- when you want to end spectating immediately
function Player:StopSpectate()
    self.Spectating = false
    self:UnSpectate()
end

-- set whether they should stay in spectator even when the round starts
function Player:SetShouldStaySpectating(bool, noswitch)
    self.StaySpectating = bool

    if bool and not noswitch then
        self:SetTeam(TEAM_SPECTATOR)
    end
end

-- check if he should respawn
function Player:ShouldStaySpectating()
    if self.StaySpectating == nil then
        self.StaySpectating = false
    end

    return self.StaySpectating
end

function Player:GetSpectate()
    return self.Spectating
end

function Player:ChangeSpectate()
    if not self:GetSpectate() then return end

    if not self.ObsMode2 then
        self.ObsMode2 = 0
    end

    self.ObsMode2 = self.ObsMode2 + 1

    if self.ObsMode2 > 2 then
        self.ObsMode2 = 0
    end

    if self.ObsMode2 == 0 then
        self:Spectate(OBS_MODE_ROAMING)
        --because it's nicer
    end

    if self.ObsMode2 == 1 then
        self:Spectate(OBS_MODE_CHASE)
    end

    if self.ObsMode2 == 2 then
        self:Spectate(OBS_MODE_IN_EYE)
    end

    if self.ObsMode2 > 0 then
        --this means we are spectating a player
        local pool = {}

        for k, ply in ipairs(player.GetAll()) do
            if ply:Alive() and not ply:GetSpectate() then
                table.insert(pool, ply)
            end
        end

        --check if they don't already have a spectator target
        local target = self:GetObserverTarget()

        if not target then
            local tidx = math.random(#pool)
            self:SpectateEntity(pool[tidx]) -- iff they don't then give em one
            self:SetupHands(pool[tidx])
        end
    end

    self:SpecModify(0)
    self:SetupHands(self:GetObserverTarget())
end

function Player:SpecModify(n)
    self.SpecEntIdx = self.SpecEntIdx or 1
    local pool = {}

    for k, ply in ipairs(player.GetAll()) do
        if ply:Alive() and not ply:GetSpectate() and not ply:IsGhost() then
            table.insert(pool, ply)
        end
    end

    self.SpecEntIdx = self.SpecEntIdx + n

    if self.SpecEntIdx > #pool then
        self.SpecEntIdx = 1
    end

    if self.SpecEntIdx < 1 then
        self.SpecEntIdx = #pool
    end

    if #pool > 0 and pool[self.SpecEntIdx] then
        self:SpectateEntity(pool[self.SpecEntIdx])
        local target = self:GetObserverTarget()

        if target then
            self:SetPos(target:EyePos() or target:OBBCenter() + target:GetPos())
            self:SetEyeAngles(target:EyeAngles())
        end

        if self:GetObserverMode() == OBS_MODE_IN_EYE then
            self:SetupHands(pool[self.SpecEntIdx])
        else
            self:SetupHands(nil)
        end
    end

    if self:GetObserverMode() ~= OBS_MODE_IN_EYE then
        self:SetupHands(nil)
    end
end

function Player:SpecNext()
    self:SpecModify(1)
end

function Player:SpecPrev()
    self:SpecModify(-1)
end

hook.Add("KeyPress", "DeathrunSpectateChangeObserverMode", function(self, key)
    if self:GetSpectate() then
        if key == IN_JUMP then
            self:ChangeSpectate()
        elseif key == IN_ATTACK then
            -- cycle players forward
            self:SpecNext()
        elseif key == IN_ATTACK2 then
            -- cycle players bacwards
            self:SpecPrev()
        end
    end
end)

concommand.Add("deathrun_toggle_spectate", function(self)
    if not self:GetSpectate() then
        self:BeginSpectate()
        self:SetShouldStaySpectating(true)
    else
        self:SetShouldStaySpectating(false)
    end
end)

concommand.Add("deathrun_set_spectate", function(self, cmd, args)
    if tonumber(args[1]) == 1 then
        self:KillSilent()
        self:SetShouldStaySpectating(true, self:Team() == TEAM_DEATH and true or false)
        self.VoluntarySpec = true
        self:BeginSpectate()
    else
        self:SetShouldStaySpectating(false)

        if ROUND:GetCurrent() == ROUND_WAITING then
            self:KillSilent()
            self:SetTeam(TEAM_RUNNER)
            self:Spawn()
        end
    end
end)

local lastmsg = ""

function Player:DeathrunChatPrint(msg)
    net.Start("DeathrunChatMessage")
    net.WriteString(msg)
    net.Send(self)
    local printmsg = "Server to " .. self:Nick() .. ": " .. msg .. "\n"

    if printmsg ~= lastmsg then
        MsgC(THEME.Color.Primary, printmsg)
        lastmsg = printmsg
    end
end

function DR:ChatBroadcast(msg)
    net.Start("DeathrunChatMessage")
    net.WriteString(msg)
    net.Broadcast()
    MsgC(THEME.Color.Primary, "Server Broadcast: " .. msg .. "\n")
end

timer.Create("MoveSpectatorsToCorrectTeam", 5, 0, function()
    for k, ply in ipairs(player.GetAll()) do
        if ply:Team() ~= TEAM_SPECTATOR and ply:ShouldStaySpectating() then
            ply:SetTeam(TEAM_SPECTATOR)
        end
    end
end)