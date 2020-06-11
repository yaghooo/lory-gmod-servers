hook.Add("PlayerInitialSpawn", "AddVip", function(ply)
    timer.Simple(10, function()
        if ply:GetUserGroup() == "user" then
            ULib.ucl.addUser(ply, nil, nil, "vip")
        end
    end)
end)