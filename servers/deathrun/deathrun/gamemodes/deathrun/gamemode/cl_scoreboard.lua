local columns = {"Name", "blank", "Frag", "Rank", "Ping"}
local columnFunctions = {function(ply) return ply:Nick() end, nil, function(ply) return ply:Frags() end, function(ply) return string.upper(ply:GetUserGroup()) end, function(ply) return ply:Ping() end} -- empty space to even the spacings out

function DR:CreateScoreboard()
    local scoreboard = DR.ScoreboardPanel

    if not IsValid(DR.ScoreboardPanel) then
        scoreboard = vgui.Create("DPanel")
        scoreboard:SetSize(ScrW() / 2, ScrH() - 100)
        scoreboard:SetPos(0, ScrH() + 50)
        scoreboard:CenterHorizontal()
        scoreboard.dt = 0
        scoreboard.lastthink = CurTime()

        function scoreboard:Think()
            local dt = CurTime() - self.lastthink
            self.lastthink = CurTime()
            local x, y = self:GetPos()
            local dur = 0.2 -- 2 seconds
            self.dt = math.Clamp(self.dt + (DR.ScoreboardIsOpen and dt or -dt), 0, dur)
            self:SetPos(x, QuadLerp(math.Clamp(InverseLerp(self.dt, 0, dur), 0, 1), ScrH() + 50, 50))

            if DR.ScoreboardIsOpen == false and y > ScrH() then
                self:Remove()
            end
        end

        DR.ScoreboardPanel = scoreboard
    end

    scoreboard = DR.ScoreboardPanel

    function scoreboard:Paint(w, h)
        surface.SetDrawColor(color_white)
    end

    local scr = vgui.Create("DScrollPanel", scoreboard)
    scr:SetSize(scoreboard:GetWide(), scoreboard:GetTall())
    scr:SetPos(0, 0)
    local vbar = scr:GetVBar()
    vbar:SetWide(0)
    local dlist = vgui.Create("DIconLayout", scr)
    dlist:SetSize(scoreboard:GetWide(), 1500)
    dlist:SetPos(0, 0)
    dlist:SetSpaceX(0)
    dlist:SetSpaceY(4)
    local header = vgui.Create("DPanel")
    header:SetSize(dlist:GetWide(), 48)
    header.counter = 0.5

    function header:Paint(w, h)
        surface.SetDrawColor(THEME.Color.Primary)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(255, 255, 255, 155 * (1 - math.pow((math.sin(CurTime()) + 1) / 2, 0.1)))
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(0, 0, 0, 100)
        surface.DrawRect(0, h - 3, w, 3)
        -- make the hostname scroll left and right
        surface.SetFont(THEME.Font.Coolvetica30)

        local hostname = GetHostName()
        local fw, _ = surface.GetTextSize(hostname)
        fw = fw + 64 -- 64 pixel gap

        self.counter = self.counter + FrameTime() / 12
        if self.counter > 1 then
            self.counter = 0
        end

        if fw > self:GetWide() then
            THEME:DrawShadowText(hostname, THEME.Font.Coolvetica30, 4 + fw - self.counter * fw, h / 2 - 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            THEME:DrawShadowText(hostname, THEME.Font.Coolvetica30, 4 - self.counter * fw, h / 2 - 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        else
            THEME:DrawShadowText(hostname, THEME.Font.Coolvetica30, w / 2, h / 2 - 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    dlist:Add(header)
    dlist:Add(DR:NewScoreboardSpacer({tostring(#team.GetPlayers(TEAM_DEATH)) .. " players on Death Team"}, dlist:GetWide(), 32, team.GetColor(TEAM_DEATH)))

    for k, ply in ipairs(team.GetPlayers(TEAM_DEATH)) do
        dlist:Add(DR:NewScoreboardPlayer(ply, dlist:GetWide(), 28))
    end

    dlist:Add(DR:NewScoreboardSpacer({tostring(#team.GetPlayers(TEAM_RUNNER)) .. " players on Runner Team"}, dlist:GetWide(), 32, team.GetColor(TEAM_RUNNER)))

    for k, ply in ipairs(team.GetPlayers(TEAM_RUNNER)) do
        dlist:Add(DR:NewScoreboardPlayer(ply, dlist:GetWide(), 28))
    end

    -- GhostMode support
    if GhostMode then
        dlist:Add(DR:NewScoreboardSpacer({tostring(#team.GetPlayers(TEAM_GHOST)) .. " players in Ghost Mode"}, dlist:GetWide(), 32, team.GetColor(TEAM_GHOST)))

        for k, ply in ipairs(team.GetPlayers(TEAM_GHOST)) do
            dlist:Add(DR:NewScoreboardPlayer(ply, dlist:GetWide(), 28))
        end
    end

    dlist:Add(DR:NewScoreboardSpacer({tostring(#team.GetPlayers(TEAM_SPECTATOR)) .. " players Spectating"}, dlist:GetWide(), 32, color_white))

    for k, ply in ipairs(team.GetPlayers(TEAM_SPECTATOR)) do
        dlist:Add(DR:NewScoreboardPlayer(ply, dlist:GetWide(), 28))
    end

    dlist:SizeToChildren()
    DR.ScoreboardPanel = scoreboard
    DR.ScoreboardIsOpen = true
end

-- static columns
function DR:NewScoreboardSpacer(tbl_cols, w, h, customColor)
    local panel = vgui.Create("DPanel")
    panel:SetSize(w, h)
    panel.tbl_cols = tbl_cols
    panel.customColor = customColor

    function panel:Paint(w2, h2)
        surface.SetDrawColor(THEME.Color.Secondary)
        surface.DrawRect(0, 0, w2, h2)
        w = w - 8
    end

    for i = 1, #tbl_cols do
        local k = i - 1
        local align = 0.5

        if i <= 1 then
            align = 0
        end

        if i >= #tbl_cols then
            align = 1
        end

        local label = vgui.Create("DLabel", panel)
        label:SetText(tbl_cols[i])
        label:SetTextColor(customColor)
        label:SetFont(THEME.Font.Coolvetica20)
        label:SizeToContents()
        label:SetPos(#tbl_cols > 1 and 4 + (k * ((panel:GetWide() - 8) / (#tbl_cols - 1)) - label:GetWide() * align) or (panel:GetWide() - 8) / 2 - label:GetWide() / 2, 0)
        label:CenterVertical()
    end

    return panel
end

local muteicon = Material("icon16/sound_mute.png")

function DR:NewScoreboardPlayer(ply, w, h)
    local t = ply:Team()
    local tcol = team.GetColor(t)
    local panel = vgui.Create("DPanel")
    panel:SetSize(w, h)
    panel.bgcol = tcol
    panel.ply = ply

    function panel:Paint(w2, h2)
        surface.SetDrawColor(self.bgcol)
        surface.DrawRect(0, 0, w2, h2)

        if IsValid(self.ply) and not self.ply:Alive() then
            surface.SetDrawColor(Color(255, 255, 255, 70))
            surface.DrawRect(0, 0, w2, h2)
        end
    end

    local av = vgui.Create("AvatarImage", panel)
    av:SetSize(h, h)
    av:SetPos(0, 0)
    av:SetPlayer(ply)
    av.ply = ply

    function av:PaintOver(w2, h2)
        if IsValid(self.ply) and not self.ply:Alive() then
            surface.SetDrawColor(Color(255, 255, 255, 100))
            surface.DrawRect(0, 0, w2, h2)
            draw.SimpleText("✖", THEME.Font.Coolvetica30, w2 / 2, h2 / 2 - 1, THEME.Color.Primary, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        if self.ply:IsValid() and table.HasValue(LocalPlayer().mutelist or {}, self.ply:SteamID()) then
            surface.SetMaterial(muteicon)
            surface.SetDrawColor(Color(255, 255, 255, 100))
            surface.DrawRect(0, 0, w2, h2)
            surface.SetDrawColor(Color(255, 255, 255, 255))
            surface.DrawTexturedRect(h2 / 2 - 8, w2 / 2 - 8, 16, 16)
        end
    end

    local data = vgui.Create("DPanel", panel)
    data:SetSize(w - (h * 2) - 8, h)
    data:SetPos((h * 2) + 8, 0)
    data.bgcol = tcol
    data.ply = ply
    -- get scoreboard icon
    local icon = vgui.Create("DPanel", panel)
    icon:SetSize(h, h)
    icon:SetPos(h, 0)
    local path = false

    if ply:IsAdmin() or ply:IsSuperAdmin() then
        path = "icon16/shield.png"
    elseif string.match(string.lower(ply:Nick()), "lory") then
        path = "icon16/heart.png"
    end

    local tpath = hook.Call("GetScoreboardIcon", nil, ply)

    if tpath then
        path = tpath
    end

    icon.Mat = path and Material(path) or false

    function icon:Paint(w2, h2)
        if self.Mat ~= false then
            surface.SetDrawColor(255, 255, 255)
            surface.SetMaterial(self.Mat)
            surface.DrawTexturedRect(0 + w / 2 - 8, 0 + h / 2 - 8, 16, 16)
        end
    end

    function data:Paint(w2, h2)
    end

    for i = 1, #columns do
        local k = i - 1
        local align = 0.5

        if i <= 1 then
            align = 0
        end

        if i >= #columns then
            align = 1
        end

        if columns[i] ~= "blank" then
            local label = vgui.Create("DLabel", data)
            label:SetText(columnFunctions[i](ply))
            label:SetFont(THEME.Font.Coolvetica20)
            label:SetColor(color_white)
            label:SetExpensiveShadow(1)
            label:SizeToContents()
            label:SetPos(k * ((data:GetWide() - 8) / (#columns - 1)) - label:GetWide() * align, 0)
            label:CenterVertical()
        end
    end

    local but = vgui.Create("DButton", panel)
    but:SetSize(w, h)
    but:SetText("")

    --options for clicking on a player: Copy steamid, Open profile, mute player
    function but:DoClick()
        local menu = vgui.Create("DMenu")
        menu.ply = self:GetParent().ply

        if not menu.ply:IsBot() then
            local copyID = menu:AddOption("Copy SteamID to clipboard")
            copyID.ply = menu.ply
            copyID:SetIcon("icon16/page_copy.png")

            function copyID:DoClick()
                if not IsValid(self.ply) then return end
                SetClipboardText(self.ply:SteamID())
                DR:ChatMessage(self.ply:Nick() .. "'s SteamID was copied to the clipboard!")
            end

            --http://steamcommunity.com/profiles/
            local openprofile = menu:AddOption("Open Steam profile")
            openprofile.ply = menu.ply
            openprofile:SetIcon("icon16/page_world.png")

            function openprofile:DoClick()
                if not IsValid(self.ply) then return end
                gui.OpenURL("http://steamcommunity.com/profiles/" .. self.ply:SteamID64())
            end

            local mute = menu:AddOption("Toggle voice")
            mute.ply = menu.ply
            mute:SetIcon("icon16/sound.png")

            function mute:DoClick()
                if not IsValid(self.ply) then return end
                RunConsoleCommand("deathrun_toggle_mute", self.ply:SteamID())
                DR:ChatMessage("Toggled mute on " .. self.ply:Nick() .. "!")
            end
        end

        if DR:CanAccessCommand(LocalPlayer(), "deathrun_force_spectate") then
            local specop = menu:AddOption("Force to Spectator") -- spectator options... SPEC OPS!
            specop.ply = menu.ply
            specop:SetIcon("icon16/status_offline.png")

            function specop:DoClick()
                if not IsValid(self.ply) then return end
                net.Start("DeathrunForceSpectator")
                net.WriteString(self.ply:SteamID())
                net.SendToServer()
            end
        end

        menu:Open()
    end

    function but:Paint()
    end

    return panel
end

function DR:DestroyScoreboard()
    DR.ScoreboardIsOpen = false
end

DR:DestroyScoreboard()

function GM:ScoreboardHide()
    DR:DestroyScoreboard()
    DR.ScoreboardCloseTime = CurTime()
end

function GM:ScoreboardShow()
    local should = hook.Call("DeathrunOpenScoreboard", nil) -- return false to suppress scoreboard opening
    if should == false then return end
    DR:CreateScoreboard()
    DR.ScoreboardOpenTime = CurTime()
end

hook.Add("CreateMove", "DeathrunScoreboardPopup", function(cmd)
    if input.WasMousePressed(MOUSE_RIGHT) and DR.ScoreboardIsOpen == true then
        DR.ScoreboardPanel:MakePopup()
    end
end)