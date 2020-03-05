local PlayerMeta = FindMetaTable("Player")
local EntityMeta = FindMetaTable("Entity")

if not PlayerMeta.GetRagdollEntityOld then
    PlayerMeta.GetRagdollEntityOld = PlayerMeta.GetRagdollEntity
end

function PlayerMeta:GetRagdollEntity()
    local ent = self:GetNWEntity("DeathRagdoll")

    return (IsValid(ent) and ent) or self:GetRagdollEntityOld()
end

if not EntityMeta.GetRagdollOwnerOld then
    EntityMeta.GetRagdollOwnerOld = EntityMeta.GetRagdollOwner
end

function EntityMeta:GetRagdollOwner()
    local ent = self:GetNWEntity("RagdollOwner")

    return (IsValid(ent) and ent) or self:GetRagdollOwnerOld()
end