GM.Name = "Murder"
GM.Author = "MechanicalMind"
GM.Email = ""
GM.Version = "29"

function GM:SetupTeams()
    team.SetColor(TEAM_SPECTATOR, Color(150, 150, 150))
    team.SetUp(2, translate.teamPlayers, Color(26, 120, 245))
end

GM:SetupTeams()

-- get rid of some default hooks
hook.Remove("PlayerTick", "TickWidgets")