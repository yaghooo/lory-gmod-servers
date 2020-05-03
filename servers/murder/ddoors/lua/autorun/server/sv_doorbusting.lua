CreateConVar("db_doorhealth", 90, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_NOTIFY}, "How strong the doors are.")
CreateConVar("db_respawntimer", 0, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_NOTIFY}, "How long it should take for doors to respawn.")
CreateConVar("db_lockopen", 0, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Whether or not doors should be opened and unlocked after being shot open.")

cvars.AddChangeCallback("db_doorhealth", function()
    for _, v in ipairs(ents.GetAll()) do
        if v:GetClass() == "prop_door_rotating" then
            local health = GetConVar("db_doorhealth"):GetInt()
            v:SetHealth(health)
        end
    end

    print("[DoorBuster] Health changed. Updating doors...")
end)

hook.Add("InitPostEntity", "ITSALLIIIVVEEE", function()
    timer.Simple(5, function()
        for _, v in ipairs(ents.GetAll()) do
            if v:GetClass() == "prop_door_rotating" then
                local health = GetConVar("db_doorhealth"):GetInt()
                v:SetHealth(health)
            end
        end

        print("[DoorBuster] All doors have been prepped")
    end)
end)

hook.Add("KeyPress", "CheckDoor", function(ply, key)
    if IsValid(ply) and key == IN_ATTACK then
        ply.Attacking = true
    end
end)

hook.Add("KeyRelease", "ReleaseInAttack", function(ply, key)
    if IsValid(ply) and key == IN_ATTACK then
        ply.Attacking = false
    end
end)

hook.Add("Think", "RemoveSadDoors", function()
    if nextThink and CurTime() < nextThink then return end

    for _, ply in ipairs(player.GetAll()) do
        if not ply.Attacking then continue end
        local tr = ply:GetEyeTrace()
        local ent = tr.Entity

        if (IsValid(ent) and ent:GetClass() == "func_door_rotating" and (not ent.phys_door or not IsValid(ent.phys_door))) and ply:GetPos():Distance(ent:GetPos()) <= 90 then
            timer.Simple(0.1, function()
                if IsValid(ent) then
                    ent:EmitSound("physics/wood/wood_crate_break" .. math.random(1, 5) .. ".wav")

                    timer.Simple(0.1, function()
                        if IsValid(ent) then
                            ent:Remove()
                        end
                    end)
                end
            end)
        end
    end

    nextThink = CurTime() + 1
end)

local knockedDoors = knockedDoors or {}

hook.Add("EntityTakeDamage", "BigBadWolfIsJealous", function(prop, dmginfo)
    if (prop:GetClass() == "prop_door_rotating" and IsValid(prop)) then
        local doorhealth = prop:Health()
        local dmgtaken = dmginfo:GetDamage()
        prop:SetHealth(doorhealth - dmgtaken) -- Takes damage for the door

        if prop:Health() <= 0 and (not prop.phys_door or not IsValid(prop.phys_door)) then
            prop:Fire("open")

            timer.Simple(0.13, function()
                -- Now we create a prop version of the door to be knocked down for looks
                local dprop = ents.Create("prop_physics")
                dprop:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
                dprop:SetMoveType(MOVETYPE_VPHYSICS)
                dprop:SetSolid(SOLID_BBOX)
                dprop:SetPos(prop:GetPos() + Vector(0, 0, 2))
                dprop:SetAngles(prop:GetAngles())
                dprop:SetModel(prop:GetModel())
                dprop:SetSkin(prop:GetSkin())
                table.insert(knockedDoors, prop)
                -- prop:Remove() -- do NOT remove the door
                prop:Extinguish() -- A fix for the fire glitch
                prop:SetNoDraw(true) -- Instead we're going to hide it
                prop:SetNotSolid(true) -- And remove the collision of it
                dprop:Spawn()
                -- Who doesnt like a little pyrotechnics eh?
                dprop:EmitSound("physics/wood/wood_crate_break" .. math.random(1, 5) .. ".wav")
                prop.phys_door = dprop
            end)
        end
    end
end)