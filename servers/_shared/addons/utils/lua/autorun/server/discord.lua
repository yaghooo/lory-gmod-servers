sql.Query("CREATE TABLE IF NOT EXISTS users_discord ( `sid64` STRING, `discord` STRING, PRIMARY KEY(sid64) )")

DISCORD = {}
DISCORD.__index = DISCORD

function DISCORD:IsRegistered(sid64)
    local result = sql.Query("SELECT discord FROM users_discord WHERE sid64='" .. sid64 .. "' LIMIT 1")
    return (result and result[1]) ~= nil
end

concommand.Add("register_discord", function(_, __, args)
    local id64 = args[1]
    local discordId = args[2]

    if id64 and discordId then
        local userExists = IsSid64Registered(id64)

        if userExists and not DISCORD:IsRegistered(sid64) then
            local query = [[INSERT INTO users_discord VALUES(%s, %s)]]
            return sql.Query(string.format(query, sid64, discordId))
        end
    end

    error("Failed to register user " .. id64 .. " with discord " .. discordId)
end)

hook.Add("PlayerSay", "DiscordRegister", function(ply, text)
    if string.lower(text) == "!registrar" then
        timer.Simple(0.1, function()
            if IsValid(ply) then
                ply:ChatPrint("Para registrar primeiramente entre no nosso discord pelo <c=114,137,218>!discord</c>")
                ply:ChatPrint("Após entrar no discord, entre no canal <c=114,137,218>bots</c> e digite o seguinte comando:")
                ply:ChatPrint("<c=114,137,218>!registrar " .. ply:SteamID64() .. "</c>")
                ply:ChatPrint("Lembre-se: <c=255,0,0>É proibido se registrar como outro usuário e fazer isso resultará em banimento!</c>")
            end
        end)
    end
end)