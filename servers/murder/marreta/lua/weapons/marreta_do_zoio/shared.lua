AddCSLuaFile("shared.lua")
SWEP.Base = "weapon_mers_base"
SWEP.Contact = ""
SWEP.Instructions = "Left Click to attack"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.ViewModelFOV = 70
SWEP.ViewModel = "models/v_marreta/v_marreta.mdl"
SWEP.WorldModel = "models/w_marreta/w_marreta.mdl"
SWEP.HoldType = "melee"
SWEP.FiresUnderwater = true
SWEP.Primary.Damage = 120
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 0.5
SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.PrintName = "Marreta"
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.MurderWeapon = true

function SWEP:ShouldDropOnDie()
    return false
end

-- function SWEP:Reload() --To do when reloading
-- end 
-- Called every frame
function SWEP:Think()
end

function SWEP:Initialize()
    self:SetWeaponHoldType("melee")
end

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    local spos = self.Owner:GetShootPos()
    local sdest = spos + (self.Owner:GetAimVector() * 70)
    local kmins = Vector(1, 1, 1) * -10
    local kmaxs = Vector(1, 1, 1) * 10

    local tr = util.TraceHull({
        start = spos,
        endpos = sdest,
        filter = self.Owner,
        mask = MASK_SHOT_HULL,
        mins = kmins,
        maxs = kmaxs
    })

    -- Hull might hit environment stuff that line does not hit
    if not IsValid(tr.Entity) then
        tr = util.TraceLine({
            start = spos,
            endpos = sdest,
            filter = self.Owner,
            mask = MASK_SHOT_HULL
        })
    end

    local hitEnt = tr.Entity

    -- effects
    if IsValid(hitEnt) then
        self:SendWeaponAnim(ACT_VM_HITCENTER)
        local edata = EffectData()
        edata:SetStart(spos)
        edata:SetOrigin(tr.HitPos)
        edata:SetNormal(tr.Normal)
        edata:SetEntity(hitEnt)

        if hitEnt:IsPlayer() or hitEnt:GetClass() == "prop_ragdoll" then
            util.Effect("BloodImpact", edata)
        end
    else
        self:SendWeaponAnim(ACT_VM_MISSCENTER)
    end

    if SERVER then
        self.Owner:SetAnimation(PLAYER_ATTACK1)
    end

    self:SetNextPrimaryFire(CurTime() + .43)
    local trace = self.Owner:GetEyeTrace()

    if trace.HitPos:Distance(self.Owner:GetShootPos()) <= 75 then
        bullet = {}
        bullet.Num = 1
        bullet.Src = self.Owner:GetShootPos()
        bullet.Dir = self.Owner:GetAimVector()
        bullet.Spread = Vector(0, 0, 0)
        bullet.Tracer = 0
        bullet.Force = 3
        bullet.Damage = 60
        self.Owner:DoAttackEvent()
        self.Owner:FireBullets(bullet)
        self:EmitSound("marreta/caraio.wav")
    else
        self:EmitSound("marreta/marretadanasuacara.wav")
        self.Owner:DoAttackEvent()
    end
end

function SWEP:SecondaryAttack()
end

function SWEP:Deploy()
    self:EmitSound("marreta/voupegar.wav")

    return true
end

function SWEP:Holster()
    return true
end