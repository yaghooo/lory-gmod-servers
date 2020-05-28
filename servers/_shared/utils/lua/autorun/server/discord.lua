sql.Query("CREATE TABLE IF NOT EXISTS users_discord ( `sid64` STRING, `discord` STRING, PRIMARY KEY(sid64) )")
DISCORD = {}
DISCORD.__index = DISCORD

function DISCORD:IsRegistered(sid64)
    local result = sql.Query("SELECT discord FROM users_discord WHERE sid64='" .. sid64 .. "' LIMIT 1")

    return (result and result[1]) ~= nil
end

function DISCORD:GetSid64ById(id)
    local result = sql.Query("SELECT sid64 FROM users_discord WHERE discord='" .. id .. "' LIMIT 1")

    return result and result[1] and result[1]["sid64"]
end

concommand.Add("register_discord", function(_, __, args)
    local sid64 = args[1]
    local discordId = args[2]

    if sid64 and discordId then
        local userExists = IsSid64Registered(sid64)

        if userExists then
            local ply = player.GetBySteamID64(sid64)

            if DISCORD:IsRegistered(sid64) then
                if IsValid(ply) then
                    ply:ChatPrint("<c=200,0,0>Você já está registrado!</c>")
                end
            else
                local query = [[INSERT INTO users_discord VALUES(%s, %s)]]
                local result = sql.Query(string.format(query, sid64, discordId))

                if result ~= false then
                    if IsValid(ply) then
                        ply:ChatPrint("<c=114,137,218>Você foi registrado com sucesso!</c>")
                    end

                    hook.Run("DISCORD_Register", sid64)
                    print("Succeed registered " .. sid64 .. " with discord " .. discordId)
                end
            end
        else
            error("Failed to register user " .. sid64 .. " with discord " .. discordId)
        end
    else
        error("Failed to register user(incorrect parameters)")
    end
end)

hook.Add("PlayerSay", "DiscordRegister", function(ply, text)
    if string.lower(text) == "!registrar" then
        timer.Simple(0.1, function()
            if IsValid(ply) then
                ply:ChatPrint("Para registrar primeiramente entre no nosso discord pelo <c=114,137,218>!discord</c>")
                ply:ChatPrint("Após entrar no discord, entre no canal <c=114,137,218>registrar</c> e digite o seguinte comando:")
                ply:ChatPrint("<c=114,137,218>!registrar " .. ply:SteamID64() .. "</c>")
                ply:ChatPrint("Lembre-se: <c=255,0,0>É proibido se registrar como outro usuário e fazer isso resultará em banimento!</c>")
            end
        end)
    end
end)
