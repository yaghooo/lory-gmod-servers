-- returns a table of players with name matching nick
local function FindPlayersByName(nick)
    if not nick then return {} end
    if nick == "*" then return player.GetAll() end
    if nick == "^" then return {} end
    local foundplayers = {}

    for _, ply in ipairs(player.GetAll()) do
        if string.find(string.lower(ply:Nick()), string.lower(nick)) then
            table.insert(foundplayers, ply)
        end
    end

    return foundplayers
end

local function DeathrunSafeChatPrint(ply, msg)
    if IsValid(ply) then
        ply:DeathrunChatPrint(msg)
    else
        MsgC(THEME.Color.Primary, msg .. "\n")
    end
end

function DR:SafeChatPrint(ply, msg)
    DeathrunSafeChatPrint(ply, msg)
end

--console commands
concommand.Add("deathrun_respawn", function(ply, cmd, args)
    local targets = args[1] and FindPlayersByName(args[1]) or {ply}

    if DR:CanAccessCommand(ply, cmd) then
        local players = ""

        if #targets > 0 then
            for k, targ in ipairs(targets) do
                targ:KillSilent()
                targ:Spawn()
                players = players .. targ:Nick() .. ", "
            end
        end

        DeathrunSafeChatPrint(ply, "Respawnou " .. string.sub(players, 1, -3) .. ".")
    else
        DeathrunSafeChatPrint(ply, "Você não tem permissão para fazer isso.")
    end
end, nil, nil, FCVAR_SERVER_CAN_EXECUTE)

concommand.Add("deathrun_cleanup", function(ply, cmd, args)
    if DR:CanAccessCommand(ply, cmd) or ROUND:GetCurrent() == ROUND_WAITING then
        game.CleanUpMap()
        DeathrunSafeChatPrint(ply, "Cleaned up the map and reset entities.")
    else
        DeathrunSafeChatPrint(ply, "You are not allowed to do that.")
    end
end, nil, nil, FCVAR_SERVER_CAN_EXECUTE)

concommand.Add("deathrun_resetzone", function(ply, cmd)
    if DR:CanAccessCommand(ply, cmd) then
        sql.Query("DELETE FROM deathrun_records WHERE mapname = '" .. game.GetMap() .. "'")
    end
end)

-- chat commands
DR.ChatCommands = {}

function DR:GetChatCommandTable()
    return DR.ChatCommands
end

function DR:AddChatCommand(cmd, func)
    DR.ChatCommands[cmd] = func
end

function DR:AddChatCommandAlias(cmd, cmd2)
    DR.ChatCommands[cmd2] = DR.ChatCommands[cmd]
end

local function ProcessChat(ply, text, public)
    text = string.lower(text)
    local args = string.Split(text, " ")
    local prefix = string.sub(args[1], 1, 1)
    local cmd = string.sub(args[1], 2, -1)

    if (prefix == "!" or prefix == "/") and DR.ChatCommands[cmd] then
        local cmdfunc = DR.ChatCommands[cmd]
        local args2 = {}

        for i = 2, #args do
            args2[i - 1] = args[i]
        end

        cmdfunc(ply, args2)
    end
end

hook.Add("PlayerSay", "ProcessDeathrunChat", ProcessChat)

DR:AddChatCommand("respawn", function(ply, args)
    ply:ConCommand("deathrun_respawn " .. (args[1] or ""))
    PrintTable(args)
end)

DR:AddChatCommandAlias("respawn", "r")

DR:AddChatCommand("cleanup", function(ply)
    ply:ConCommand("deathrun_cleanup")
end)

DR:AddChatCommand("settings", function(ply)
    ply:ConCommand("deathrun_open_settings")
end)

DR:AddChatCommand("1p", function(ply)
    ply:ConCommand("deathrun_thirdperson_enabled 0")
end)

DR:AddChatCommand("3p", function(ply)
    ply:ConCommand("deathrun_thirdperson_enabled 1")
end)

DR:AddChatCommand("thirdperson", function(ply)
    ply:ConCommand("deathrun_toggle_thirdperson")
end)

DR:AddChatCommand("firstperson", function(ply)
    ply:ConCommand("deathrun_toggle_thirdperson")
end)

DR:AddChatCommand("spec", function(ply, args)
    if ply:ShouldStaySpectating() then
        ply:ConCommand("deathrun_spectate_only 0")
    else
        ply:ConCommand("deathrun_spectate_only 1")
    end
end)

DR:AddChatCommand("zones", function(ply)
    ply:ConCommand("deathrun_open_zone_editor")
end)
