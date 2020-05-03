if SERVER then
    AddCSLuaFile()
    util.AddNetworkString("StartFlashbangEffect")
else
    net.Receive("StartFlashbangEffect", function()
        local sender = net.ReadEntity()
        local client = LocalPlayer()
        local shouldFlash = true

        hook.Add("HUDPaint", "FlashbangEffect", function()
            local ply = client:Alive() and client or client:GetObserverTarget()

            if IsValid(ply) and ply ~= sender then
                if shouldFlash then
                    surface.SetDrawColor(color_white)
                    surface.DrawRect(0, 0, ScrW(), ScrH())
                end

                local M = Matrix()
                M:Translate(Vector(ScrW() / 2, ScrH() / 2))
                M:Rotate(Angle(0, 5 * math.sin(CurTime() * 0.5), 0))
                M:Scale(Vector(1, 1, 1) * (0.9 + 0.2 * math.sin(CurTime() * 0.3)))
                M:Translate(-Vector(ScrW() / 2, ScrH() / 2))
                cam.PushModelMatrix(M)
            end
        end)

        hook.Add("HUDPaint", "FlashbangCrazyEffect", function() end)

        timer.Simple(3, function()
            local start = SysTime()
            shouldFlash = false

            hook.Add("RenderScreenspaceEffects", "DrawMotionBlur", function()
                local ply = client:Alive() and client or client:GetObserverTarget()

                if IsValid(ply) and ply ~= sender then
                    local blur = math.Clamp(Lerp(SysTime() - start, 0, 3) / 3, 0.01, 1)
                    DrawMotionBlur(blur, 1, 0.05)
                end
            end)

            timer.Simple(3, function()
                hook.Remove("RenderScreenspaceEffects", "DrawMotionBlur")
                hook.Remove("HUDPaint", "FlashbangEffect")
            end)
        end)
    end)
end

SWEP.Base = "weapon_mers_base"
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.DrawCrosshair = false
SWEP.ViewModel = "models/weapons/c_slam.mdl"
SWEP.WorldModel = "models/weapons/w_slam.mdl"
SWEP.ViewModelFlip = false
SWEP.HoldType = "slam"
SWEP.SequenceDraw = "draw"
SWEP.SequenceIdle = "idle01"
SWEP.SequenceHolster = "holster"
SWEP.PrintName = "Botão de flash"
SWEP.Primary.DefaultClip = 0
SWEP.Primary.ClipSize = 0

function SWEP:Initialize()
    self.BaseClass.Initialize(self)
end

function SWEP:Deploy()
    self:SendWeaponAnim(ACT_SLAM_DETONATOR_DRAW)
end

function SWEP:PrimaryAttack()
    self.Owner:SetAnimation(PLAYER_ATTACK1)
    self:SendWeaponAnim(ACT_SLAM_DETONATOR_DETONATE)
    self:EmitSound("Weapon_SLAM.SatchelDetonate")

    if SERVER then
        timer.Simple(0.5, function()
            if IsValid(self) then
                sound.Play("weapons/flashbang/flashbang_explode2.wav", self:GetPos(), 120, 100, 1)
                net.Start("StartFlashbangEffect")
                net.WriteEntity(self:GetOwner())
                net.SendOmit(self:GetOwner())
                self:Remove()
            end
        end)
    end
end