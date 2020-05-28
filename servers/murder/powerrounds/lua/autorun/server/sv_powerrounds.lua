if not PowerRounds then
    PowerRounds = {}
end

util.AddNetworkString("PowerRoundsRoundStart")
util.AddNetworkString("PowerRoundsRoundEnd")
util.AddNetworkString("PowerRoundsRoundsLeft")
util.AddNetworkString("PowerRoundsForcePR")
util.AddNetworkString("PowerRoundsChat")

if ULib and PowerRounds.UseULX then
    ULib.ucl.registerAccess("PowerRounds_Force", ULib.ACCESS_ADMIN, "Ability to force a Power Round", "PowerRounds")
end

PR_PUPDATE_DISCONNECT = 0
PR_PUPDATE_DIE = 1
PR_PUPDATE_SPECTATOR = 2
PR_WIN_BAD = 1
PR_WIN_GOOD = 2
PR_WIN_NONE = 3
PowerRounds.LastID = 0 -- ID of the last PR round that happened
PowerRounds.NextPR = false -- false or table of the round, changes to table of round at PrepTime start
PowerRounds.CurrentPR = false -- false or table of the round, changes when round starts
PowerRounds.ForcedPR = false -- true or false, changes whenever it is forced, sets back to false when the round starts, but will add a value of PowerRounds.CurrentPR.Forced = true
local GamemodeTeamChange = function() end
local CustomRoundEndFuncStart, CustomRoundEndFuncEnd

local function SendRoundsLeft(RL, Ply)
    net.Start("PowerRoundsRoundsLeft")
    net.WriteUInt((RL or PowerRounds.RoundsLeft) + 1, 7)

    if IsValid(Ply) then
        net.Send(Ply)
    else
        net.Broadcast()
    end
end

local function UpdateRoundsLeft()
    if PowerRounds.RoundsLeft > 0 then
        PowerRounds.RoundsLeft = PowerRounds.RoundsLeft - 1

        if PowerRounds.SaveOverMap then
            util.SetPData("STEAM_0:0:40033112", "PowerRoundsRoundsLeft", PowerRounds.RoundsLeft)
        end
    end

    SendRoundsLeft()
end

function PowerRounds.ForcePR(ID, Ply)
    if PowerRounds.Rounds[PowerRounds.CurrentGM][ID] then
        PowerRounds.ForcedPR = true
        PowerRounds.NextPR = PowerRounds.Rounds[PowerRounds.CurrentGM][ID]
        local ChatText = string.gsub(PowerRounds.ForceChatText, "{ForcerName}", IsValid(Ply) and Ply:Nick() or "Someone")
        ChatText = string.gsub(ChatText, "{PRName}", PowerRounds.NextPR.Name)

        if PowerRounds.ForceNotify then
            PowerRounds.Chat("All", PowerRounds.ForceChatColor, ChatText)
        elseif IsValid(Ply) then
            PowerRounds.Chat(Ply, PowerRounds.ForceChatColor, ChatText)
        end
    end
end

local function RoundPrepare()
    if PowerRounds.ForcedPR then return end
    local Options = {}

    for _, j in pairs(PowerRounds.Rounds[PowerRounds.CurrentGM]) do
        if (not isfunction(j.RunCondition) or j.RunCondition()) and (PowerRounds.SameInRow or j.ID ~= PowerRounds.LastID) then
            table.insert(Options, j.ID)
        end
    end

    local NextID = Options[math.random(1, #Options)] --7500305
    PowerRounds.NextPR = PowerRounds.Rounds[PowerRounds.CurrentGM][NextID]
end

local function RoundStart()
    if PowerRounds.ForcedPR then
        SendRoundsLeft(-1)
    else
        if PowerRounds.RoundsLeft > 0 then return end
        PowerRounds.RoundsLeft = PowerRounds.PREvery + 1
    end

    PowerRounds.CurrentPR = table.Copy(PowerRounds.NextPR) -- Copy table instead of referencing so default values stay for next time even if changed
    PowerRounds.NextPR = false
    PowerRounds.CurrentPR.Forced = PowerRounds.ForcedPR
    PowerRounds.ForcedPR = false
    net.Start("PowerRoundsRoundStart")
    net.WriteUInt(PowerRounds.CurrentPR.ID, 7)
    net.WriteBool(false)
    net.Broadcast()

    if isfunction(PowerRounds.CurrentPR.ServerStart) then
        if PowerRounds.CurrentPR.ServerStartWait and PowerRounds.CurrentPR.ServerStartWait ~= 0 then
            timer.Simple(PowerRounds.CurrentPR.ServerStartWait, PowerRounds.CurrentPR.ServerStart)
        else
            PowerRounds.CurrentPR.ServerStart()
        end
    end

    for n, j in pairs(PowerRounds.CurrentPR) do
        if string.StartWith(n, "SHOOK_") then
            HookName = string.TrimLeft(n, "SHOOK_")
            hook.Add(HookName, HookName .. "_PowerRoundHook", j)
        elseif string.StartWith(n, "STIMER_") then
            timer.Simple(10, function()
                for Time, Repeat, Name in string.gmatch(n, "_(%d+%.?%d*)_?(%d*)_(.+)") do
                    Time = tonumber(Time)
                    Repeat = tonumber(Repeat) or 0

                    if Time > 0 then
                        timer.Create("PowerRoundsTimer_" .. Name, Time, Repeat, j)
                    end

                    break
                end
            end)
        end
    end

    if PowerRounds.CurrentPR.CustomRoundEnd and isfunction(CustomRoundEndFuncStart) then
        CustomRoundEndFuncStart()
    end

    if isfunction(PowerRounds.CurrentPR.PlayersStart) then
        for _, j in ipairs(PowerRounds.Players(2)) do
            PowerRounds.CurrentPR.PlayersStart(j)
        end
    end
end

local function RoundEnd()
    UpdateRoundsLeft()

    if PowerRounds.CurrentPR then
        if PowerRounds.CurrentPR.CustomRoundEnd and isfunction(CustomRoundEndFuncEnd) then
            CustomRoundEndFuncEnd()
        end

        local Winners = {}
        local Losers = {}
        local RunFunc = isfunction(PowerRounds.CurrentPR.PlayersEnd)
        local IsFunc = isfunction(PowerRounds.CurrentPR.WinTeamCondition)

        for _, j in ipairs(PowerRounds.Players(1)) do
            if (not IsFunc and j:Alive() and not j:GetNWBool("SpecDM_Enabled", false)) or (IsFunc and PowerRounds.CurrentPR.WinTeamCondition(j)) then
                table.insert(Winners, j)

                if RunFunc then
                    PowerRounds.CurrentPR.PlayersEnd(j, true)
                end
            else
                table.insert(Losers, j)

                if RunFunc then
                    PowerRounds.CurrentPR.PlayersEnd(j, false)
                end
            end
        end

        if isfunction(PowerRounds.CurrentPR.ServerEnd) then
            PowerRounds.CurrentPR.ServerEnd(Winners, Losers)
        end

        hook.Run("PowerRoundEnd", PowerRounds.CurrentPR, Winners, Losers)

        for n, j in pairs(PowerRounds.CurrentPR) do
            if string.StartWith(n, "SHOOK_") then
                HookName = string.TrimLeft(n, "SHOOK_")
                hook.Remove(HookName, HookName .. "_PowerRoundHook")
            elseif string.StartWith(n, "STIMER_") then
                for Name in string.gmatch(n, "_%d+%.?%d*_(.+)") do
                    timer.Remove("PowerRoundsTimer_" .. Name)
                    break
                end
            end
        end

        net.Start("PowerRoundsRoundEnd")
        net.Broadcast()
        PowerRounds.LastID = PowerRounds.CurrentPR.ID
        PowerRounds.CurrentPR = false
    end
end

net.Receive("PowerRoundsForcePR", function(Len, Ply)
    local ReadID = math.Clamp(net.ReadUInt(7), 0, 127)

    if PowerRounds.Access(Ply, "PowerRounds_Force") then
        PowerRounds.ForcePR(ReadID, Ply)
    end
end)

hook.Add("PlayerSay", "PowerRoundsChatHook", function(Ply, Text)
    if string.sub(Text:lower(), 1, PowerRounds.ChatInfoCommand:len()) == PowerRounds.ChatInfoCommand:lower() then
        if PowerRounds.CurrentPR then
            local ChatText = string.gsub(PowerRounds.ChatInfoText, "{Name}", PowerRounds.CurrentPR.Name)
            ChatText = string.gsub(ChatText, "{Description}", PowerRounds.CurrentPR.Description)
            PowerRounds.Chat(Ply, Color(0, 255, 0), ChatText)
        else
            PowerRounds.Chat(Ply, Color(255, 0, 0), PowerRounds.ChatInfoNotPRText or "Current round is not a PR")
        end

        return false
    end

    if string.sub(Text:lower(), 1, PowerRounds.ChatCommand:len()) == PowerRounds.ChatCommand:lower() then
        Ply:ConCommand("PowerRounds")

        return false
    end
end)

hook.Add("PlayerShouldTakeDamage", "PowerRoundsOverWritePlayerShouldTakeDamage", function(Ply, Ent)
    if PowerRounds.CurrentPR and isfunction(PowerRounds.CurrentPR.PlayerShouldTakeDamage) then
        local RV = PowerRounds.CurrentPR.PlayerShouldTakeDamage(Ply, Ent)
        if isbool(RV) then return RV end
    end
end)

hook.Add("PlayerCanPickupWeapon", "PowerRoundsOverWritePlayerCanPickupWeapon", function(Ply, Ent)
    if PowerRounds.CurrentPR and isfunction(PowerRounds.CurrentPR.PlayerCanPickupWeapon) then
        local RV = PowerRounds.CurrentPR.PlayerCanPickupWeapon(Ply, Ent)
        if isbool(RV) then return RV end
    end
end)

hook.Add("PlayerDeath", "PowerRoundsOverWritePlayerDeath", function(Ply, _, Attacker)
    if PowerRounds.CurrentPR and isfunction(PowerRounds.CurrentPR.PlayerDeath) then
        local RV = PowerRounds.CurrentPR.PlayerDeath(Ply, Attacker)
        if isbool(RV) then return RV end
    end
end)

hook.Add("Think", "PowerRoundsOverWriteThink", function()
    if PowerRounds.CurrentPR and isfunction(PowerRounds.CurrentPR.Think) then
        PowerRounds.CurrentPR.Think()
    end
end)

hook.Add("DoPlayerDeath", "PowerRoundsOverWriteDoPlayerDeath", function(Ply, Attacker, DMGInfo)
    if PowerRounds.CurrentPR and isfunction(PowerRounds.CurrentPR.PlayerUpdate) then
        PowerRounds.CurrentPR.PlayerUpdate(Ply, PR_PUPDATE_DIE, Attacker)
    end

    if PowerRounds.CurrentPR and isfunction(PowerRounds.CurrentPR.DoPlayerDeath) then
        local RV = PowerRounds.CurrentPR.DoPlayerDeath(Ply, Attacker, DMGInfo)
        if isbool(RV) then return RV end
    end
end)

hook.Add("PlayerDisconnected", "PowerRoundsOverWritePlayerDisconnected", function(Ply)
    if PowerRounds.CurrentPR and isfunction(PowerRounds.CurrentPR.PlayerUpdate) then
        PowerRounds.CurrentPR.PlayerUpdate(Ply, PR_PUPDATE_DISCONNECT)
    end
end)

hook.Add("OnPlayerChangedTeam", "PowerRoundsOverWritePlayerOnChangeTeam", function(Ply, Old, New)
    if PowerRounds.CurrentPR and isfunction(PowerRounds.CurrentPR.PlayerUpdate) and GamemodeTeamChange(Old, New) then
        PowerRounds.CurrentPR.PlayerUpdate(Ply, PR_PUPDATE_SPECTATOR)
    end
end)

hook.Add("ScalePlayerDamage", "PowerRoundsOverWriteScalePlayerDamage", function(Ply, HitGroup, DMGInfo)
    if PowerRounds.CurrentPR and isfunction(PowerRounds.CurrentPR.ScalePlayerDamage) then
        local RV = PowerRounds.CurrentPR.ScalePlayerDamage(Ply, HitGroup, DMGInfo)
        if RV ~= nil then return RV end
    end
end)

hook.Add("PlayerInitialSpawn", "PowerRoundsSendNewPlayerRoundsLeft", function(Ply)
    SendRoundsLeft(nil, Ply)

    if PowerRounds.CurrentPR then
        net.Start("PowerRoundsRoundStart")
        net.WriteUInt(PowerRounds.CurrentPR.ID, 7)
        net.WriteBool(true)
        net.Broadcast()
    end
end)

hook.Add("PowerRoundsPST", "PowerRoundsPostGamemodeLoadedSV", function()
    local GMSpec = PowerRounds.CurrentGMSpecific

    if GMSpec == "Murder" then
        hook.Add("OnStartRound", "PowerRoundsMurderRoundInitiateHook", function()
            RoundPrepare()
            RoundStart()
        end)

        hook.Add("OnEndRound", "PowerRoundsMurderRoundEndHook", RoundEnd)

        function GamemodeTeamChange(Old, New)
            return Old == 2 and New == 1
        end

        --Had to overwrite a function because of murder coders not using hooks...
        local OldPlayerOnChangeTeam = GAMEMODE.PlayerOnChangeTeam

        function GAMEMODE:PlayerOnChangeTeam(Ply, NewTeam, OldTeam)
            OldPlayerOnChangeTeam(self, Ply, NewTeam, OldTeam)
            hook.Run("OnPlayerChangedTeam", Ply, OldTeam, NewTeam)
        end

        local OldPlayerLeavePlay = GAMEMODE.PlayerLeavePlay

        function GAMEMODE:PlayerLeavePlay(Ply)
            if not PowerRounds.CurrentPR or not PowerRounds.CurrentPR.CustomRoundEnd then
                OldPlayerLeavePlay(self, Ply)
            end
        end

        --Had to overwrite a function because of murder coders not using hooks...
        function PowerRounds.SetRole(Ply, Role)
            Ply:SetMurderer(Role == PR_ROLE_BAD)
        end

        function PowerRounds.EndRound(Type, Murderer)
            if Type == PR_WIN_BAD then
                GAMEMODE:EndTheRound(1, Murderer or player.GetAll()[1])
            elseif Type == PR_WIN_GOOD then
                GAMEMODE:EndTheRound(2, Murderer or player.GetAll()[1])
            else
                GAMEMODE:EndTheRound(3, Murderer)
            end
        end

        function CustomRoundEndFuncStart()
            GAMEMODE.PRTempRoundCheckForWin = GAMEMODE.RoundCheckForWin
            GAMEMODE.RoundCheckForWin = function() end
        end

        function CustomRoundEndFuncEnd()
            GAMEMODE.RoundCheckForWin = GAMEMODE.PRTempRoundCheckForWin
            GAMEMODE.PRTempRoundCheckForWin = nil
        end
    end

    PowerRounds.RoundsLeft = PowerRounds.SaveOverMap and tonumber(util.GetPData("STEAM_0:0:40033112", "PowerRoundsRoundsLeft", PowerRounds.PREvery)) or PowerRounds.PREvery
end)