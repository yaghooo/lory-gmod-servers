local PlayerMeta = FindMetaTable("Player")
util.AddNetworkString("mu_tker")

function PlayerMeta:SetTKer(tker)
    if tker then
        self.LastTKTime = CurTime()

        timer.Simple(0, function()
            if IsValid(self) and self:HasWeapon("weapon_mu_magnum") then
                local wep = self:GetWeapon("weapon_mu_magnum")
                wep.LastTK = self
                wep.LastTKTime = CurTime()
                self:DropWeapon(wep)
            end
        end)
    else
        self.LastTKTime = nil
    end

    net.Start("mu_tker")
    net.WriteBool(tker)
    net.Send(self)
    self:CalculateSpeed()
end

function PlayerMeta:GetTKer()
    return self.LastTKTime
end