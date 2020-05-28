util.AddNetworkString("add_footstep")
util.AddNetworkString("clear_footsteps")

function GM:FootstepsOnFootstep(ply, pos, foot, sound, volume, filter)
    net.Start("add_footstep")
    net.WriteEntity(ply)
    net.WriteVector(pos)
    net.WriteAngle(ply:GetAimVector():Angle())
    local tab = {}

    for _, ply2 in ipairs(player.GetAll()) do
        if self:CanSeeFootsteps(ply2) then
            table.insert(tab, ply2)
        end
    end

    net.Send(tab)
end

function GM:CanSeeFootsteps(ply)
    return ply:IsMurderer() and ply:Alive()
end

function GM:ClearAllFootsteps()
    net.Start("clear_footsteps")
    net.Broadcast()
end