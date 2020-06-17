include("sh_translate.lua")
include("shared.lua")
include("cl_hud.lua")
include("cl_scoreboard.lua")
include("cl_footsteps.lua")
include("cl_respawn.lua")
include("cl_murderer.lua")
include("cl_player.lua")
include("cl_fixplayercolor.lua")
include("cl_ragdoll.lua")
include("cl_chattext.lua")
include("cl_rounds.lua")
include("cl_endroundboard.lua")
include("cl_qmenu.lua")
include("cl_spectate.lua")
include("cl_adminpanel.lua")
include("cl_flashlight.lua")
include("cl_halos.lua")
GM.HaloRenderLoot = CreateClientConVar("mu_halo_loot", 1, true, true) -- shouuld we render loot halos
GM.HaloRenderKnife = CreateClientConVar("mu_halo_knife", 1, true, true) -- shouuld we render murderer's knife halos
halo_colors = {Color(0, 220, 0), Color(220, 0, 0), Color(0, 0, 255)}

function GM:Initialize()
    self:FootStepsInit()
end

GM.FogEmitters = {}

if GAMEMODE then
    GM.FogEmitters = GAMEMODE.FogEmitters
end

function GM:Think()
    local curTime = CurTime()

    for _, ply in ipairs(player.GetAll()) do
        if ply:Alive() and ply:GetNWBool("MurdererFog") then
            if not ply.FogEmitter then
                ply.FogEmitter = ParticleEmitter(ply:GetPos())
                self.FogEmitters[ply] = ply.FogEmitter
            end

            if not ply.FogNextPart then
                ply.FogNextPart = curTime
            end

            local pos = ply:GetPos() + Vector(0, 0, 30)
            local client = LocalPlayer()

            if ply.FogNextPart < curTime then
                if client:GetPos():Distance(pos) > 1000 then return end
                ply.FogEmitter:SetPos(pos)
                ply.FogNextPart = curTime + math.Rand(0.01, 0.03)
                local vec = Vector(math.Rand(-8, 8), math.Rand(-8, 8), math.Rand(10, 55))
                local wpos = ply:LocalToWorld(vec)
                local particle = ply.FogEmitter:Add("particle/snow.vmt", wpos)
                particle:SetVelocity(Vector(0, 0, 4) + VectorRand() * 3)
                particle:SetDieTime(5)
                particle:SetStartAlpha(180)
                particle:SetEndAlpha(0)
                particle:SetStartSize(6)
                particle:SetEndSize(7)
                particle:SetRoll(0)
                particle:SetRollDelta(0)
                particle:SetColor(0, 0, 0)
            end
        elseif IsValid(ply.FogEmitter) then
            ply.FogEmitter:Finish()
            ply.FogEmitter = nil
            self.FogEmitters[ply] = nil
        end
    end

    -- clean up old fog emitters
    for ply, emitter in pairs(self.FogEmitters) do
        if not IsValid(ply) or not ply:IsPlayer() then
            emitter:Finish()
            self.FogEmitters[ply] = nil
        end
    end
end

function GM:EntityRemoved(ent)
end

function GM:PostDrawViewModel(vm, ply, weapon)
    if weapon.UseHands or not weapon:IsScripted() then
        local hands = LocalPlayer():GetHands()

        if IsValid(hands) then
            hands:DrawModel()
        end
    end
end

function GM:RenderScene(origin, angles, fov)
end

function GM:PostDrawTranslucentRenderables()
    if self:CanSeeFootsteps() then
        self:DrawFootprints()
    end
end

function GM:PreDrawMurderHalos(Add)
    local client = LocalPlayer()

    if IsValid(client) and client:Alive() then
        local table_insert = table.insert
        local clientPos = client:GetPos()
        local halos = {}

        if self.HaloRenderLoot:GetBool() then
            for _, v in pairs(ents.FindByClass("weapon_mu_magnum")) do
                if not IsValid(v.Owner) and clientPos:Distance(v:GetPos()) < 800 then
                    table_insert(halos, {
                        ent = v,
                        color = 3
                    })
                end
            end

            for _, v in pairs(ents.FindByClass("mu_loot")) do
                if clientPos:Distance(v:GetPos()) < 300 then
                    table_insert(halos, {
                        ent = v,
                        color = 1
                    })
                end
            end
        end

        if self:IsMurderer() and self.HaloRenderKnife:GetBool() then
            for _, v in pairs(ents.FindByClass("mu_knife")) do
                if clientPos:Distance(v:GetPos()) < 800 then
                    table_insert(halos, {
                        ent = v,
                        color = 2
                    })
                end
            end

            for _, v in pairs(ents.FindByClass(self:GetKnife())) do
                if not IsValid(v.Owner) and clientPos:Distance(v:GetPos()) < 800 then
                    table_insert(halos, {
                        ent = v,
                        color = 2
                    })
                end
            end
        end

        if #halos > 0 then
            Add(halos, halo_colors, 5, 5, 5, true, false)
        end
    end
end

net.Receive("mu_tker", function(len)
    GAMEMODE.TKerPenalty = net.ReadBool()
end)
