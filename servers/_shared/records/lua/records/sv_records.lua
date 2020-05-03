-- A LOT OF SHITTY CODE PLS REFACT
function RECORDS:LoadRecords()
    self.Records = {}
    local files, _ = file.Find("records/records/*.lua", "LUA")

    for _, name in pairs(files) do
        RECORD = {}
        RECORD.Id = string.gsub(string.lower(name), ".lua", "")
        include("records/records/" .. name)
        self.Records[RECORD.Id] = RECORD
        RECORD = nil
    end
end

function RECORDS:DisplayRecord(ply, record)
    local sid64 = ply:SteamID64()

    for k, v in pairs(self.Records) do
        if record == k or table.HasValue(v.Aliases, record) then
            local records = v:GetRecords()

            for k2, v2 in pairs(records) do
                records[k2].Name = Sid64ToNick(v2.Sid64)
                records[k2].Sid64 = nil
            end

            local user = v:GetUser(sid64)
            net.Start("records_display")
            net.WriteString(v.Name)
            net.WriteString(util.TableToJSON(records) or "")
            net.WriteString(user or "")
            net.Send(ply)

            return
        end
    end

    ply:ChatPrint("Recordes não encontrado para este top!")
end

util.AddNetworkString("records_display")

hook.Add("PlayerSay", "CheckTopSay", function(ply, text, team)
    text = string.lower(text)

    if string.sub(text, 1, 4) == "!top" then
        local record = string.sub(text, 6)

        timer.Simple(0.1, function()
            RECORDS:DisplayRecord(ply, record)
        end)
    end
end)

sql.Query("CREATE TABLE IF NOT EXISTS users ( `sid64` STRING, `name` STRING, PRIMARY KEY(sid64) )")

hook.Add("PlayerInitialSpawn", "RegisterUser", function(ply)
    local sid64 = ply:SteamID64()
    local name = ply:Nick()
    local query = [[INSERT OR REPLACE INTO users VALUES(%s, %s)]]
    sql.Query(string.format(query, sql.SQLStr(sid64), sql.SQLStr(name)))
end)
