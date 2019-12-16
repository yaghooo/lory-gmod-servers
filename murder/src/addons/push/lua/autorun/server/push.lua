local possibleSounds = {"physics/body/body_medium_impact_hard1.wav", "physics/body/body_medium_impact_hard2.wav", "physics/body/body_medium_impact_hard3.wav", "physics/body/body_medium_impact_hard5.wav", "physics/body/body_medium_impact_hard6.wav", "physics/body/body_medium_impact_soft5.wav", "physics/body/body_medium_impact_soft6.wav", "physics/body/body_medium_impact_soft7.wav"}

hook.Add("KeyPress", "Pushing", function(ply, key)
    if key == IN_USE and ply:PS_HasItemEquipped("push") then
        local ent = ply:GetEyeTrace().Entity

        if IsValid(ply) and IsValid(ent) and ply:IsPlayer() and ent:IsPlayer() and ent:Alive() then
            local isEntityClose = ply:GetPos():Distance(ent:GetPos()) <= 100
            local isEntityWalking = ent:GetMoveType() == MOVETYPE_WALK

            if isEntityClose and isEntityWalking then
                local entityHasAntiPush = ent:PS_HasItemEquipped("antipush")
                local canPush = not entityHasAntiPush or (entityHasAntiPush and ply:PS_HasItemEquipped("antiantipush"))

                if canPush then
                    ply:EmitSound(table.Random(possibleSounds), 100, math.random(90, 110))
                    ent:SetVelocity(ply:EyeAngles():Forward() * 500)
                    ent:ViewPunch(Angle(math.random(-20, 20), math.random(-20, 20), 0))
                end
            end
        end
    end
end)