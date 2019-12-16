local CATEGORY_NAME = "DEVX"

local addons = ulx.command(CATEGORY_NAME, "ulx addons", function(ply)
    openUrl(ply, "https://steamcommunity.com/sharedfiles/filedetails/?id=1193912994")
end, {"!addons", "!addon"})

addons:defaultAccess(ULib.ACCESS_ALL)
addons:help("Ver addons do servidor.")

local steamgroup = ulx.command(CATEGORY_NAME, "ulx steamgroup", function(ply)
    openUrl(ply, "http://steamcommunity.com/groups/devxservers")
end, {"!steam", "!group", "!grupo"})

steamgroup:defaultAccess(ULib.ACCESS_ALL)
steamgroup:help("Entre no nosso grupo da steam.")

local discord = ulx.command(CATEGORY_NAME, "ulx discord", function(ply)
    openUrl(ply, "https://discord.gg/4xDjk5U")
end, {"!discord"})

discord:defaultAccess(ULib.ACCESS_ALL)
discord:help("Entre no nosso discord.")

local staffrequest = ulx.command(CATEGORY_NAME, "ulx staffrequest", function(ply)
    openUrl(ply, "http://devx.ultimatez.xyz/form")
end, {"!form", "!formulario", "!virarstaff"})

staffrequest:defaultAccess(ULib.ACCESS_ALL)
staffrequest:help("Vire um staff.")

function openUrl(ply, url)
    ply:SendLua(string.format([[gui.OpenURL("%s")]], url))
end