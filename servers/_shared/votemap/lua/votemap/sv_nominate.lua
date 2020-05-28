VOTEMAP.NominatedMaps = {}

function VOTEMAP:NominateMap(ply, map)
    local curtime = CurTime()

    if not ply.LastNomination or ply.LastNomination + 3 < curtime then
        ply.LastNomination = curtime

        if table.HasValue(self:GetAvailableMaps(), map) then
            self.NominatedMaps[ply:SteamID()] = map
            self:WriteToEveryone("<c=255,68,80>" .. ply:Nick() .. "</c> nomeou o mapa <c=255,68,80>" .. map .. "</c>.")
        end
    end
end

hook.Add("PlayerSay", "VotemapCheckNominate", function(ply, text)
    if string.StartWith(text, "!nominate") then
        local parts = string.Split(text, " ")

        if parts[2] and parts[2] ~= "" then
            for k, v in ipairs(VOTEMAP:GetAvailableMaps()) do
                if string.find(v, parts[2]) then
                    VOTEMAP:NominateMap(ply, v)
                    return
                end
            end

            ply:ChatPrint("Mapa não encontrado.")
        else
            net.Start("MAPVOTE_OpenNominationSelector")
            net.WriteTable(VOTEMAP:GetMaps())
            net.Send(ply)
        end
    end
end)

net.Receive("MAPVOTE_NominateMap", function(len, ply)
    local map = net.ReadString()
    VOTEMAP:NominateMap(ply, map)
end)

util.AddNetworkString("MAPVOTE_NominateMap")
util.AddNetworkString("MAPVOTE_OpenNominationSelector")