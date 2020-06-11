local PlayerMeta = FindMetaTable("Player")
local EntityMeta = FindMetaTable("Entity")

if not PlayerMeta.CreateRagdollOld then
    PlayerMeta.CreateRagdollOld = PlayerMeta.CreateRagdoll
end

local function clearupRagdolls(ragdolls, max)
    local count = 1

    for k, rag in pairs(ragdolls) do
        if IsValid(rag) then
            count = count + 1
        else
            rag[k] = nil
        end
    end

    if max >= 0 and count > max then
        while count > max do
            if IsValid(ragdolls[1]) then
                ragdolls[1]:Remove()
            end

            table.remove(ragdolls, 1)
            count = count - 1
        end
    end
end

function PlayerMeta:CreateRagdoll(attacker, dmginfo)
    local ent = self:GetNWEntity("DeathRagdoll")

    -- remove old player ragdolls
    if not self.DeathRagdolls then
        self.DeathRagdolls = {}
    end

    local max = hook.Run("MaxDeathRagdollsPerPlayer", self)
    clearupRagdolls(self.DeathRagdolls, max or 1)

    -- remove old server ragdolls
    if not GAMEMODE.DeathRagdolls then
        GAMEMODE.DeathRagdolls = {}
    end

    max = hook.Run("MaxDeathRagdolls")
    clearupRagdolls(GAMEMODE.DeathRagdolls, max or 1)
    local data = duplicator.CopyEntTable(self)

    if not util.IsValidRagdoll(data.Model) then
        data.Model = "models/player/skeleton.mdl"
        -- if use pointshop or something similar to handle character models, just return could be problem with disguise.
    end

    ent = ents.Create("prop_ragdoll")
    data.ModelScale = 1 -- doesn't work on ragdolls
    duplicator.DoGeneric(ent, data)
    self:SetNWEntity("DeathRagdoll", ent)
    ent:SetNWEntity("RagdollOwner", self)
    table.insert(self.DeathRagdolls, ent)
    table.insert(GAMEMODE.DeathRagdolls, ent)

    if ent.SetPlayerColor then
        ent:SetPlayerColor(self:GetPlayerColor())
    end

    ent.PlayerRagdoll = true
    hook.Run("PreDeathRagdollSpawn", self, ent)
    ent:Spawn()
    ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    hook.Run("OnDeathRagdollCreated", self, ent)
    ent:Fire("kill", "", 60 * 8)
    local vel = self:GetVelocity()

    for bone = 0, ent:GetPhysicsObjectCount() - 1 do
        local phys = ent:GetPhysicsObjectNum(bone)

        if IsValid(phys) then
            local pos, ang = self:GetBonePosition(ent:TranslatePhysBoneToBone(bone))

            if pos and ang and vel then
                phys:SetPos(pos)
                phys:SetAngles(ang)
                phys:AddVelocity(vel)
            end
        end
    end
end

if not PlayerMeta.GetRagdollEntityOld then
    PlayerMeta.GetRagdollEntityOld = PlayerMeta.GetRagdollEntity
end

function PlayerMeta:GetRagdollEntity()
    local ent = self:GetNWEntity("DeathRagdoll")

    return (IsValid(ent) and ent) or self:GetRagdollEntityOld()
end

if not PlayerMeta.GetRagdollOwnerOld then
    PlayerMeta.GetRagdollOwnerOld = PlayerMeta.GetRagdollOwner
end

function EntityMeta:GetRagdollOwner()
    local ent = self:GetNWEntity("RagdollOwner")

    return (IsValid(ent) and ent) or self:GetRagdollOwnerOld()
end