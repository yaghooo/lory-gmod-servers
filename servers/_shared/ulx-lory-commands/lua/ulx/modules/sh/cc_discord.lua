local CATEGORY_NAME = "Lory"

local discordrank = ulx.command(CATEGORY_NAME, "ulx discordrank", function(ply, discordId, group)
    group = group:lower()
    local sid64 = DISCORD:GetSid64ById(discordId)
    print("Add user to rank " .. group .. " with discord '" .. discordId .. "' and id '" .. sid64 .. "'")

    local steamid = util.SteamIDFrom64(sid64)
    if group == "user" then
        ULib.ucl.removeUser(steamid)
    else
        ULib.ucl.addUser(steamid, nil, nil, group)
    end
end)

discordrank:addParam{
    type = ULib.cmds.StringArg,
    hint = "Discord id"
}

discordrank:addParam{
    type = ULib.cmds.StringArg,
    completes = ulx.tempuser_group_names,
    hint = "Group to place user",
    error = "invalid group '%s' specified",
ULib.cmds.restrictToCompletes
}

discordrank:defaultAccess(ULib.ACCESS_SUPERADMIN)
discordrank:help("Adiciona rank pelo id do discord.")

local discordpoints = ulx.command(CATEGORY_NAME, "ulx discordpoints", function(ply, discordId, quantity)
    local sid64 = DISCORD:GetSid64ById(discordId)
    print("Add " .. quantity .. " points to user with discord '" .. discordId .. "' and id '" .. sid64 .. "'")
    PS.DataProvider:GivePoints(sid64, quantity)
end)

discordpoints:addParam{
    type = ULib.cmds.StringArg,
    hint = "Discord id"
}

discordpoints:addParam{
    type = ULib.cmds.NumArg
}

discordpoints:defaultAccess(ULib.ACCESS_SUPERADMIN)
discordpoints:help("Adiciona pontos pelo id do discord. Necessário pointshop.")

local discordban = ulx.command(CATEGORY_NAME, "ulx discordban", function(ply, discordId, hours, reason)
    local sid64 = DISCORD:GetSid64ById(discordId)
    print("Banned user with discord '" .. discordId .. "' and id '" .. sid64 .. "' for " .. hours .. " hours")
    ULib.addBan(util.SteamIDFrom64(sid64), hours * 60, reason)
end)

discordban:addParam{
    type = ULib.cmds.StringArg,
    hint = "Discord id"
}

discordban:addParam{
    type = ULib.cmds.NumArg,
    hint = "Hours"
}

discordban:addParam{
    type = ULib.cmds.StringArg,
    hint = "Reason"
}

discordban:defaultAccess(ULib.ACCESS_SUPERADMIN)
discordban:help("Adiciona pontos pelo id do discord. Necessário pointshop.")