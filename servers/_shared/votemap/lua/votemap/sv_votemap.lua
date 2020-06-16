VOTEMAP.MaxRounds = CreateConVar("votemap_round_limit", 10, FCVAR_NONE, "Max rounds", 1, 1000)
VOTEMAP.RtvRatio = CreateConVar("votemap_rtv_ratio", 0.6, FCVAR_NONE, "Rtv ratio", 0, 1)
VOTEMAP.MaxMaps = CreateConVar("votemap_max_maps", 5, FCVAR_NONE, "Rtv ratio", 3, 10)

VOTEMAP.RoundsPlayed = 0
VOTEMAP.VoteTime = 20
VOTEMAP.RtvVotes = 0
VOTEMAP.Votes = {}

timer.Simple(120, function()
    VOTEMAP.CurrentState = VOTEMAP.READY
end)

function VOTEMAP:WriteToEveryone(msg)
    print("[VOTEMAP] " .. msg)
    timer.Simple(0, function()
        for k, ply2 in ipairs(player.GetAll()) do
            ply2:ChatPrint("[<c=255,68,80>VOTEMAP</c>] " .. msg)
        end
    end)
end

function VOTEMAP:StartMapVote()
    self:WriteToEveryone("<c=255,68,80>Iniciando a votação de mapa...</c>")
    VOTEMAP.CurrentState = VOTEMAP.VOTING

    local maps = table.Copy(self:GetAvailableMaps())
    local nominates = self.NominatedMaps
    local mapQuantity = math.min(#maps, self.MaxMaps:GetInt())
    local mappool = {}

    local lastNominateKey, nomination = nil
    while #mappool < mapQuantity do
        lastNominateKey, nomination = next(nominates, lastNominateKey)
        if nomination ~= nil then
            if not table.HasValue(mappool, nomination) then
                table.insert(mappool, nomination)
                table.RemoveByValue(maps, nomination)
            end
        else
            local mapKey = math.random(#maps)
            table.insert(mappool, table.remove(maps, mapKey))
        end
    end

    net.Start("MAPVOTE_StartVotemap")
    net.WriteTable(mappool)
    net.WriteInt(self.VoteTime, 16)
    net.Broadcast()

    timer.Simple(self.VoteTime + 1, function()
        VOTEMAP.CurrentState = VOTEMAP.FINISHED
        local votes = {}

        for k, v in pairs(VOTEMAP.Votes) do
            local map = mappool[v]
            votes[map] = (votes[map] or 0) + 1
        end

        local winner = table.GetWinningKey(votes)
        if not winner then
            winner = table.Random(mappool)
        end

        VOTEMAP:WriteToEveryone("O mapa vencedor foi <c=255,68,80>" .. winner .. "</c>. Trocando em 5 segundos...")

        timer.Simple(5, function()
            VOTEMAP:ChangeMap(winner)
        end)
    end)
end

function VOTEMAP:ChangeMap(map)
    VOTEMAP:WriteToEveryone("Trocando para o próximo mapa...")
    RunConsoleCommand("changelevel", map)
end

function VOTEMAP:ComputeRoundEnd()
    self.RoundsPlayed = self.RoundsPlayed + 1
    local maxRounds = self.CustomMaxRounds or self.MaxRounds:GetInt()

    if self.RoundsPlayed >= maxRounds and self.CurrentState == self.READY then
        self:StartMapVote()
    end
end

hook.Add("OnEndRound", "ComputeRoundEnd", function()
    VOTEMAP:ComputeRoundEnd()
end)

hook.Add("TTTEndRound", "ComputeRoundEndTTT", function()
    VOTEMAP:ComputeRoundEnd()
end)

hook.Add(hookName, "CheckStartMapVote", function()
    VOTEMAP.RoundsPlayed = VOTEMAP.RoundsPlayed + 1
    local maxRounds = VOTEMAP.CustomMaxRounds or VOTEMAP.MaxRounds:GetInt()

    if VOTEMAP.RoundsPlayed >= maxRounds and VOTEMAP.CurrentState == VOTEMAP.READY then
        VOTEMAP:StartMapVote()
    end
end)

hook.Add("PlayerSay", "VotemapCheckCommands", function(ply, text)
    if text == "!rounds" and (not VOTEMAP.LastRoundCheck or VOTEMAP.LastRoundCheck + 3 < curtime) then
        VOTEMAP.LastRoundCheck = curtime
        VOTEMAP:WriteToEveryone("Faltam <c=255,68,80>" .. (VOTEMAP.CustomMaxRounds or VOTEMAP.MaxRounds:GetInt()) - VOTEMAP.RoundsPlayed .. "</c> rounds para a troca de mapa.")
    elseif text == "!rtv" then
        if VOTEMAP.CurrentState == VOTEMAP.WAITING then
            VOTEMAP:WriteToEveryone("Ainda é muito cedo para dar rtv!")
        elseif not ply.DidRtv and VOTEMAP.CurrentState == VOTEMAP.READY then
            ply.DidRtv = true

            VOTEMAP.RtvVotes = VOTEMAP.RtvVotes + 1
            local rtvNeeded = math.max(0, math.floor(player.GetCount() * VOTEMAP.RtvRatio:GetFloat()) - VOTEMAP.RtvVotes)
            VOTEMAP:WriteToEveryone("<c=255,68,80>" .. ply:Nick() .. "</c> deu rtv, faltam <c=255,68,80>" .. rtvNeeded .. "</c> para iniciar a votação.")

            if rtvNeeded == 0 then
                VOTEMAP:StartMapVote()
            end
        end
    elseif text == "!forcertv" and ply:IsAdmin() then
        VOTEMAP:StartMapVote()
    end
end)

net.Receive("MAPVOTE_MapVote", function(len, ply)
    if VOTEMAP.CurrentState == VOTEMAP.VOTING then
        local chosen = net.ReadInt(16)
        local idx = ply:SteamID()
        VOTEMAP.Votes[idx] = chosen
    end
end)

util.AddNetworkString("MAPVOTE_StartVotemap")
util.AddNetworkString("MAPVOTE_MapVote")