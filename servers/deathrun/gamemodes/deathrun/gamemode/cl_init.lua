include("sh_init.lua")

function DR:ChatMessage(msg)
    chat.AddText(color_white, "[", THEME.Color.Primary, "Lory", color_white, "] ", msg)
end

net.Receive("DeathrunChatMessage", function(len, ply)
    DR:ChatMessage(net.ReadString())
end)

net.Receive("DeathrunSyncMutelist", function(len, ply)
    LocalPlayer().mutelist = net.ReadTable()
end)

hook.Add("CalcView", "DrawSelfView", function(ply, pos, ang, fov, nearz, farz)
    if DR.ThirdpersonOn:GetBool() == true and ply:Alive() and (ply:Team() ~= TEAM_SPECTATOR) then
        local view = {}
        local newpos = Vector(0, 0, 0)
        local dist = 100 + ThirdpersonZ:GetFloat()

        local tr = util.TraceHull({
            start = pos,
            endpos = pos + ang:Forward() * -dist + Vector(0, 0, 9) + ang:Right() * ThirdpersonX:GetFloat() + ang:Up() * ThirdpersonY:GetFloat(),
            mins = Vector(-5, -5, -5),
            maxs = Vector(5, 5, 5),
            filter = player.GetAll(),
            mask = MASK_SHOT_HULL
        })

        newpos = tr.HitPos
        view.origin = newpos
        local newang = ang
        newang:RotateAroundAxis(ply:EyeAngles():Right(), ThirdpersonPitch:GetFloat())
        newang:RotateAroundAxis(ply:EyeAngles():Up(), ThirdpersonYaw:GetFloat())
        newang:RotateAroundAxis(ply:EyeAngles():Forward(), ThirdpersonRoll:GetFloat())
        view.angles = newang
        view.fov = fov
        -- test for thirdperson scoped weapons
        local wep = ply:GetActiveWeapon()

        if wep and wep.Scope and wep:GetIronsights() then
            view.fov = wep.ScopedFOV or fov
        end

        return view
    end
end)

hook.Add("ShouldDrawLocalPlayer", "DrawSelf", function()
    local ply = LocalPlayer()
    if DR.ThirdpersonOn:GetBool() and ply:Alive() and (ply:Team() ~= TEAM_SPECTATOR) then return true end
end)

hook.Add("CreateMove", "CheckClientsideKeyBinds", function()
    if input.WasKeyPressed(KEY_F8) then
        DR.ThirdpersonOn:SetBool(not tobool(DR.ThirdpersonOn:GetBool()))
    end
end)

hook.Add("PrePlayerDraw", "TransparencyPlayers", function(ply)
    if ply:GetRenderMode() ~= RENDERMODE_TRANSALPHA then
        ply:SetRenderMode(RENDERMODE_TRANSALPHA)
    end

    local fadedistance = DR.TeamFadeDistance:GetInt()
    local eyedist = LocalPlayer():EyePos():Distance(ply:EyePos())
    local col = ply:GetColor()

    if eyedist < fadedistance and LocalPlayer() ~= ply then
        local frac = InverseLerp(eyedist, 5, fadedistance)
        col.a = Lerp(frac, 20, 255)

        if ply:Team() ~= LocalPlayer():Team() then
            col.a = 255
        end

        ply:SetColor(col)
    else
        col.a = LocalPlayer() == ply and DR.ThirdpersonOpacity:GetInt() or 255
        ply:SetColor(col)
    end
end)

function GM:PreDrawViewModel(vm, ply, wep)
    ply = ply or LocalPlayer()
    if ply:GetObserverMode() == OBS_MODE_CHASE or ply:GetObserverMode() == OBS_MODE_ROAMING then return true end
end

function GM:PreDrawPlayerHands(hands, vm, ply, wep)
    if ply:GetObserverMode() == OBS_MODE_CHASE or ply:GetObserverMode() == OBS_MODE_ROAMING then return true end
end

function GM:PlayerFootstep(ply, pos, foot, sound, volume, filter)
    if ply:Team() == TEAM_GHOST then return true end
end

concommand.Add("+menu", function()
    RunConsoleCommand("deathrun_dropweapon")
end)