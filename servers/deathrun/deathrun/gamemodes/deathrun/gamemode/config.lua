-- don't touch this otherwise shit will hit the fan and your custom colors won't work
hook.Add("InitPostEntity", "DeathrunChangeColors", function()
    hook.Call("DeathrunChangeColors", nil, nil)
end)

DR.Colors = {
    GhostTeam = Color(255, 204, 0),
    DeathTeam = Color(242, 108, 79),
    RunnerTeam = Color(58, 137, 201),
    SpectatorTeam = Color(189, 195, 199)
}

-- 1 = user, 2 = operator, 3 = admin
-- 2 will inherit from 1, 3 will inherit from 2
-- to access a command, player must have access level >= permission level
DR.Ranks = {}
DR.Ranks["user"] = 1 -- access levels
DR.Ranks["operator"] = 2
DR.Ranks["admin"] = 3
DR.Ranks["superadmin"] = 3

DR.Permissions = {
    ["deathrun_respawn"] = 3, -- permission levels
    ["deathrun_cleanup"] = 3,
    ["deathrun_open_zone_editor"] = 3,
    ["zone_create"] = 3,
    ["zone_remove"] = 3,
    ["zone_setpos1"] = 3,
    ["zone_setpos2"] = 3,
    ["zone_setcolor"] = 3,
    ["zone_settype"] = 3,
    ["deathrun_force_spectate"] = 2,
    -- mapvote
    ["mapvote_list_maps"] = 1,
    ["mapvote_begin_mapvote"] = 3,
    ["mapvote_vote"] = 1,
    ["mapvote_nominate_map"] = 1,
    ["mapvote_update_mapvote"] = 3, -- debug tool
    ["mapvote_rtv"] = 1
}