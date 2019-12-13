local possibleSounds = {
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

hook.Add(
    "KeyPress",
    "Pushing",
    function(ply, key)
        if key == IN_USE and ply:PS_HasItemEquipped("push") and not pushs[ply:UserID()] then
            local ent = ply:GetEyeTrace().Entity
            if
                IsValid(ply) and IsValid(ent) and ply:IsPlayer() and ent:IsPlayer() and
                    ply:GetPos():Distance(ent:GetPos()) <= 100 and
                    ent:Alive() and
                    ent:GetMoveType() == MOVETYPE_WALK
             then
                ply:EmitSound(table.Random(possibleSounds), 100, math.random(90, 110))
                ent:SetVelocity(ply:EyeAngles():Forward() * 100)
                ent:ViewPunch(Angle(math.random(-20, 20), math.random(-20, 20), 0))

                pushs[ply:UserID()] = true

                timer.Simple(
                    0.3,
                    function()
                        pushs[ply:UserID()] = false
                    end
                )
            end
        end
    end
)
