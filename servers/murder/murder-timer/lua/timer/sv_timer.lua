util.AddNetworkString("startTheTimer")
util.AddNetworkString("stopTheTimer")
util.AddNetworkString("toggleTheTimer")
murderTimer.maxTime = 0

function murderTimer.roundShouldHaveTimer()
    if PowerRounds and PowerRounds.CurrentPR and PowerRounds.CurrentPR.SupressMurderTimer then
        return false
    elseif GAMEMODE and GAMEMODE.RoundStage == 0 then
        return false
    end

    return true
end

function murderTimer.startTimer()
    murderTimer.maxTime = team.NumPlayers(2) > 12 and 480 or 360
    murderTimer.counter = 0

    timer.Create("murderRoundTimer", murderTimer.maxTime, 1, function()
        local murderer = GAMEMODE:GetMurderer()

        local reason = murderer and 2 or 3
        -- Start real timer
        gamemode.Call("EndTheRound", reason, murderer)
    end)

    net.Start("startTheTimer")
    net.WriteInt(murderTimer.maxTime, 32)
    net.WriteInt(0, 32)
    net.Broadcast()

    timer.Create("murderRoundSecondTimer", 1, murderTimer.maxTime, function()
        -- Time server sync
        murderTimer.counter = murderTimer.counter + 1
    end)
end

function murderTimer.stopTimer()
    timer.Stop("murderRoundTimer")
    timer.Stop("murderRoundSecondTimer")
    net.Start("stopTheTimer")
    net.Broadcast()
end

hook.Add("OnStartRound", "theRoundStarted", function()
    timer.Simple(1, function()
        if murderTimer.roundShouldHaveTimer() then
            murderTimer.startTimer()
        end
    end)
end)

-- If the round ends before the timer does, stop the timer
hook.Add("OnEndRound", "theRoundEnded", function()
    murderTimer.stopTimer()
end)

hook.Add("PlayerInitialSpawn", "anPlayerEnteredStartTimer", function()
    timer.Simple(1, function()
        if murderTimer.roundShouldHaveTimer() then
            net.Start("startTheTimer")
            net.WriteInt(murderTimer.maxTime, 32)
            net.WriteInt(murderTimer.counter, 32)
            net.Broadcast()
        end
    end)
end)

function murderTimer.toggleTimer(ply)
    if ply:IsAdmin() then
        timer.Toggle("murderRoundTimer")
        timer.Toggle("murderRoundSecondTimer")
        net.Start("toggleTheTimer")
        net.Broadcast()
    end
end

hook.Add("PlayerSay", "murderTimerChatCommand", function(ply, text, public)
    if ply:IsAdmin() then
        text = string.lower(text)

        if text == "!timer toggle" then
            murderTimer.toggleTimer(ply)
        end
    end
end)