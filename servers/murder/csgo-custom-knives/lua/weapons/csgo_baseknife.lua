AddCSLuaFile()

if SERVER then
    SWEP.Weight = 5
    SWEP.AutoSwitchTo = false
    SWEP.AutoSwitchFrom = false
    CreateConVar("csgo_knives_oldsounds", 0, FCVAR_ARCHIVE, "Play old sounds when swinging knife or hitting wall")
    CreateConVar("csgo_knives_backstabs", 1, FCVAR_ARCHIVE, "Allow backstabs")
    CreateConVar("csgo_knives_primary", 1, FCVAR_ARCHIVE, "Allow primary attacks")
    CreateConVar("csgo_knives_secondary", 1, FCVAR_ARCHIVE, "Allow secondary attacks")
    CreateConVar("csgo_knives_inspecting", 1, FCVAR_ARCHIVE, "Allow inspecting")
    CreateConVar("csgo_knives_decals", 1, FCVAR_ARCHIVE, "Paint wall decals when hit wall")
    CreateConVar("csgo_knives_hiteffect", 1, FCVAR_ARCHIVE, "Draw effect when hit wall")
end

if CLIENT then
    SWEP.Base = "weapon_mers_base"
    SWEP.Slot = 1
    SWEP.SlotPos = 1
    SWEP.DrawAmmo = false
    SWEP.DrawCrosshair = false
    SWEP.ViewModelFOV = 65
    SWEP.ViewModelFlip = false
    SWEP.UseHands = true
    SWEP.HoldType = "knife"
    SWEP.SequenceDraw = "draw"
    SWEP.SequenceIdle = "idle"

    function SWEP:DrawWeaponSelection(x, y, w, h, alpha)
        local name = translate and translate.knife or "Knife"
        surface.SetFont("MersText1")
        local tw = surface.GetTextSize(name:sub(2))
        surface.SetFont("MersHead1")
        local twf = surface.GetTextSize(name:sub(1, 1))
        tw = tw + twf + 1
        draw.DrawText(name:sub(2), "MersText1", x + w * 0.5 - tw / 2 + twf + 1, y + h * 0.51, Color(255, 150, 0, alpha), 0)
        draw.DrawText(name:sub(1, 1), "MersHead1", x + w * 0.5 - tw / 2, y + h * 0.49, Color(255, 50, 50, alpha), 0)
    end
end

SWEP.DrawWeaponInfoBox = false
SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Primary.Sequence = {"midslash1", "midslash2"}
SWEP.Primary.Delay = 0.5
SWEP.Primary.Recoil = 3
SWEP.Primary.Damage = 120
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0.04
SWEP.Primary.ClipSize = -1
SWEP.Primary.Force = 900
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

--This also used for variable declaration and SetVar/GetVar getting work
function SWEP:SetupDataTables()
    self:NetworkVar("Float", 0, "InspectTime")
    self:NetworkVar("Float", 1, "IdleTime")
end

function SWEP:Initialize()
    self:SetHoldType(self.AreDaggers and "fist" or "knife") -- Avoid using SetWeaponHoldType! Otherwise the players could hold it wrong!
end

-- PaintMaterial
function SWEP:DrawWorldModel()
    if self.PaintMaterial then
        self:SetMaterial(self.PaintMaterial or nil)
    else
        self:SetSkin(self.SkinIndex or self:GetSkin() or 0)
    end

    self:DrawModel()
end

local function FuncPaintMaterial(vm, ply, weapon)
    if not (IsValid(vm) and IsValid(weapon)) then return end

    if weapon.PaintMaterial then
        vm:SetMaterial(weapon.PaintMaterial or nil)
        vm:SetSkin(0)
    elseif weapon.SkinIndex then
        vm:SetMaterial(nil)
        vm:SetSkin(weapon.SkinIndex or vm:GetSkin() or 0)
    else
        vm:SetMaterial(vm:GetMaterial() or nil)
        vm:SetSkin(vm:GetSkin() or 0)
    end
end

hook.Add("PreDrawViewModel", "HookPaintMaterial", FuncPaintMaterial)

function SWEP:Think()
    if CurTime() >= self:GetIdleTime() then
        self:SendWeaponAnim(ACT_VM_IDLE)
        self:SetIdleTime(CurTime() + self.Owner:GetViewModel():SequenceDuration())
    end
end

function SWEP:Deploy()
    self:SetInspectTime(0)
    self:SetIdleTime(CurTime() + self.Owner:GetViewModel():SequenceDuration())
    self:SendWeaponAnim(ACT_VM_DRAW)
    self:SetNextPrimaryFire(CurTime() + 1)
    self:SetNextSecondaryFire(CurTime() + 1)

    return true
end

function SWEP:EntityFaceBack(ent)
    local angle = self.Owner:GetAngles().y - ent:GetAngles().y

    if angle < -180 then
        angle = 360 + angle
    end

    if angle <= 90 and angle >= -90 then return true end

    return false
end

function SWEP:FindHullIntersection(VecSrc, tr, Mins, Maxs, pEntity)
    local VecHullEnd = VecSrc + ((tr.HitPos - VecSrc) * 2)
    local tracedata = {}
    tracedata.start = VecSrc
    tracedata.endpos = VecHullEnd
    tracedata.filter = pEntity
    tracedata.mask = MASK_SOLID
    tracedata.mins = Mins
    tracedata.maxs = Maxs
    local tmpTrace = util.TraceLine(tracedata)

    if tmpTrace.Hit then
        tr = tmpTrace

        return tr
    end

    local Distance = 999999

    for i = 0, 1 do
        for j = 0, 1 do
            for k = 0, 1 do
                local VecEnd = Vector()
                VecEnd.x = VecHullEnd.x + (i > 0 and Maxs.x or Mins.x)
                VecEnd.y = VecHullEnd.y + (j > 0 and Maxs.y or Mins.y)
                VecEnd.z = VecHullEnd.z + (k > 0 and Maxs.z or Mins.z)
                tracedata.endpos = VecEnd
                tmpTrace = util.TraceLine(tracedata)

                if tmpTrace.Hit then
                    ThisDistance = (tmpTrace.HitPos - VecSrc):Length()

                    if (ThisDistance < Distance) then
                        tr = tmpTrace
                        Distance = ThisDistance
                    end
                end
            end
            -- for k
        end
        -- for j
    end
    --for i

    return tr
end

function SWEP:PrimaryAttack()
    local prim = cvars.Bool("csgo_knives_primary", true)
    local sec = cvars.Bool("csgo_knives_secondary", true)
    if not (prim or sec) or (CurTime() < self:GetNextPrimaryFire()) then return end
    self:DoAttack(not prim) -- If we can do primary attack, do it. Otherwise - do secondary.
end

function SWEP:ThrowKnife(force)
    local ent = ents.Create("mu_knife")
    ent:SetOwner(self.Owner)
    ent:SetPos(self.Owner:GetShootPos())
    local knife_ang = Angle(-28, 0, 0) + self.Owner:EyeAngles()
    knife_ang:RotateAroundAxis(knife_ang:Right(), -90)
    ent:SetAngles(knife_ang)
    ent:Spawn()
    local phys = ent:GetPhysicsObject()
    phys:SetVelocity(self.Owner:GetAimVector() * (force * 1000 + 200))
    phys:AddAngleVelocity(Vector(0, 1500, 0))
    self.Owner:DropWeapon(self)
    self:Remove()
end

function SWEP:SecondaryAttack()
    if SERVER then
        self:ThrowKnife(1)
    end
end

function SWEP:DoAttack(Altfire)
    local Weapon = self
    local Attacker = self:GetOwner()
    local Range = 30
    Attacker:LagCompensation(true)
    local Forward = Attacker:GetAimVector()
    local AttackSrc = Attacker:GetShootPos()
    local AttackEnd = AttackSrc + Forward * Range
    local tracedata = {}
    tracedata.start = AttackSrc
    tracedata.endpos = AttackEnd
    tracedata.filter = Attacker
    tracedata.mask = MASK_SOLID
    tracedata.mins = Vector(-16, -16, -18) -- head_hull_mins
    tracedata.maxs = Vector(16, 16, 18) -- head_hull_maxs
    local tr = util.TraceLine(tracedata)

    if not tr.Hit then
        tr = util.TraceHull(tracedata)
    end

    if tr.Hit and (not (IsValid(tr.Entity) and tr.Entity) or tr.HitWorld) then
        -- Calculate the point of intersection of the line (or hull) and the object we hit
        -- This is and approximation of the "best" intersection
        local HullDuckMins, HullDuckMaxs = Attacker:GetHullDuck()
        tr = self:FindHullIntersection(AttackSrc, tr, HullDuckMins, HullDuckMaxs, Attacker)
        AttackEnd = tr.HitPos -- This is the point on the actual surface (the hull could have hit space)
    end

    local DidHit = tr.Hit and not tr.HitSky
    local HitEntity = IsValid(tr.Entity) and tr.Entity or Entity(0) -- Ugly hack to destroy glass surf. 0 is worldspawn.
    local DidHitPlrOrNPC = HitEntity and IsValid(HitEntity) and (HitEntity:IsPlayer() or HitEntity:IsNPC())
    tr.HitGroup = HITGROUP_GENERIC -- Hack to disable damage scaling. No matter where we hit it, the damage should be as is.
    -- Calculate damage and deal hurt if we can
    local Backstab = cvars.Bool("csgo_knives_backstabs", true) and DidHitPlrOrNPC and self:EntityFaceBack(HitEntity) -- Because we can only backstab creatures
    local Force = Forward:GetNormalized() * 300 * cvars.Number("phys_pushscale", 1) -- simplified result of CalculateMeleeDamageForce()
    local damageinfo = DamageInfo()
    damageinfo:SetAttacker(Attacker)
    damageinfo:SetInflictor(self)
    damageinfo:SetDamage(self.Primary.Damage or 1)
    damageinfo:SetDamageType(DMG_SLASH)
    damageinfo:SetDamageForce(Force)
    damageinfo:SetDamagePosition(AttackEnd)

    if HitEntity then
        HitEntity:DispatchTraceAttack(damageinfo, tr, Forward)
    end

    if DidHitPlrOrNPC then
        local edata = EffectData()
        edata:SetStart(self.Owner:GetShootPos())
        edata:SetOrigin(tr.HitPos)
        edata:SetNormal(tr.Normal)
        edata:SetEntity(tr.Entity)
        util.Effect("BloodImpact", edata)
    end

    if tr.HitWorld and not tr.HitSky then
        if cvars.Bool("csgo_knives_decals", true) then
            util.Decal("ManhackCut", AttackSrc - Forward, AttackEnd + Forward, true)
        end

        if cvars.Bool("csgo_knives_hiteffect", true) then
            local effectdata = EffectData()
            effectdata:SetOrigin(tr.HitPos + tr.HitNormal)
            effectdata:SetStart(tr.StartPos)
            effectdata:SetSurfaceProp(tr.SurfaceProps)
            effectdata:SetDamageType(DMG_SLASH)
            effectdata:SetHitBox(tr.HitBox)
            effectdata:SetNormal(tr.HitNormal)
            effectdata:SetEntity(tr.Entity)
            effectdata:SetAngles(Forward:Angle())
            util.Effect("csgo_knifeimpact", effectdata)
        end
    end

    -- Change next attack time
    local NextAttack = Altfire and 1.0 or DidHit and 0.5 or 0.4
    Weapon:SetNextPrimaryFire(CurTime() + NextAttack)
    Weapon:SetNextSecondaryFire(CurTime() + NextAttack)
    -- Send animation to attacker
    Attacker:SetAnimation(PLAYER_ATTACK1)
    -- Send animation to viewmodel
    local Act = DidHit and (Altfire and (Backstab and ACT_VM_SWINGHARD or ACT_VM_HITCENTER2) or (Backstab and ACT_VM_SWINGHIT or ACT_VM_HITCENTER)) or (Altfire and ACT_VM_MISSCENTER2 or ACT_VM_MISSCENTER)

    if Act then
        Weapon:SendWeaponAnim(Act)
        self:SetIdleTime(CurTime() + self.Owner:GetViewModel():SequenceDuration())
    end

    -- Play sound
    -- Sound("...") were added to precache sounds
    local Oldsounds = cvars.Bool("csgo_knives_oldsounds", false)
    local StabSnd = Sound("csgo_knife.Stab")
    local HitSnd = Sound("csgo_knife.Hit")
    local HitwallSnd = Oldsounds and Sound("csgo_knife.HitWall_old") or Sound("csgo_knife.HitWall")
    local SlashSnd = Oldsounds and Sound("csgo_knife.Slash_old") or Sound("csgo_knife.Slash")

    if CLIENT and LocalPlayer() == self.Owner then
        local Snd = DidHitPlrOrNPC and (Altfire and StabSnd or HitSnd) or DidHit and HitwallSnd or SlashSnd
        Weapon:EmitSound(Snd)
    end

    Attacker:LagCompensation(false) -- Don't forget to disable it!
end

function SWEP:Reload()
    if self.Owner:IsNPC() then return end -- NPCs aren't supposed to reload it
    local keydown = self.Owner:KeyDown(IN_ATTACK) or self.Owner:KeyDown(IN_ATTACK2) or self.Owner:KeyDown(IN_ZOOM)
    if not cvars.Bool("csgo_knives_inspecting", true) or keydown then return end
    local getseq = self:GetSequence()
    local act = self:GetSequenceActivity(getseq) --GetActivity() method doesn't work :\

    if (act == ACT_VM_IDLE_LOWERED and CurTime() < self:GetInspectTime()) then
        self:SetInspectTime(CurTime() + 0.1) -- We should press R repeately instead of holding it to loop

        return
    end

    self:SendWeaponAnim(ACT_VM_IDLE_LOWERED)
    self:SetIdleTime(CurTime() + self.Owner:GetViewModel():SequenceDuration())
    self:SetInspectTime(CurTime() + 0.1)
end

function SWEP:Holster(wep)
    return true
end