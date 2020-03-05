-- Proxy Example:
--
--	Proxies
--	{
--		PlayerColor
--		{
--			resultVar	$color2
--		}
--	}
matproxy.Add({
    name = "PlayerColor",
    init = function(self, mat, values)
        self.ResultTo = values.resultvar
    end,
    bind = function(self, mat, ent)
        if not IsValid(ent) then return end

        if ent.GetPlayerColor then
            local col = ent:GetPlayerColor()

            if isvector(col) then
                mat:SetVector(self.ResultTo, col)
            end
        else
            mat:SetVector(self.ResultTo, Vector(62.0 / 255.0, 88.0 / 255.0, 106.0 / 255.0))
        end
    end
})