if SERVER then
    AddCSLuaFile()
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

function SWEP:Initialize()
    self:SetWeaponState("holster")
    self.BaseClass.Initialize(self)
end

function SWEP:PrimaryAttack()
    self.Owner:SetAnimation(PLAYER_ATTACK1)

    timer.Simple(1, function()
        if IsValid(self) then
            sound.Play("weapons/flashbang/flashbang_explode2.wav", self:GetPos(), 120, 100, 1)

            if CLIENT then
                local sender = self:GetOwner()
                local flashtime = 0

                hook.Add("HUDPaint", "FlashbangEffect", function()
                    local client = LocalPlayer()
                    local ply = client:Alive() and client or client:GetObserverTarget()

                    if IsValid(ply) and ply ~= sender then
                        flashtime = math.Clamp((flashtime or 0) - FrameTime(), 0, 10)
                        local alpha = InverseLerp(flashtime, 0, 1)
                        alpha = math.Clamp(alpha, 0, 1)

                        if alpha > 0 then
                            surface.SetDrawColor(ColorAlpha(color_white, alpha * 255))
                            surface.DrawRect(0, 0, ScrW(), ScrH())
                        end
                    end
                end)

                timer.Simple(4, function()
                    hook.Remove("HUDPaint", "FlashbangEffect")
                end)
            end

            self:Remove()
        end
    end)
end