RECORD.Name = PS.Config.PointsName
RECORD.Aliases = {PS.Config.PointsName, "judeu", "judeus"}

function RECORD:GetUser(sid64)
    local result = sql.Query("SELECT points FROM pointshop_points WHERE sid64 = '" .. sid64 .. "'")

    return result and result[1] and result[1]["points"] or 0
end

function RECORD:GetRecords()
    local result = sql.Query("SELECT sid64 as Sid64, points as Value FROM pointshop_points ORDER BY points DESC LIMIT 10")

    return result
end