local image = Material("rewards/gift.png")

hook.Add("HUDPaint", "DrawRewardsNotice", function()
    if REWARDS.PrizesToClaim and REWARDS.PrizesToClaim > 0 then
        local M = Matrix()
        M:Translate(Vector(ScrW() / 2, ScrH() / 2))
        M:Rotate(Angle(0, math.sin(CurTime()), 0))
        M:Scale(Vector(1, 1) * (1 + 0.01 * math.sin(CurTime() * 2)))
        M:Translate(-Vector(ScrW() / 2, ScrH() / 2))
        cam.PushModelMatrix(M)

        local y = 150

        if not image:IsError() then
            surface.SetMaterial(image)
            surface.SetDrawColor(color_white)
            surface.DrawTexturedRect(ScrW() - 180, y, 80, 80)
            y = y + 80
        end

        THEME:DrawShadowText(REWARDS.PrizesToClaim .. " prêmios para resgatar!", THEME.Font.Coolvetica24, ScrW() - 140, y, THEME.Color.Primary, TEXT_ALIGN_CENTER)
        THEME:DrawShadowText("Pressione F4", THEME.Font.Coolvetica24, ScrW() - 140, y + 20, THEME.Color.Primary, TEXT_ALIGN_CENTER)
        cam.PopModelMatrix()
    end
end)