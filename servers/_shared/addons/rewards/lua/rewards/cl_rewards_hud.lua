local image = Material("rewards/gift.png")

hook.Add("HUDPaint", "DrawRewardsNotice", function()
    if REWARDS.PrizesToClaim and REWARDS.PrizesToClaim > 0 then
        local M = Matrix()
        M:Translate(Vector(ScrW() / 2, ScrH() / 2))
        M:Rotate(Angle(0, math.sin(CurTime()), 0))
        M:Scale(Vector(1, 1) * (1 + 0.01 * math.sin(CurTime() * 2)))
        M:Translate(-Vector(ScrW() / 2, ScrH() / 2))
        cam.PushModelMatrix(M)

        local function drawShadowText(text, font, x, y, col, align, d)
            draw.DrawText(text, font, x + 1 * 2, y + 2, Color(0, 0, 0, col.a / 4), align)
            draw.DrawText(text, font, x + 1, y + 1, Color(0, 0, 0, col.a / 2), align)
            draw.DrawText(text, font, x, y, col, align)
        end

        local y = 150

        if not image:IsError() then
            surface.SetMaterial(image)
            surface.SetDrawColor(color_white)
            surface.DrawTexturedRect(ScrW() - 180, y, 80, 80)
            y = y + 80
        end

        drawShadowText(REWARDS.PrizesToClaim .. " prêmios para resgatar!", THEME.Font.Coolvetica24, ScrW() - 140, y, THEME.Color.Primary, TEXT_ALIGN_CENTER)
        drawShadowText("Pressione F4", THEME.Font.Coolvetica24, ScrW() - 140, y + 20, THEME.Color.Primary, TEXT_ALIGN_CENTER)
        cam.PopModelMatrix()
    end
end)