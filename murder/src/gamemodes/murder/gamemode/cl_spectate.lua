spectating_color = Color(20, 120, 255)
name_color = Color(190, 190, 190)

net.Receive("spectating_status", function()
    GAMEMODE.SpectateMode = net.ReadInt(8)
    GAMEMODE.Spectating = false
    GAMEMODE.Spectatee = nil

    if GAMEMODE.SpectateMode >= 0 then
        GAMEMODE.Spectating = true
        GAMEMODE.Spectatee = net.ReadEntity()
    end
end)

function GM:IsCSpectating()
    return self.Spectating
end

function GM:GetCSpectatee()
    return self.Spectatee
end

function GM:GetCSpectateMode()
    return self.SpectateMode
end

local function drawTextShadow(t, f, x, y, c, px, py)
    color_black.a = c.a
    draw.SimpleText(t, f, x + 1, y + 1, color_black, px, py)
    draw.SimpleText(t, f, x, y, c, px, py)
    color_black.a = 255
end

function GM:RenderSpectate()
    if self:IsCSpectating() then
        drawTextShadow(translate.spectating, "MersRadial", ScrW() / 2, ScrH() - 100, spectating_color, 1)
        local spectatee = self:GetCSpectatee()

        if IsValid(spectatee) and spectatee:IsPlayer() then
            local h = draw.GetFontHeight("MersRadial")
            drawTextShadow(spectatee:Nick(), "MersRadialSmall", ScrW() / 2, ScrH() - 100 + h, name_color, 1)

            if self.DrawGameHUD and GAMEMODE.RoundSettings.ShowSpectateInfo then
                self:DrawGameHUD(spectatee)
            end
        end
    end
end