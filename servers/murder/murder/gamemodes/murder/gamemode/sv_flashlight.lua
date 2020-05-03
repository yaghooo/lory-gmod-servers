util.AddNetworkString("flashlight_charge")

function GM:FlashlightThink()
    local curTime = CurTime()
    if self.FlashlightLastThink and self.FlashlightLastThink > curTime - 0.1 then return end
    self.FlashlightLastThink = curTime
    local battery = self.FlashlightBattery:GetFloat()

    if battery > 0 then
        local decay = FrameTime() * 10 / battery

        for _, ply in ipairs(player.GetAll()) do
            if ply:Alive() then
                if ply:FlashlightIsOn() then
                    ply:SetFlashlightCharge(math.Clamp(ply:GetFlashlightCharge() - decay, 0, 1))
                else
                    ply:SetFlashlightCharge(math.Clamp(ply:GetFlashlightCharge() + decay / 2, 0, 1))
                end
            end
        end
    end
end

function GM:PlayerSwitchFlashlight(ply, turningOn)
    return not (turningOn and ply.FlashlightPenalty and ply.FlashlightPenalty > CurTime())
end

local PlayerMeta = FindMetaTable("Player")

function PlayerMeta:GetFlashlightCharge()
    return self.FlashlightCharge or 1
end

function PlayerMeta:SetFlashlightCharge(charge)
    if self.FlashlightCharge ~= charge then
        self.FlashlightCharge = charge

        if charge <= 0 then
            self.FlashlightPenalty = CurTime() + 1.5

            if self:FlashlightIsOn() then
                self:Flashlight(false)
            end
        end

        net.Start("flashlight_charge")
        net.WriteFloat(self.FlashlightCharge)
        net.Send(self)
    end
end