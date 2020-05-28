GM.Name = "Deathrun"
GM.Author = "Ceifa"
GM.Email = ""
GM.Website = ""

function GM:Initialize()
    self.BaseClass.Initialize(self)
end

TEAM_GHOST = 5
TEAM_RUNNER = 3
TEAM_DEATH = 2

function GM:CreateTeams()
    team.SetUp(TEAM_GHOST, "Ghosts", DR.Colors.GhostTeam, false)
    team.SetUp(TEAM_RUNNER, "Runners", DR.Colors.RunnerTeam, false)
    team.SetUp(TEAM_DEATH, "Deaths", DR.Colors.DeathTeam, false)
    team.SetSpawnPoint(TEAM_GHOST, "info_player_counterterrorist")
    team.SetSpawnPoint(TEAM_DEATH, "info_player_terrorist")
    team.SetSpawnPoint(TEAM_RUNNER, "info_player_counterterrorist")
    team.SetColor(TEAM_SPECTATOR, DR.Colors.SpectatorTeam)
end

function player.GetAllPlaying()
    local pool = {}

    for k, ply in ipairs(player.GetAll()) do
        if ply and ply:ShouldStaySpectating() == false then
            table.insert(pool, ply)
        end
    end

    return pool
end

hook.Add("SetupMove", "DeathrunDisableSpectatorSpacebar", function(ply, mv, cmd)
    if ply:GetObserverMode() ~= OBS_MODE_NONE then
        mv:SetButtons(bit.band(mv:GetButtons(), bit.bnot(IN_JUMP)))
    end
end)

function QuadLerp(frac, p1, p2)
    local y = (p1 - p2) * (frac - 1) ^ 2 + p2

    return y
end

function InverseLerp(pos, p1, p2)
    local range = 0
    range = p2 - p1
    if range == 0 then return 1 end

    return (pos - p1) / range
end

-- hull sizes
DR.Hulls = {
    HullMin = Vector(-16, -16, 0),
    HullDuck = Vector(16, 16, 43),
    HullStand = Vector(16, 16, 66),
    ViewDuck = Vector(0, 0, 41),
    ViewStand = Vector(0, 0, 64)
}

if CLIENT then
    concommand.Add("deathrun_reload_hull_client", function()
        DR:SetClientHullSizes()
    end)

    function DR:SetClientHullSizes()
        LocalPlayer():SetHull(DR.Hulls.HullMin, DR.Hulls.HullStand)
        LocalPlayer():SetHullDuck(DR.Hulls.HullMin, DR.Hulls.HullDuck) -- quack quack
        LocalPlayer():SetViewOffset(DR.Hulls.ViewStand)
        LocalPlayer():SetViewOffsetDucked(DR.Hulls.ViewDuck) -- quack
    end
end

hook.Add("PlayerSpawn", "HullSizes", function(ply)
    ply:SetHull(DR.Hulls.HullMin, DR.Hulls.HullStand)
    ply:SetHullDuck(DR.Hulls.HullMin, DR.Hulls.HullDuck) -- quack quack
    ply:SetViewOffset(DR.Hulls.ViewStand)
    ply:SetViewOffsetDucked(DR.Hulls.ViewDuck) -- quack
    ply:ConCommand("deathrun_reload_hull_client")
end)

local lp, bn, ba = LocalPlayer, bit.bnot, bit.band

hook.Add("SetupMove", "AutoHop", function(ply, data)
    if lp and ply ~= lp() then return end
    local ButtonData = data:GetButtons()

    if ba(ButtonData, IN_JUMP) > 0 and ply:WaterLevel() < 2 and ply:GetMoveType() ~= MOVETYPE_LADDER and not ply:IsOnGround() then
        data:SetButtons(ba(ButtonData, bn(IN_JUMP)))
    end
end)

-- get rid of some default hooks
hook.Remove("PlayerTick", "TickWidgets")

function DR:CanAccessCommand(ply, cmd)
    if not ply or not IsValid(ply) then return 100 end
    local access = DR.Ranks[ply:GetUserGroup()] or 1
    local perm = DR.Permissions[cmd] or 99

    return access >= perm
end