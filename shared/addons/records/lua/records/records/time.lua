RECORD.Name = "Viciados"
RECORD.Aliases = {"vicio", "tempo", "time", "viciados"}

function RECORD:GetUser(sid64)
    local result = sql.Query("SELECT totaltime FROM utime WHERE player = '" .. sid64 .. "'")

    if result and result[1] and result[1]["totaltime"] then
        return timeToStr(result[1]["totaltime"])
    else
        return timeToStr(0)
    end
end

function RECORD:GetRecords()
    local result = sql.Query("SELECT player as Sid64, totaltime as Value FROM utime ORDER BY totaltime DESC LIMIT 10")

    for i = 1, #result do
        result[i].Value = timeToStr(result[i].Value)
    end

    return result
end

function timeToStr(time)
    local tmp = time
    local s = tmp % 60
    tmp = math.floor(tmp / 60)
    local m = tmp % 60
    tmp = math.floor(tmp / 60)
    local h = tmp % 24
    tmp = math.floor(tmp / 24)
    local d = tmp % 7
    local w = math.floor(tmp / 7)

    return string.format("%02iw %id %02ih %02im %02is", w, d, h, m, s)
end