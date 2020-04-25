ROUND_WAITING = 3
ROUND_PREP = 4
ROUND_PREPARING = ROUND_PREP
ROUND_ACTIVE = 5
ROUND_OVER = 6
ROUND_ENDING = ROUND_OVER
-- win constants
WIN_STALEMATE = 1
WIN_RUNNER = TEAM_RUNNER
WIN_DEATH = TEAM_DEATH
-- for the round timer
-- have a shared ROUND_TIMER variable which continuously counts down each 0.2 second
-- timer going every 0.2s updating ROUND_TIMER so we have a precision of 1/5th of a second ?????
-- network each time the timer is set, but calculate the timer on server and client individually
ROUND_TIMER = ROUND_TIMER or 0

function ROUND:GetTimer()
    return ROUND_TIMER or 0
end

timer.Create("DeathrunRoundTimerCalculate", 0.2, 0, function()
    ROUND_TIMER = ROUND_TIMER - 0.2

    if ROUND_TIMER < 0 then
        ROUND_TIMER = 0
    end
end)

if SERVER then
    util.AddNetworkString("DeathrunSyncRoundTimer")
    util.AddNetworkString("DeathrunSendMVPs")

    function ROUND:SyncTimer()
        net.Start("DeathrunSyncRoundTimer")
        net.WriteInt(ROUND:GetTimer(), 16)
        net.Broadcast()
    end

    function ROUND:SyncTimerPlayer(ply)
        net.Start("DeathrunSyncRoundTimer")
        net.WriteInt(ROUND:GetTimer(), 16)
        net.Send(ply)
    end

    function ROUND:SetTimer(s)
        ROUND_TIMER = s
        ROUND:SyncTimer()
    end
else
    net.Receive("DeathrunSyncRoundTimer", function(len, ply)
        ROUND_TIMER = net.ReadInt(16)
    end)
end

hook.Add("PlayerInitialSpawn", "DeathrunCleanupSinglePlayer", function(ply)
    ROUND:SyncTimerPlayer(ply)

    if player.GetCount() <= 1 then
        game.CleanUpMap()
        DR:ChatBroadcast("Cleaned up the map.")
    end
end)

ROUND:AddState(ROUND_WAITING, function()
    print("Round State: WAITING")
    hook.Call("DeathrunBeginWaiting", nil)

    if SERVER then
        for k, ply in ipairs(player.GetAllPlaying()) do
            ply:StripWeapons()
            ply:StripAmmo()
            ply:SetTeam(TEAM_RUNNER)
            ply:Spawn()
        end

        timer.Create("DeathrunWaitingStateCheck", 5, 0, function()
            if #player.GetAllPlaying() >= 2 then
                ROUND:RoundSwitch(ROUND_PREP)
                timer.Remove("DeathrunWaitingStateCheck")
            end
        end)
    end
end, function() end, function()
    --thinking
    print("Exiting: WAITING")
end)

ROUND:AddState(ROUND_PREP, function()
    print("Round State: PREP")
    hook.Call("DeathrunBeginPrep", nil)

    if CLIENT then
        surface.PlaySound("ui/achievement_earned.wav") -- round start cue
    end

    if SERVER then
        game.CleanUpMap()

        timer.Simple(DR.PrepDuration:GetInt(), function()
            ROUND:RoundSwitch(ROUND_ACTIVE)
        end)

        ROUND:SetTimer(DR.PrepDuration:GetInt())

        for k, ply in ipairs(player.GetAll()) do
            -- for some reason we need to do this otherwise people spawn as spec when they shouldnt!
            if not ply:ShouldStaySpectating() then
                ply:KillSilent()
                ply:SetTeam(TEAM_RUNNER)
            end
        end

        -- let's pick deaths at random, but ignore if they have been death the 2 previous rounds
        local deaths = {}
        local runners = table.Copy(player.GetAllPlaying())

        local deathsNeeded = math.min(math.ceil(DR.DeathRatio:GetFloat() * #player.GetAllPlaying()), DR.DeathMax:GetInt())

        while #deaths < deathsNeeded do
            local _, rkey = table.Random(runners)
            table.insert(deaths, table.remove(runners, rkey))
        end

        --now, spawn all deaths
        for k, death in ipairs(deaths) do
            death:StripWeapons()
            death:StripAmmo()
            death:SetTeam(TEAM_DEATH)
            death:Spawn()
        end

        --now, spawn all runners
        for k, runner in ipairs(runners) do
            runner:StripWeapons()
            runner:StripAmmo()
            runner:SetTeam(TEAM_RUNNER)
            runner:Spawn()
        end

        -- make sure nobody is dead??????
        for k, v in ipairs(player.GetAllPlaying()) do
            if not v:Alive() then
                v:Spawn()
            end
        end
    end
end, function() end, function()
    print("Exiting: PREP")
end)

ROUND:AddState(ROUND_ACTIVE, function()
    print("Round State: ACTIVE")
    hook.Call("DeathrunBeginActive", nil)

    if SERVER then
        ROUND:SetTimer(DR.RoundDuration:GetInt())
    end
end, function()
    if SERVER then
        local playing = player.GetAllPlaying()

        if #playing < 2 then
            ROUND:RoundSwitch(ROUND_WAITING)

            return
        end

        local deaths = {}
        local runners = {}

        for k, v in ipairs(playing) do
            if v:Alive() then
                if v:Team() == TEAM_RUNNER then
                    table.insert(runners, v)
                elseif v:Team() == TEAM_DEATH then
                    table.insert(deaths, v)
                end
            end
        end

        if (#deaths == 0 and #runners == 0) or ROUND:GetTimer() == 0 then
            ROUND:FinishRound(WIN_STALEMATE)
        elseif #deaths == 0 then
            ROUND:FinishRound(WIN_RUNNER)
        elseif #runners == 0 then
            ROUND:FinishRound(WIN_DEATH)
        end
    end
end, function()
    print("Exiting: ACTIVE")
end)

ROUND:AddState(ROUND_OVER, function()
    print("Round State: OVER")
    hook.Call("DeathrunBeginOver", nil)

    if SERVER then
        ROUND:SetTimer(DR.FinishDuration:GetInt())

        timer.Simple(DR.FinishDuration:GetInt(), function()
            ROUND:RoundSwitch(ROUND_PREP)
        end)
    end
end, function() end, function()
    --thinking
    print("Exiting: OVER")
end)

if SERVER then
    hook.Add("PlayerDeath", "DeathrunMVPs", function(ply, inflictor, attacker)
        if attacker:IsPlayer() then
            attacker.KillsThisRound = attacker.KillsThisRound or 0

            if ply ~= attacker then
                attacker.KillsThisRound = attacker.KillsThisRound + 1
            end
        end
    end)

    hook.Add("DeathrunBeginActive", "DeathrunMVPs", function()
        for k, v in ipairs(player.GetAll()) do
            v.KillsThisRound = 0
        end
    end)

    function ROUND:FinishRound(winteam)
        ROUND:RoundSwitch(ROUND_OVER)
        DR:ChatBroadcast("Round acabou! " .. (winteam == WIN_RUNNER and team.GetName(TEAM_RUNNER) .. " venceram!" or winteam == WIN_DEATH and team.GetName(TEAM_DEATH) .. " venceram!" or "Empate! Não acredito..."))
        --calculate MVPs
        net.Start("DeathrunSendMVPs")
        local mvps = {}
        local mostkills = 0
        local mostkillsmvp = nil
        local players = player.GetAll()

        for k, v in ipairs(players) do
            if v:Team() == winteam then
                if v:Alive() then
                    table.insert(mvps, v:Nick() .. " sobreviveu o round!")
                end

                if v.KillsThisRound > mostkills then
                    mostkills = v.KillsThisRound
                    mostkillsmvp = v
                end
            end
        end

        if mostkillsmvp and winteam == TEAM_RUNNER then
            table.insert(mvps, mostkillsmvp:Nick() .. " conseguiu " .. mostkills .. (mostkills > 1 and " kills!" or " kill!"))
        end

        local data = {}
        data.mvps = table.Copy(mvps)
        data.duration = DR.FinishDuration:GetInt() -- how long we want to show this screen for, in seconds (temporary?)
        data.winteam = winteam
        net.WriteTable(data)
        net.Broadcast()
        hook.Call("DeathrunRoundWin", nil, winteam)
        hook.Run("OnEndRound")
        -- compatibility
        hook.Call("OnRoundSet", nil, ROUND_OVER, winteam ~= WIN_STALEMATE and winteam or 123)
    end

    --initial round
    hook.Add("InitPostEntity", "DeathrunInitialRoundState", function()
        ROUND:RoundSwitch(ROUND_WAITING)
    end)
end

hook.Add("DeathrunPlayerFinishMap", "Balloons", function(ply)
    for i = 1, 12 do
        local dir = Vector(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100))
        dir:Normalize()
        local balloon = ents.Create("ent_deathrun_balloon")
        balloon:Spawn()
        balloon:SetAngles(Angle(0, math.random(-180, 180), 0))

        local td = {
            start = ply:GetShootPos(),
            endpos = ply:GetShootPos() + dir * 92,
            filter = ply,
            mins = balloon:OBBMins(),
            maxs = balloon:OBBMaxs()
        }

        local tr = util.TraceHull(td)

        if tr.HitPos:Distance(td.start) > 30 then
            balloon:SetPos(tr.HitPos)
            balloon:GetPhysicsObject():ApplyForceCenter(dir * 2.5)
        else
            balloon:Remove()
        end
    end
end)