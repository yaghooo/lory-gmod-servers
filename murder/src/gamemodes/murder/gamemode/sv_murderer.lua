local PlayerMeta = FindMetaTable("Player")
util.AddNetworkString("SetMurdererStatus")
util.AddNetworkString("SetKnife")
GM.MurdererWeight = CreateConVar("mu_murder_weight_multiplier", 2, bit.bor(FCVAR_NOTIFY), "Multiplier for the weight of the murderer chance")

function PlayerMeta:SetMurderer(murderer)
    local defaultKnives = {"csgo_default_knife", "csgo_default_t"}
    self.CurrentMurderKnife = self.CustomKnife or table.Random(defaultKnives)
    self.Murderer = murderer

    if murderer then
        self.MurdererChance = 1
        net.Start("SetKnife")
        net.WriteString(self:GetKnife())
        net.Send(self)
    end

    net.Start("SetMurdererStatus")
    net.WriteBool(murderer)
    net.Send(self)
end

function PlayerMeta:GetKnife()
    return self.CurrentMurderKnife
end

function PlayerMeta:IsMurderer()
    return self.Murderer
end

function PlayerMeta:SetMurdererRevealed(revealed)
    self:SetNWBool("MurdererFog", revealed)
    self.MurdererRevealed = revealed
end

function PlayerMeta:IsMurdererRevealed()
    return self.MurdererRevealed
end

function GM:GetMurderer()
    for _, ply in pairs(team.GetPlayers(2)) do
        if ply:IsMurderer() then return ply end
    end
end

local NO_KNIFE_TIME = 30

function GM:MurdererThink()
    local curTime = CurTime()
    if self.MurdererLastThink and self.MurdererLastThink > curTime - 1 then return end
    self.MurdererLastThink = curTime
    local murderer = self:GetMurderer()

    -- regenerate knife if on ground
    if IsValid(murderer) and murderer:Alive() then
        if murderer:HasWeapon(murderer:GetKnife()) then
            murderer.LastHadKnife = curTime
        elseif murderer.LastHadKnife and murderer.LastHadKnife + NO_KNIFE_TIME < curTime then
            for _, ent in pairs(ents.FindByClass(murderer:GetKnife())) do
                ent:Remove()
            end

            murderer:Give(murderer:GetKnife())
        end
    end
end