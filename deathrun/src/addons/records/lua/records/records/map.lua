RECORD.Name = "Melhor tempo no mapa " .. game.GetMap()
RECORD.Aliases = {"map", "mapa", "", " ", nil}

function RECORD:GetUser(sid64)
    local result = sql.Query("SELECT MIN(seconds) as seconds FROM deathrun_records WHERE sid64 = '" .. sid64 .. "'")

    return result and result[1] and result[1]["seconds"] or 0
end

function RECORD:GetRecords()
    local result = sql.Query("SELECT sid64 as Sid64, MIN(seconds) as Value FROM deathrun_records WHERE mapname = '" .. game.GetMap() .. "' GROUP BY sid64 ORDER BY seconds ASC LIMIT 10")

    return result
end