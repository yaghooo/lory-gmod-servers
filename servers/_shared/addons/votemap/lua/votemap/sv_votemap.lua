VOTEMAP.MaxRounds = CreateConVar("votemap_round_limit", 10, FCVAR_NONE, "Max rounds", 1, 1000)
VOTEMAP.RtvRatio = CreateConVar("votemap_rtv_ratio", 0.6, FCVAR_NONE, "Rtv ratio", 0, 1)
VOTEMAP.MaxMaps = CreateConVar("votemap_max_maps", 5, FCVAR_NONE, "Rtv ratio", 3, 10)
VOTEMAP.RoundsPlayed = 0
VOTEMAP.VoteTime = 20
VOTEMAP.Votes = {}
VOTEMAP.RtvVotes = {}

timer.Simple(1, function()
    VOTEMAP.Maps = ulx.votemaps
end)

function VOTEMAP:GetMaps()
    return VOTEMAP.Maps
end

function VOTEMAP:GetAvailableMaps()
    return VOTEMAP.Maps
end

function VOTEMAP:WriteToEveryone(msg)
    timer.Simple(0, function()
        for k, ply2 in ipairs(player.GetAll()) do
            ply2:ChatPrint("[<c=255,68,80>VOTEMAP</c>] " .. msg)
        end
    end)
end

function VOTEMAP:StartMapVote()
    self:WriteToEveryone("<c=255,68,80>Iniciando a votação de mapa...</c>")
    self.Started = true
    local maps = table.Copy(self:GetAvailableMaps())
    local nominates = self.NominatedMaps
    local mapQuantity = math.min(#maps, self.MaxMaps:GetInt())
    local mappool = {}

    while #mappool < mapQuantity do
        if #nominates ~= 0 then
            table.insert(mappool, table.remove(nominates))
        else
            local _, selectedMapKey = table.Random(maps)
            table.insert(mappool, table.remove(maps, selectedMapKey))
        end
    end

    net.Start("MAPVOTE_StartVotemap")
    net.WriteTable(mappool)
    net.WriteInt(self.VoteTime, 16)
    net.Broadcast()
    self.MapPool = mappool

    timer.Simple(self.VoteTime + 1, function()
        VOTEMAP.Finished = true

        local votes = {}
        for k, v in pairs(VOTEMAP.Votes) do
            local map = mappool[v]
            votes[map] = (votes[map] or 0) + 1
        end

        local winner = table.GetWinningKey(votes)
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

hook.Add("OnEndRound", "CheckStartMapVote", function()
    VOTEMAP.RoundsPlayed = VOTEMAP.RoundsPlayed + 1
    local maxRounds = VOTEMAP.CustomMaxRounds or VOTEMAP.MaxRounds:GetInt()

    if VOTEMAP.RoundsPlayed >= maxRounds and not VOTEMAP.Started then
        VOTEMAP:StartMapVote()
    end
end)

hook.Add("PlayerSay", "VotemapCheckCommands", function(ply, text)
    if text == "!rounds" and (not VOTEMAP.LastRoundCheck or VOTEMAP.LastRoundCheck + 3 < curtime) then
        VOTEMAP.LastRoundCheck = curtime
        VOTEMAP:WriteToEveryone("Faltam <c=255,68,80>" .. (VOTEMAP.CustomMaxRounds or VOTEMAP.MaxRounds:GetInt()) - VOTEMAP.RoundsPlayed .. "</c> rounds para a troca de mapa.")
    elseif text == "!rtv" and not VOTEMAP.Started then
        local idx = ply:SteamID()

        if not VOTEMAP.RtvVotes[idx] then
            VOTEMAP.RtvVotes[idx] = true
            local rtvNeeded = math.max(0, math.floor(player.GetCount() * VOTEMAP.RtvRatio:GetFloat()) - #VOTEMAP.RtvVotes)
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
    if VOTEMAP.Started and not VOTEMAP.Finished then
        local chosen = net.ReadInt(16)
        local idx = ply:SteamID()
        VOTEMAP.Votes[idx] = chosen
    end
end)

util.AddNetworkString("MAPVOTE_StartVotemap")
util.AddNetworkString("MAPVOTE_MapVote")