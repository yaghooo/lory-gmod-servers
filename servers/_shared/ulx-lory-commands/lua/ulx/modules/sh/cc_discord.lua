local CATEGORY_NAME = "Lory"

local discordrank = ulx.command(CATEGORY_NAME, "ulx discordrank", function(ply, discordId, group)
    group = group:lower()
    local sid64 = DISCORD:GetSid64ById(discordId)
    print("Add user to rank " .. group .. " with discord '" .. discordId .. "' and id '" .. sid64 .. "'")
    ULib.ucl.addUser(util.SteamIDFrom64(sid64), nil, nil, group)
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

discordrank:defaultAccess(ULib.ACCESS_ALL)
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

discordpoints:defaultAccess(ULib.ACCESS_ALL)
discordpoints:help("Adiciona pontos pelo id do discord. Necessário pointshop.")