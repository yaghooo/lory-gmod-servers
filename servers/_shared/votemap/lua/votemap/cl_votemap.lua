-- shit code alert, pls refact
net.Receive("MAPVOTE_OpenNominationSelector", function()
    local maps = net.ReadTable()
    local page = vgui.Create(THEME.Component.Page)
    page:SetSize(480, math.min(ScrH() - 64, 480 * 1.618 - 44)) -- GOLDEN RATIO FIBONACCI SPIRAL OMG
    page:Center()
    page:MakePopup()
    local panel = vgui.Create("DPanel", page)
    panel:SetPos(4, 32)
    panel:SetSize(page:GetWide() - 4, page:GetTall() - 44)

    function panel:Paint(w, h)
    end

    local scr = vgui.Create(THEME.Component.Scroll, panel)
    scr:SetSize(panel:GetWide() - 8, panel:GetTall())
    scr:SetPos(4, 0)
    local dlist = vgui.Create("DIconLayout", scr)
    dlist:SetSize(panel:GetWide(), 1500)
    dlist:SetPos(0, 0)
    dlist:SetSpaceX(0)
    dlist:SetSpaceY(4)
    local label = dlist:Add("DLabel")
    label:SetFont(THEME.Font.Coolvetica30)
    label:SetText("Mapas")
    label:SetColor(color_white)
    label:SizeToContents()
    label:SetWide(dlist:GetWide())

    for k, config in ipairs(maps) do
        local btn = vgui.Create(THEME.Component.Button1, panel)
        btn:SetBackgroundColor(Color(70, 70, 70))
        btn:SetSize(dlist:GetWide() - 8, 20)
        btn:SetPos(0, 0)
        btn:SetFont("DermaDefault")

        if config.error then
            btn:SetText(config.map .. "  (" .. config.error .. ")")
        else
            btn:SetText(config.map)
        end

        btn:SetDisabled(config.error ~= nil)

        function btn:DoClick()
            surface.PlaySound("ui/buttonclickrelease.wav")
            net.Start("MAPVOTE_NominateMap")
            net.WriteString(config.map)
            net.SendToServer()
            page:Close()
        end

        dlist:Add(btn)
    end
end)

net.Receive("MAPVOTE_StartVotemap", function()
    local mappool = net.ReadTable()
    local time = net.ReadInt(16)
    local endTime = CurTime() + time
    surface.PlaySound("common/warning.wav")
    local frame = vgui.Create("EditablePanel")
    frame:SetSize(245 * 1.618 + 4, (#mappool * 24) + (#mappool - 1) * 4 + 44) -- GOLDEN RATIO FIBONACCI SPIRAL OMG
    local y = ScrH() / 2 - frame:GetTall() / 2
    frame:SetPos(-frame:GetWide(), y)
    frame:MoveTo(4, y, 0.2, 0, -1)

    function frame:Paint(w, h)
        surface.SetDrawColor(THEME.Color.Primary)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(THEME.Color.Secondary)
        surface.DrawRect(0, 25, w, h - 25)
        surface.SetFont(THEME.Font.Roboto18)
        surface.SetTextColor(color_white)
        surface.SetTextPos(10, 3)
        surface.DrawText("Votação de mapa - " .. string.ToMinutesSeconds(endTime - CurTime()))
    end

    local panel = vgui.Create("DPanel", frame)
    panel:SetPos(4, 32)
    panel:SetSize(frame:GetWide() - 8, frame:GetTall() - 44)

    function panel:Paint(w, h)
    end

    local dlist = vgui.Create("DIconLayout", panel)
    dlist:SetSize(panel:GetWide(), 1500)
    dlist:SetPos(0, 0)
    dlist:SetSpaceX(0)
    dlist:SetSpaceY(4)

    for k, v in ipairs(mappool) do
        local label = dlist:Add("DLabel")
        label:SetFont(THEME.Font.Roboto18)
        label:SetText(k .. " - " .. v)
        label:SizeToContents()
        label:SetWide(dlist:GetWide())
        label:SetTall(label:GetTall() + 6)

        function label:Think()
            if VOTEMAP.ChosenMap == k then
                label:SetColor(THEME.Color.Primary)
            else
                label:SetColor(color_white)
            end
        end
    end

    hook.Add("SetupMove", "MapvoteReceiveKeys", function()
        if not vgui.CursorVisible() then
            local keynums = {KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9}

            for i = 1, #keynums do
                if input.WasKeyPressed(keynums[i]) and mappool[i] and VOTEMAP.ChosenMap ~= i then
                    surface.PlaySound("ui/buttonclick.wav")
                    VOTEMAP.ChosenMap = i
                    net.Start("MAPVOTE_MapVote")
                    net.WriteInt(i, 16)
                    net.SendToServer()
                end
            end
        end
    end)

    timer.Simple(time, function()
        frame:MoveTo(-frame:GetWide(), y, 0.2, 0, -1, function()
            if IsValid(frame) then
                frame:Remove()
            end
        end)

        hook.Remove("SetupMove", "MapvoteReceiveKeys")
        surface.PlaySound("ui/achievement_earned.wav")
    end)
end)