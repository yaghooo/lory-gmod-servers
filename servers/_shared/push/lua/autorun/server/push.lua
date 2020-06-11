local push_force = CreateConVar("push_force", 100, FCVAR_NONE, "Push force", 1, 99999)

local possible_sounds = {
    "physics/body/body_medium_impact_hard1.wav",
    "physics/body/body_medium_impact_hard2.wav",
    "physics/body/body_medium_impact_hard3.wav",
    "physics/body/body_medium_impact_hard5.wav",
    "physics/body/body_medium_impact_hard6.wav",
    "physics/body/body_medium_impact_soft5.wav",
    "physics/body/body_medium_impact_soft6.wav",
    "physics/body/body_medium_impact_soft7.wav"
}

local pushs = {}

function PushEntity(originator, ent, originatorId)
    originator:EmitSound(table.Random(possible_sounds), 100, math.random(90, 110))
    ent:SetVelocity(originator:EyeAngles():Forward() * push_force:GetInt())
    ent:ViewPunch(Angle(math.random(-20, 20), math.random(-20, 20), 0))

    pushs[originatorId] = true
    timer.Simple(0.3, function()
        pushs[originatorId] = nil
    end)
end

hook.Add("KeyPress", "Pushing", function(ply, key)
    if key == IN_USE then
        if GhostMode and ply:IsGhost() then
            return
        end

        local originatorId = ply:SteamID()
        if pushs[originatorId] then
            return
        end

        local ent = ply:GetEyeTrace().Entity

        if PS then
            local playerHasPush = ply:PS_HasItemEquipped("push")
            local playerHasAntiPush = ply:PS_HasItemEquipped("antipush")
            local entityHasAntiPush = ent:IsPlayer() and ent:PS_HasItemEquipped("antipush")

            if not playerHasPush or playerHasAntiPush or entityHasAntiPush then
                return
            end
        end

        if IsValid(ply) and IsValid(ent) and ply:IsPlayer() and ent:IsPlayer() and ent:Alive() then
            local isEntityClose = ply:GetPos():Distance(ent:GetPos()) <= 200
            local entMoveType = ent:GetMoveType()
            local isMoveTypeValid = entMoveType ~= MOVETYPE_OBSERVER and entMoveType ~= MOVETYPE_LADDER

            if isEntityClose and isMoveTypeValid then
                PushEntity(ply, ent, originatorId)
            end
        end
    end
end)