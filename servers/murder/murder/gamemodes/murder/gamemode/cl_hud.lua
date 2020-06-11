bystander_color = Color(20, 120, 255)
murderer_color = Color(190, 20, 20)

surface.CreateFont("MersText1", {
    font = "Tahoma",
    size = 16,
    weight = 1000,
    antialias = true,
    italic = false
})

surface.CreateFont("MersHead1", {
    font = "coolvetica",
    size = 24,
    weight = 500,
    antialias = true,
    italic = false
})

surface.CreateFont("MersRadial", {
    font = "coolvetica",
    size = math.ceil(ScrW() / 34),
    weight = 500,
    antialias = true,
    italic = false
})

surface.CreateFont("MersRadialBig", {
    font = "coolvetica",
    size = math.ceil(ScrW() / 24),
    weight = 500,
    antialias = true,
    italic = false
})

surface.CreateFont("MersRadialSmall", {
    font = "coolvetica",
    size = math.ceil(ScrW() / 60),
    weight = 100,
    antialias = true,
    italic = false
})

surface.CreateFont("MersDeathBig", {
    font = "coolvetica",
    size = math.ceil(ScrW() / 18),
    weight = 500,
    antialias = true,
    italic = false
})

local function drawTextShadow(t, f, x, y, c, px, py)
    color_black.a = c.a
    draw.SimpleText(t, f, x + 1, y + 1, color_black, px, py)
    draw.SimpleText(t, f, x, y, c, px, py)
    color_black.a = 255
end

function GM:HUDPaint()
    local round = self:GetRound()

    if round == 0 then
        drawTextShadow(translate.minimumPlayers, "MersRadial", ScrW() / 2, ScrH() - 10, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
    end

    local client = LocalPlayer()

    if client:Team() == 2 then
        if not client:Alive() then
            self:RenderRespawnText()
        else
            if round == 1 and self.RoundStart and self.RoundStart + 10 > CurTime() then
                self:DrawStartRoundInformation()
            elseif round == 2 or round == 1 then
                -- display who won
                self:DrawGameHUD(client)
            end
        end
    else
        self:RenderSpectate()
    end

    self:DrawRadialMenu()
end

function GM:DrawStartRoundInformation()
    local client = LocalPlayer()
    local t1 = translate.startHelpBystanderTitle
    local t2 = nil
    local c = bystander_color
    local desc = translate.table.startHelpBystander

    if self:IsMurderer() then
        t1 = translate.startHelpMurdererTitle

        if team.NumPlayers(2) > 12 then
            t2 = translate.startHelpMurdererSubtitle
        end

        desc = translate.table.startHelpMurderer
        c = murderer_color
    elseif client:HasWeapon("weapon_mu_magnum") then
        t1 = translate.startHelpGunTitle
        t2 = translate.startHelpGunSubtitle
        desc = translate.table.startHelpGun
    end

    drawTextShadow(t1, "MersRadial", ScrW() / 2, ScrH() * 0.25, c, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    if t2 then
        local h = draw.GetFontHeight("MersRadial")
        drawTextShadow(t2, "MersRadialSmall", ScrW() / 2, ScrH() * 0.25 + h * 0.7, Color(120, 70, 245), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    if desc then
        local fontHeight = draw.GetFontHeight("MersRadialSmall")

        for _, v in pairs(desc) do
            drawTextShadow(v, "MersRadialSmall", ScrW() / 2, ScrH() * 0.75 + (_ - 1) * fontHeight, c, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
end

local tex = surface.GetTextureID("SGM/playercircle")
local gradR = surface.GetTextureID("gui/gradient")

local function colorDif(col1, col2)
    local x = col1.x - col2.x
    local y = col1.y - col2.y
    local z = col1.z - col2.z
    x = x > 0 and x or -x
    y = y > 0 and y or -y
    z = z > 0 and z or -z

    return x + y + z
end

function GM:DrawGameHUD(ply)
    if not IsValid(ply) then return end
    --caching
    local client = LocalPlayer()
    local screenW, screenH = ScrW(), ScrH()
    local tr = ply:GetEyeTraceNoCursor()
    local lookingPlayer = IsValid(tr.Entity) and tr.Entity

    if client == ply and ply:GetNWBool("MurdererFog") and self:IsMurderer() then
        surface.SetDrawColor(10, 10, 10, 50)
        surface.DrawRect(-1, -1, screenW + 2, screenH + 2)
        drawTextShadow(translate.murdererFog, "MersRadial", screenW * 0.5, screenH - 80, Color(90, 20, 20), 1, TEXT_ALIGN_CENTER)
        drawTextShadow(translate.murdererFogSub, "MersRadialSmall", screenW * 0.5, screenH - 50, Color(130, 130, 130), 1, TEXT_ALIGN_CENTER)
    end

    if self:IsMurderer() then
        -- find closest button to cursor with usable range
        local dot, but

        for _, lbut in pairs(ents.FindByClass("ttt_traitor_button")) do
            local vec = lbut:GetPos() - ply:GetShootPos()
            local ldis, ldot = vec:Length(), vec:GetNormal():Dot(ply:GetAimVector())

            if (ldis < lbut:GetUsableRange() and ldot > 0.95) and (not but or ldot > dot) then
                dis = ldis
                dot = ldot
                but = lbut
            end
        end

        -- draw the friggen button with excessive text
        if but then
            local sp = but:GetPos():ToScreen()

            if sp.visible then
                local col = Color(190, 20, 20)

                if but:GetNextUseTime() > CurTime() then
                    col = Color(150, 150, 150)
                end

                local ft, fh = draw.GetFontHeight("MersText1"), draw.GetFontHeight("MersHead1")
                drawTextShadow(but:GetDescription(), "MersHead1", sp.x, sp.y, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                local text

                if but:GetNextUseTime() > CurTime() then
                    text = Translator:VarTranslate(translate.ttt_tbut_waittime, {
                        timesec = math.ceil(but:GetNextUseTime() - CurTime()) .. "s"
                    })
                elseif but:GetDelay() < 0 then
                    text = translate.ttt_tbut_single
                elseif but:GetDelay() == 0 then
                    text = translate.ttt_tbut_reuse
                else
                    text = Translator:VarTranslate(translate.ttt_tbut_retime, {
                        num = but:GetDelay()
                    })
                end

                drawTextShadow(text, "MersText1", sp.x, sp.y + fh, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                local key = input.LookupBinding("use")

                if key and but:GetNextUseTime() <= CurTime() then
                    text = Translator:VarTranslate(translate.ttt_tbut_help, {
                        key = key:upper()
                    })

                    drawTextShadow(text, "MersText1", sp.x, sp.y + ft + fh, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            end
        end

        if self.LootCollected and self.LootCollected >= 1 and lookingPlayer and lookingPlayer:IsPlayer() and lookingPlayer:GetClass() == "prop_ragdoll" and tr.HitPos:Distance(tr.StartPos) < 80 and (lookingPlayer:GetBystanderName() ~= ply:GetBystanderName() or colorDif(lookingPlayer:GetPlayerColor(), ply:GetPlayerColor()) > 0.1) then
            local h = draw.GetFontHeight("MersRadial")
            drawTextShadow(translate.pressEToDisguiseFor1Loot, "MersRadialSmall", screenW / 2, screenH / 2 + 80 + h * 0.7, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    -- draw names
    if lookingPlayer and (lookingPlayer:IsPlayer() or lookingPlayer:GetClass() == "prop_ragdoll") and tr.HitPos:Distance(tr.StartPos) < 500 then
        self.LastLooked = lookingPlayer
        self.LookedFade = CurTime()
    end

    if IsValid(self.LastLooked) and self.LookedFade + 2 > CurTime() then
        local name = self.LastLooked:GetBystanderName() or "error"
        local color = self.LastLooked:GetPlayerColor():ToColor()
        color.a = (1 - (CurTime() - self.LookedFade) / 2) * 255
        drawTextShadow(name, "MersRadial", screenW / 2, screenH / 2 + 80, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    -- setup size
    local size = screenW * 0.08
    -- draw black circle
    surface.SetTexture(tex)
    surface.SetDrawColor(color_black)
    surface.DrawTexturedRect(size * 0.1, screenH - size * 1.1, size, size)
    -- draw health circle
    surface.SetTexture(tex)
    local color = ply:GetPlayerColor():ToColor()
    surface.SetDrawColor(color)
    local hsize = math.Clamp(ply:Health(), 0, 100) / 100 * size
    surface.DrawTexturedRect(size * 0.1 + (size - hsize) / 2, screenH - size * 1.1 + (size - hsize) / 2, hsize, hsize)

    if client == ply then
        drawTextShadow(self.LootCollected or "error", "MersRadialBig", size * 0.6, screenH - size * 0.6, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    surface.SetFont("MersRadialSmall")
    local w = surface.GetTextSize(ply:GetBystanderName())
    local x = math.max(size * 0.6 + w / -2, size * 0.1)
    drawTextShadow(ply:GetBystanderName(), "MersRadialSmall", x, screenH - size * 1.1, color, 0, TEXT_ALIGN_BOTTOM)

    if client == ply and (ply:FlashlightIsOn() or self:GetFlashlightCharge() < 1) then
        size = screenW * 0.08
        x = size * 1.2
        w = screenW * 0.08
        local h = screenH * 0.03
        local bord = math.Round(screenW * 0.08 * 0.03)

        if ply:FlashlightIsOn() then
            surface.SetDrawColor(0, 0, 0, 240)
        else
            surface.SetDrawColor(5, 5, 5, 180)
        end

        surface.DrawRect(x, screenH - h - size * 0.2, w, h)
        local charge = self:GetFlashlightCharge()

        if ply:FlashlightIsOn() then
            surface.SetDrawColor(50, 180, 220, 240)
        else
            surface.SetDrawColor(50, 180, 220, 180)
        end

        surface.DrawRect(x + bord, screenH - h - size * 0.2 + bord, (w - bord * 2) * charge, h - bord * 2)
        surface.SetTexture(gradR)
        surface.SetDrawColor(255, 255, 255, 50)
        surface.DrawTexturedRect(x + bord, screenH - h - size * 0.2 + bord, (w - bord * 2) * charge, h - bord * 2)
    end

    if client == ply then
        local name = translate.bystander
        color = bystander_color

        if client == ply and self:IsMurderer() then
            name = translate.murderer
            color = murderer_color
        end

        drawTextShadow(name, "MersRadial", screenW - 20, screenH - 10, color, 2, TEXT_ALIGN_BOTTOM)
    end
end

function GM:GUIMousePressed(code, vector)
end

function GM:RenderScreenspaceEffects()
    if not LocalPlayer():Alive() then
        self:RenderDeathOverlay()
    end

    if self:GetRound() == 1 and self.RoundStart and self.RoundStart + 10 > CurTime() then
        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawRect(-1, -1, ScrW() + 2, ScrH() + 2)
    end
end

function GM:PostDrawHUD()
    if self:GetRound() == 1 and self.TKerPenalty then
        local dest = 254
        self.ScreenDarkness = math.Clamp(math.Approach(self.ScreenDarkness or 0, dest, FrameTime() * 120), 0, 255)

        if self.ScreenDarkness > 0 then
            local sw, sh = ScrW(), ScrH()
            surface.SetDrawColor(0, 0, 0, self.ScreenDarkness)
            surface.DrawRect(-1, -1, sw + 2, sh + 2)
        end
    else
        self.ScreenDarkness = 0
    end
end

function GM:HUDShouldDraw(name)
    -- hide health and armor
    if name == "CHudHealth" or name == "CHudBattery" then return false end

    return true
end

function GM:GUIMousePressed(code, vector)
    return self:RadialMousePressed(code, vector)
end