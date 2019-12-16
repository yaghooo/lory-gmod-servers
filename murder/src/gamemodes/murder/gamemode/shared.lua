GM.Name = "Murder"
GM.Author = "MechanicalMind"
GM.Email = ""
GM.Version = "29"

function GM:SetupTeams()
    team.SetUp(1, translate.teamSpectators, Color(150, 150, 150))
    team.SetUp(2, translate.teamPlayers, Color(26, 120, 245))
end

GM:SetupTeams()