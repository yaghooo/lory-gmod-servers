if SERVER then
    hook.Add("PlayerInitialSpawn", "freevip", function(ply)
        local userInfo = ULib.ucl.authed[ply:UniqueID()]
        ULib.ucl.addUser(ply:SteamID(), userInfo.allow, userInfo.deny, "vip")
        ulx.CreateExpiration(ply, 14400, "user")
    end)
end