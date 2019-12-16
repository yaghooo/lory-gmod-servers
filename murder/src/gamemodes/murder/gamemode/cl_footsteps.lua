GM.FootstepMaxLifeTime = CreateClientConVar("mu_footstep_maxlifetime", 30, true, true)
local FootSteps = {}

if FootStepsG then
    FootSteps = FootStepsG
end

FootStepsG = FootSteps

function GM:FootStepsInit()
end

local footMat = Material("thieves/footprint")
local maxDistance = 600 ^ 2

function GM:DrawFootprints()
    -- caching
    local pos = EyePos()
    local curTime = CurTime()
    local drawFoot = render.DrawQuadEasy
    local lifeTime = math.Clamp(self.FootstepMaxLifeTime:GetInt(), 0, 30)
    cam.Start3D(pos, EyeAngles())
    render.SetMaterial(footMat)

    for k, footstep in pairs(FootSteps) do
        if footstep.curtime + lifeTime > curTime then
            if (footstep.pos - pos):LengthSqr() < maxDistance then
                drawFoot(footstep.pos + footstep.normal * 0.01, footstep.normal, 10, 20, footstep.col, footstep.angle)
            end
        else
            FootSteps[k] = nil
        end
    end

    cam.End3D()
end

function GM:AddFootstep(ply, pos, ang)
    ang.p = 0
    ang.r = 0
    local fpos = pos

    if ply.LastFoot then
        fpos = fpos + ang:Right() * 5
    else
        fpos = fpos + ang:Right() * -5
    end

    ply.LastFoot = not ply.LastFoot
    local trace = {}
    trace.start = fpos
    trace.endpos = trace.start + Vector(0, 0, -10)
    trace.filter = ply
    local tr = util.TraceLine(trace)

    if tr.Hit then
        local col = ply:GetPlayerColor()

        local tbl = {
            pos = tr.HitPos,
            plypos = fpos,
            curtime = CurTime(),
            angle = ang.y,
            normal = tr.HitNormal,
            col = col:ToColor()
        }

        table.insert(FootSteps, tbl)
    end
end

function GM:FootStepsFootstep(ply, pos, foot, sound, volume, filter)
    if ply ~= LocalPlayer() or not self:CanSeeFootsteps() then return end
    self:AddFootstep(ply, pos, ply:GetAimVector():Angle())
end

function GM:CanSeeFootsteps()
    return self:IsMurderer() and LocalPlayer():Alive()
end

function GM:ClearFootsteps()
    table.Empty(FootSteps)
end

net.Receive("add_footstep", function()
    local ply = net.ReadEntity()
    local pos = net.ReadVector()
    local ang = net.ReadAngle()
    if not IsValid(ply) or ply == LocalPlayer() or not GAMEMODE:CanSeeFootsteps() then return end
    GAMEMODE:AddFootstep(ply, pos, ang)
end)

net.Receive("clear_footsteps", function()
    GAMEMODE:ClearFootsteps()
end)