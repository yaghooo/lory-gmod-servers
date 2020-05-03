local HideElements = {
    ["CHudBattery"] = false,
    ["CHudHealth"] = false,
    ["CHudAmmo"] = false
}

function GM:HUDShouldDraw(el)
    local hide = HideElements[el]

    return hide ~= false
end

local RoundNames = {}
RoundNames[ROUND_WAITING] = "Esperando por Jogadores"
RoundNames[ROUND_PREP] = "Preparando"
RoundNames[ROUND_ACTIVE] = "Faltam"
RoundNames[ROUND_OVER] = "Round Acabou"

local RoundEndData = {
    Active = false,
    BeginTime = 0
}

net.Receive("DeathrunSendMVPs", function()
    RoundEndData = net.ReadTable()
    RoundEndData.BeginTime = CurTime()
    RoundEndData.Active = true

    if RoundEndData.winteam == 1 then
        local stalematesounds = {"ambient/animal/cow.wav", "ambient/misc/flush1.wav", "npc/crow/alert2.wav", "ambient/animal/dog_med_inside_bark_2.wav"}
        surface.PlaySound(table.Random(stalematesounds))
    else
        local endingsounds = {"ambient/alarms/warningbell1.wav"}
        surface.PlaySound(table.Random(endingsounds))
    end

    hook.Call("DeathrunRoundWin", nil, RoundEndData.winteam)
end)

function DR:DrawTargetID(w, h)
    local tr = LocalPlayer() and LocalPlayer():GetEyeTrace() or {}

    if tr.Hit and tr.Entity and tr.Entity:IsPlayer() and tr.Entity:Team() ~= TEAM_GHOST then
        targetName = tr.Entity:Nick()
        targetColor = team.GetColor(tr.Entity:Team())
        targetEntity = tr.Entity
        local x, y = w / 2, h / 2 + 48
        local tidText = targetName .. (IsValid(targetEntity) and " - " .. tostring(math.Clamp(targetEntity:Health(), 0, 100)) .. "%" or "")
        THEME:DrawShadowText(tidText, THEME.Font.Coolvetica24, x, y, targetColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

local transColor = ColorAlpha(color_white, 50)

function DR:DrawPlayerHUDAmmo(x, y)
    local ply = LocalPlayer()

    if ply:GetObserverMode() ~= OBS_MODE_NONE and IsValid(ply:GetObserverTarget()) then
        ply = ply:GetObserverTarget()
    end

    local wepdata = GetWeaponHUDData(ply)

    if wepdata and wepdata.HoldType ~= "melee" and wepdata.HoldType ~= "knife" then
        y = y + 32
        surface.SetDrawColor(THEME.Color.Primary) -- name of wep
        surface.DrawRect(x, y, 228, 32)
        THEME:DrawShadowText(tostring(wepdata.Name), THEME.Font.Coolvetica30, x + 224, y + 32 / 2 - 1, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

        if wepdata.ShouldDrawHUD then
            y = y + 32 + 4
            local frac = wepdata.Clip1 / wepdata.Clip1Max
            frac = math.Clamp(frac, 0, 1)
            surface.SetDrawColor(THEME.Color.Primary)
            surface.DrawRect(x, y, 32, 32)
            surface.SetDrawColor(transColor)
            surface.DrawRect(x + 32 + 4, y, 192, 32)
            surface.SetDrawColor(THEME.Color.Primary)
            surface.DrawRect(x + 32 + 4, y, 192 * frac, 32)
            THEME:DrawShadowText("AM", THEME.Font.Coolvetica20, x + 32 / 2, y + 32 / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            THEME:DrawShadowText(tostring(wepdata.Clip1) .. " +" .. tostring(wepdata.Remaining1), THEME.Font.Coolvetica30, x + 32 + 192, y + 32 / 2 - 1, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end
    end
end

function DR:DrawCustomPlayerHUD(x, y)
    local ply = LocalPlayer()

    if ply:GetObserverMode() ~= OBS_MODE_NONE and IsValid(ply:GetObserverTarget()) then
        ply = ply:GetObserverTarget()
    end

    local teamId = ply:Team()
    local teamColor = team.GetColor(teamId)

    surface.SetDrawColor(teamColor)
    surface.DrawRect(x, y, 228, 16) -- team box
    surface.SetDrawColor(ColorAlpha(color_black, 100))
    surface.DrawRect(x, y + 14, 228, 2)
    local teamtext = ply ~= LocalPlayer() and string.upper(ply:Nick()) or string.upper(team.GetName(teamId))
    THEME:DrawShadowText(teamtext, THEME.Font.Coolvetica18, x + 228 / 2, y + 16 / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) -- team name
    y = y + 16 + 4
    surface.SetDrawColor(THEME.Color.Secondary) -- Time Left
    surface.DrawRect(x, y, 228, 16)
    THEME:DrawShadowText(string.upper(RoundNames[ROUND:GetCurrent()] or "FALTAM"), THEME.Font.Coolvetica16, x + 4, y + 16 / 2, teamColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    THEME:DrawShadowText(string.ToMinutesSeconds(math.Clamp(ROUND:GetTimer(), 0, 99999)), THEME.Font.Coolvetica20, x + 228 - 4, y + 16 / 2, teamColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    y = y + 16 + 4
    surface.SetDrawColor(THEME.Color.Primary) -- hp bar
    surface.DrawRect(x, y, 32, 32)
    surface.SetDrawColor(transColor)
    surface.DrawRect(x + 32 + 4, y, 192, 32)
    local maxhp = 100 -- yeah fuck yall
    local curhp = math.Clamp(ply:Health(), 0, maxhp)
    local hpfrac = InverseLerp(curhp, 0, maxhp)
    surface.SetDrawColor(THEME.Color.Primary)
    surface.DrawRect(x + 32 + 4, y, 192 * hpfrac, 32)
    -- hp text
    THEME:DrawShadowText("HP", THEME.Font.Coolvetica28, x + 32 / 2, y + 32 / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    THEME:DrawShadowText(tostring(curhp), THEME.Font.Coolvetica28, x + 32 + 4 + 4, y + 32 / 2 - 1, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    y = y + 32 + 4
    local velColor = Color(255, 182, 0)
    surface.SetDrawColor(velColor) -- vel bar
    surface.DrawRect(x, y, 32, 32)
    surface.SetDrawColor(transColor)
    surface.DrawRect(x + 32 + 4, y, 192, 32)
    local maxvel = 1000 -- yeah fuck yall
    local curvel = math.Round(math.Clamp(ply:GetVelocity():Length2D(), 0, maxvel))
    local velfrac = InverseLerp(curvel, 0, maxvel)
    surface.SetDrawColor(velColor)
    surface.DrawRect(x + 32 + 4, y, 192 * velfrac, 32)
    -- vel text
    THEME:DrawShadowText("VL", THEME.Font.Coolvetica28, x + 32 / 2, y + 32 / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1)
    THEME:DrawShadowText(curvel, THEME.Font.Coolvetica28, x + 32 + 4 + 4, y + 32 / 2 - 1, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1)
end

function DR:DrawWinners(winteam, tbl_mvps, x, y, stalemate)
    local col = stalemate == false and team.GetColor(winteam) or THEME.Color.Secondary
    local w, h = 628, 88
    local mw, mh = w, 24
    local gap = 4
    surface.SetDrawColor(col)
    surface.DrawRect(x, y, w, h)

    if not stalemate then
        surface.SetDrawColor(color_white)
        surface.DrawRect(x, y + h + gap, mw, mh)
        -- draw MVPs
        surface.SetDrawColor(col)

        for i = 1, #tbl_mvps do
            local name = tbl_mvps[i]

            if name then
                surface.DrawRect(x, y + h + (gap + mh) * i + gap, mw, mh)
                THEME:DrawShadowText(name, THEME.Font.Coolvetica24, x + w / 2, y + h + (gap + mh) * i + gap + mh / 2 - 1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1)
            end
        end
    end

    THEME:DrawShadowText(stalemate == false and string.upper(team.GetName(winteam) .. " GANHARAM O ROUND!") or "EMPATE!", THEME.Font.Coolvetica30, x + w / 2, y + h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1)
    surface.SetDrawColor(color_white)
    surface.DrawRect(x, y + h + gap, mw, mh)
    THEME:DrawShadowText(stalemate and "VOCÊS SÃO TODOS RUINS!" or "JOGADORES MAIS PRECIOSOS", THEME.Font.Coolvetica24, x + w / 2, y + h + gap + mh / 2 - 1, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 0)
end

function GetWeaponHUDData(ply)
    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) then return nil end
    local data = {}
    local weptable = {}
    weptable = wep:GetTable()
    data.Name = wep:GetPrintName() or "Weapon"
    data.Clip1 = wep:Clip1() or -1
    data.Clip2 = wep:Clip2() or -1
    data.Clip1Max = 1
    data.Clip2Max = 1
    data.Remaining1 = ply:GetAmmoCount(wep:GetPrimaryAmmoType()) or wep:Ammo1() or 0
    data.Remaining2 = ply:GetAmmoCount(wep:GetSecondaryAmmoType()) or wep:Ammo2() or 0
    data.HoldType = weptable.HoldType or "melee"

    if weptable.Primary then
        data.Clip1Max = weptable.Primary.ClipSize or data.Clip2Max
    end

    if weptable.Secondary then
        data.Clip2Max = weptable.Secondary.ClipSize or data.Clip2Max
    end

    data.ShouldDrawHUD = true

    if data.Clip1 < 0 then
        data.ShouldDrawHUD = false
    end

    return data
end

function GM:HUDPaint()
    local w, h = ScrW(), ScrH()
    DR:DrawTargetID(w, h)
    local hud_positions = {{8, 8}, {w / 2 - 228 / 2, 8}, {w - 228 - 8, 8}, {8, h / 2 - 108 / 2}, {w / 2 - 228 / 2, h / 2 - 108 / 2}, {w - 228 - 8, h / 2 - 108 / 2}, {8, h - 108 - 8}, {w / 2 - 228 / 2, h - 108 - 8}, {w - 228 - 8, h - 108 - 8}}
    local hudPos = DR.HudPos:GetInt()
    local hudAmmoPos = DR.HudAmmoPos:GetInt()
    local hx = hud_positions[hudPos + 1][1] or 8
    local hy = hud_positions[hudPos + 1][2] or 8
    local ax = hud_positions[hudAmmoPos + 1][1] or 8
    local ay = hud_positions[hudAmmoPos + 1][2] or 8
    DR:DrawCustomPlayerHUD(hx, hy)
    DR:DrawPlayerHUDAmmo(ax, ay)

    -- check if it's stalemate, and don't do the thing, zhu li!
    if RoundEndData.Active then
        DR:DrawWinners(RoundEndData.winteam, RoundEndData.mvps, w / 2 - 628 / 2, 24, RoundEndData.winteam == 1)

        if CurTime() > RoundEndData.BeginTime + RoundEndData.duration then
            RoundEndData.Active = false
        end
    end
end