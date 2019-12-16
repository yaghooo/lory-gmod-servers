util.AddNetworkString("mu_adminpanel_details")

net.Receive("mu_adminpanel_details", function(length, ply)
    if not ply:IsAdmin() or not GAMEMODE.AdminPanelAllowed:GetBool() then return end
    local tab = {}
    tab.players = {}
    tab.weightMul = GAMEMODE.MurdererWeight:GetFloat()
    local total = 0

    for _, ply2 in pairs(team.GetPlayers(2)) do
        total = total + (ply2.MurdererChance or 1) ^ tab.weightMul
    end

    for _, ply2 in pairs(team.GetPlayers(2)) do
        local t = {}
        t.player = ply2:EntIndex() -- can't send players via JSON
        t.murderer = ply2:IsMurderer()
        t.murdererChance = ((ply2.MurdererChance or 1) ^ tab.weightMul) / total
        t.murdererWeight = ply2.MurdererChance or 1
        tab.players[ply2:EntIndex()] = t
    end

    local json = util.TableToJSON(tab)
    net.Start("mu_adminpanel_details")
    net.WriteString(json)
    net.Send(ply)
end)