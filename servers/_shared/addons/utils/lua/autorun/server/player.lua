sql.Query("CREATE TABLE IF NOT EXISTS users ( `sid64` STRING, `name` STRING, PRIMARY KEY(sid64) )")

hook.Add("PlayerInitialSpawn", "RegisterUser", function(ply)
    local sid64 = ply:SteamID64()
    local name = ply:Nick()
    local query = [[INSERT OR REPLACE INTO users VALUES(%s, %s)]]
    sql.Query(string.format(query, sql.SQLStr(sid64), sql.SQLStr(name)))
end)

function SteamToNick(sid64)
    local result = sql.Query("SELECT name FROM users WHERE sid64='" .. sid64 .. "' LIMIT 1")
    return result and result[1] and result[1]["name"] or "Desconhecido"
end