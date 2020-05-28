local CATEGORY_NAME = "Lory"

local addons = ulx.command(CATEGORY_NAME, "ulx addons", function(ply)
    openUrl(ply, "https://steamcommunity.com/sharedfiles/filedetails/?id=382793424")
end, {"!addons", "!addon"})

addons:defaultAccess(ULib.ACCESS_ALL)
addons:help("Ver addons do servidor.")

local steamgroup = ulx.command(CATEGORY_NAME, "ulx steamgroup", function(ply)
    openUrl(ply, "http://steamcommunity.com/groups/lorybr")
end, {"!steam", "!group", "!grupo"})

steamgroup:defaultAccess(ULib.ACCESS_ALL)
steamgroup:help("Entre no nosso grupo da steam.")

local discord = ulx.command(CATEGORY_NAME, "ulx discord", function(ply)
    openUrl(ply, "https://discord.gg/7FnEfXC")
end, {"!discord"})

discord:defaultAccess(ULib.ACCESS_ALL)
discord:help("Entre no nosso discord.")

local rules = ulx.command(CATEGORY_NAME, "ulx rules", function(ply)
    openUrl(ply, "https://steamcommunity.com/groups/lorybr/discussions/0/1735508423601696637/")
end, {"!rules", "!regras"})

rules:defaultAccess(ULib.ACCESS_ALL)
rules:help("Ver as regras.")

local vip = ulx.command(CATEGORY_NAME, "ulx vip", function(ply)
    openUrl(ply, "https://steamcommunity.com/groups/lorybr/discussions/0/1735508423601693879/")
end, {"!vip", "!doador", "!doar", "!donate"})

vip:defaultAccess(ULib.ACCESS_ALL)
vip:help("Ver informações sobre o vip.")

function openUrl(ply, url)
    ply:SendLua(string.format([[gui.OpenURL("%s")]], url))
end
