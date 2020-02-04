RECORD.Name = "Bom dia"
RECORD.Aliases = {"bom dia"}

function RECORD:GetUser(sid64)
    local result = sql.Query("SELECT bomdias FROM bomdia WHERE sid64 = '" .. sid64 .. "'")
    return result and result[1] and result[1]["bomdias"] or 0
end

function RECORD:GetRecords()
    local result = sql.Query("SELECT sid64 as Sid64, bomdias as Value FROM bomdia ORDER BY bomdias DESC LIMIT 10")
    return result
end