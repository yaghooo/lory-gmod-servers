-- record timings
sql.Query("CREATE TABLE IF NOT EXISTS deathrun_records ( sid64 STRING, mapname STRING, seconds REAL )")

hook.Add("DeathrunPlayerFinishMap", "DeathrunMapRecords", function(ply, zname, zone, place, seconds)
    if ply:GetWalkSpeed() ~= ply:GetRunSpeed() then return end
    local sid64 = ply:SteamID64()
    local mapname = game.GetMap()
    sql.Query("INSERT INTO deathrun_records VALUES ('" .. sid64 .. "', '" .. mapname .. "', " .. tostring(seconds) .. ")")
end)

local endmap = nil

local function findendmap()
    if ZONE.zones then
        for k, v in pairs(ZONE.zones) do
            if v.type == "end" then
                endmap = v
            end
        end
    end
end

findendmap()

hook.Add("InitPostEntity", "DeathrunFindEndZone", function()
    findendmap()
end)

hook.Add("DeathrunBeginPrep", "DeathrunSendRecords", function()
    -- deathrun_send_map_records
    local res = sql.Query("SELECT * FROM (SELECT * FROM deathrun_records ORDER BY seconds DESC) WHERE mapname = '" .. game.GetMap() .. "' GROUP BY sid64 ORDER BY seconds LIMIT 3")

    if endmap ~= nil and res ~= false then
        if res == nil then
            res = {}
        else
            for i = 1, #res do
                res[i]["nickname"] = Sid64ToNick(res[i]["sid64"])
                res[i]["value"] = string.ToMinutesSecondsMilliseconds(res[i]["seconds"])
            end
        end

        net.Start("deathrun_send_map_records")
        net.WriteVector(0.5 * (endmap.pos1 + endmap.pos2))
        net.WriteString(util.TableToJSON(res))
        net.Broadcast()
    end

    for k, ply in ipairs(player.GetAll()) do
        local res2 = sql.Query("SELECT * FROM deathrun_records WHERE mapname = '" .. game.GetMap() .. "' AND sid64 = '" .. ply:SteamID64() .. "' ORDER BY seconds ASC LIMIT 1")

        if endmap ~= nil and res2 ~= false then
            local seconds = -1

            if res2 ~= nil and res2[1] and res2[1]["seconds"] then
                seconds = res2[1]["seconds"]
            end

            net.Start("deathrun_send_map_pb")
            net.WriteFloat(seconds)
            net.Send(ply)
        end
    end
end)

util.AddNetworkString("deathrun_send_map_records")
util.AddNetworkString("deathrun_send_map_pb")