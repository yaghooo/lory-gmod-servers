if SERVER then
    AddCSLuaFile()
end

SWEP.Base = "weapon_mers_base"
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true
SWEP.ViewModel = "models/weapons/c_357.mdl"
SWEP.WorldModel = "models/weapons/w_357.mdl"
SWEP.ViewModelFlip = false
SWEP.HoldType = "revolver"
SWEP.SequenceDraw = "draw"
SWEP.SequenceIdle = "idle01"
SWEP.SequenceHolster = "holster"
SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Sound = "Weapon_357.Single"
SWEP.Primary.Sequence = "fire"
SWEP.Primary.Damage = 200
SWEP.Primary.Cone = 0
SWEP.Primary.DryFireSequence = "fireempty"
SWEP.Primary.DryFireSound = Sound("Weapon_Pistol.Empty")
SWEP.Primary.InfiniteAmmo = true
SWEP.Primary.AutoReload = true
SWEP.ReloadSequence = "reload"
SWEP.ReloadSound = Sound("Weapon_357.Reload")
SWEP.PrintName = translate and translate.magnum or "Magnum"

function SWEP:Initialize()
    self:SetWeaponState("holster")
    self.BaseClass.Initialize(self)
    self.PrintName = translate and translate.magnum or "Magnum"
    self:SetClip1(self:GetMaxClip1())
end

function SWEP:SetupDataTables()
    self:NetworkVar("String", 0, "WeaponState")
    self:NetworkVar("Float", 0, "ReloadEnd")
    self:NetworkVar("Float", 1, "NextIdle")
end

function SWEP:IsIdle()
    if self:GetReloadEnd() > 0 and self:GetReloadEnd() >= CurTime() then return false end
    if self:GetNextPrimaryFire() > 0 and self:GetNextPrimaryFire() >= CurTime() then return false end

    return true
end

function SWEP:PrimaryAttack()
    if not self:IsIdle() then return end

    if self:GetMaxClip1() > 0 and self:Clip1() <= 0 then
        self:Reload()

        return
    end

    local vm = self.Owner:GetViewModel()

    if self.Primary.Sequence then
        vm:SendViewModelMatchingSequence(vm:LookupSequence(self.Primary.Sequence))
    end

    self:SetNextPrimaryFire(CurTime() + (self.Primary.Delay or vm:SequenceDuration()))
    self:SetNextIdle(CurTime() + vm:SequenceDuration())
    self:TakePrimaryAmmo(1)

    if self.Primary.Sound then
        self:EmitSound(self.Primary.Sound)
    end

    self.Owner:SetAnimation(PLAYER_ATTACK1)
    local stats = {}
    stats.damage = self.Primary.Damage or 1
    stats.cone = self.Primary.Cone or 0.1

    if IsValid(self.Owner) and self.Owner:IsPlayer() then
        self.Owner:LagCompensation(true)
    end

    self:DoPrimaryAttackEffect(stats)

    if IsValid(self.Owner) and self.Owner:IsPlayer() then
        self.Owner:LagCompensation(false)
    end
end

function SWEP:DoPrimaryAttackEffect(stats)
    local bullet = {}
    bullet.Num = self.Primary.NumShots or 1
    bullet.Src = self.Owner:GetShootPos()
    bullet.Dir = self.Owner:GetAimVector()
    bullet.Spread = Vector(stats.cone, stats.cone, 0)
    bullet.Tracer = self.Primary.Tracer or 1
    bullet.Force = self.Primary.Force or ((self.Primary.Damage or 1) * 3)
    bullet.Damage = stats.damage or 1
    self.Owner:FireBullets(bullet)
end

function SWEP:Reload()
    if self:IsIdle() and self:GetWeaponState() == "normal" and self:GetMaxClip1() > 0 and self:Clip1() < self:GetMaxClip1() and self.Primary.InfiniteAmmo then
        local vm = self.Owner:GetViewModel()
        vm:SendViewModelMatchingSequence(vm:LookupSequence(self.ReloadSequence))

        if self.ReloadSound then
            self:EmitSound(self.ReloadSound)
        end

        self.Owner:SetAnimation(PLAYER_RELOAD)
        self:SetReloadEnd(CurTime() + vm:SequenceDuration())
        self:SetNextIdle(CurTime() + vm:SequenceDuration())
    end
end

function SWEP:Deploy()
    self:SetWeaponState("normal")
    self:CalculateHoldType()
    local time = 1
    local vm = self.Owner:GetViewModel()

    if IsValid(vm) then
        if self.SequenceDraw then
            vm:SendViewModelMatchingSequence(vm:LookupSequence(self.SequenceDraw))
            time = vm:SequenceDuration()
        elseif self.SequenceDrawTime then
            time = self.SequenceDrawTime
        end
    end

    self:SetNextIdle(CurTime() + time)

    return true
end

function SWEP:Think()
    self:CalculateHoldType()

    if self:GetReloadEnd() > 0 and self:GetReloadEnd() < CurTime() then
        self:SetReloadEnd(0)

        if self.Primary.InfiniteAmmo then
            self:SetClip1(self:GetMaxClip1())
        end
    end

    if self:GetNextIdle() > 0 and self:GetNextIdle() < CurTime() then
        self:SetNextIdle(0)
        local sequence = self.SequenceIdle
        local vm = self.Owner:GetViewModel()
        vm:SendViewModelMatchingSequence(vm:LookupSequence(sequence))

        if self.Primary.AutoReload and self:GetMaxClip1() > 0 and self:Clip1() <= 0 then
            self:Reload()
        end
    end
end