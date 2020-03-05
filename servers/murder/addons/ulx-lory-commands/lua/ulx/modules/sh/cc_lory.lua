local CATEGORY_NAME = "DEVX"

local addons = ulx.command(CATEGORY_NAME, "ulx addons", function(ply)
    openUrl(ply, "https://steamcommunity.com/sharedfiles/filedetails/?id=1581506103")
end, {"!addons", "!addon"})

addons:defaultAccess(ULib.ACCESS_ALL)
addons:help("Ver addons do servidor.")

local steamgroup = ulx.command(CATEGORY_NAME, "ulx steamgroup", function(ply)
    openUrl(ply, "https://steamcommunity.com/groups/lorybr")
end, {"!steam", "!group", "!grupo"})

steamgroup:defaultAccess(ULib.ACCESS_ALL)
steamgroup:help("Entre no nosso grupo da steam.")

local discord = ulx.command(CATEGORY_NAME, "ulx discord", function(ply)
    openUrl(ply, "https://discord.gg/6aWsG6U")
end, {"!discord"})

discord:defaultAccess(ULib.ACCESS_ALL)
discord:help("Entre no nosso discord.")

function openUrl(ply, url)
    ply:SendLua(string.format([[gui.OpenURL("%s")]], url))
end