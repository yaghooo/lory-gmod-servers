local menu

function GM:DisplayEndRoundBoard(data)
    if IsValid(menu) then
        menu:Remove()
    end

    menu = vgui.Create("DFrame")
    menu:SetSize(ScrW() * 0.8, ScrH() * 0.8)
    menu:Center()
    menu:SetTitle("")
    menu:MakePopup()
    menu:SetKeyboardInputEnabled(false)
    menu:SetDeleteOnClose(false)
    menu.backgroundColor = Color(40, 40, 40, 255)

    function menu:Paint()
        surface.SetDrawColor(self.backgroundColor)
        surface.DrawRect(0, 0, menu:GetWide(), menu:GetTall())
    end

    local winnerPnl = vgui.Create("DPanel", menu)
    winnerPnl:DockPadding(24, 24, 24, 24)
    winnerPnl:Dock(TOP)
    winnerPnl.backgroundColor = Color(50, 50, 50, 255)

    function winnerPnl:PerformLayout()
        self:SizeToChildren(false, true)
    end

    function winnerPnl:Paint(w, h)
        surface.SetDrawColor(self.backgroundColor)
        surface.DrawRect(2, 2, w - 4, h - 4)
    end

    local winner = vgui.Create("DLabel", winnerPnl)
    winner:Dock(TOP)
    winner:SetFont("MersRadialBig")
    winner:SetAutoStretchVertical(true)

    if data.reason == 3 then
        winner:SetText(translate.endroundMurdererQuit)
        winner:SetTextColor(color_white)
    elseif data.reason == 2 then
        winner:SetText(translate.endroundBystandersWin)
        winner:SetTextColor(Color(20, 120, 255))
    elseif data.reason == 1 then
        winner:SetText(translate.endroundMurdererWins)
        winner:SetTextColor(Color(190, 20, 20))
    end

    local murdererPnl = vgui.Create("DPanel", winnerPnl)
    murdererPnl:Dock(TOP)
    murdererPnl:SetTall(draw.GetFontHeight("MersRadialSmall"))

    function murdererPnl:Paint()
    end

    if data.murdererName then
        local msgs = Translator:AdvVarTranslate(translate.endroundMurdererWas, {
            murderer = {
                text = data.murdererName,
                color = data.murdererColor
            }
        })

        for k, msg in pairs(msgs) do
            local was = vgui.Create("DLabel", murdererPnl)
            was:Dock(LEFT)
            was:SetText(msg.text)
            was:SetFont("MersRadialSmall")
            was:SetTextColor(msg.color or color_white)
            was:SetAutoStretchVertical(true)
            was:SizeToContentsX()
        end
    end

    local lootPnl = vgui.Create("DPanel", menu)
    lootPnl:Dock(FILL)
    lootPnl:DockPadding(24, 24, 24, 24)
    lootPnl.backgroundColor = Color(50, 50, 50, 255)

    function lootPnl:Paint(w, h)
        surface.SetDrawColor(self.backgroundColor)
        surface.DrawRect(2, 2, w - 4, h - 4)
    end

    local desc = vgui.Create("DLabel", lootPnl)
    desc:Dock(TOP)
    desc:SetFont("MersRadial")
    desc:SetAutoStretchVertical(true)
    desc:SetText(translate.endroundLootCollected)
    desc:SetTextColor(color_white)
    local lootList = vgui.Create("DPanelList", lootPnl)
    lootList:Dock(FILL)

    for k, v in pairs(data.collectedLoot) do
        if v.playerName then
            local pnl = vgui.Create("DPanel")
            pnl:SetTall(draw.GetFontHeight("MersRadialSmall"))

            function pnl:Paint(w, h)
            end

            function pnl:PerformLayout()
                if self.NamePnl then
                    self.NamePnl:SetWidth(self:GetWide() * 0.5)
                end

                if self.BNamePnl then
                    self.BNamePnl:SetWidth(self:GetWide() * 0.3)
                end

                self:SizeToChildren(false, true)
            end

            local name = vgui.Create("DButton", pnl)
            pnl.NamePnl = name
            name:Dock(LEFT)
            name:SetAutoStretchVertical(true)
            name:SetText(v.playerName)
            name:SetFont("MersRadialSmall")
            name:SetTextColor(v.playerColor)
            name:SetContentAlignment(4)

            function name:Paint()
            end

            function name:DoClick()
                if IsValid(v.player) then
                    GAMEMODE:DoScoreboardActionPopup(v.player)
                end
            end

            local bname = vgui.Create("DButton", pnl)
            pnl.BNamePnl = bname
            bname:Dock(LEFT)
            bname:SetAutoStretchVertical(true)
            bname:SetText(v.playerBystanderName)
            bname:SetFont("MersRadialSmall")
            bname:SetTextColor(v.playerColor)
            bname:SetContentAlignment(4)

            function bname:Paint()
            end

            bname.DoClick = name.DoClick
            lootList:AddItem(pnl)
        end
    end

    local add = vgui.Create("DButton", menu)
    add:Dock(BOTTOM)
    add:SetTall(64)
    add:SetText("")
    local mat = Material("murder/logo.png")
    local add_clean_color = Color(255, 255, 255)
    local add_active_color = Color(180, 180, 180)
    local add_hovered_color = Color(220, 220, 220)

    function add:Paint(w, h)
        surface.SetMaterial(mat)

        if self:IsDown() then
            surface.SetDrawColor(add_active_color)
            surface.SetTextColor(add_active_color)
        elseif self.Hovered then
            surface.SetDrawColor(add_hovered_color)
            surface.SetTextColor(add_hovered_color)
        else
            surface.SetDrawColor(add_clean_color)
            surface.SetTextColor(add_clean_color)
        end

        surface.DrawTexturedRect(10, 0, 64, 64)
        surface.SetFont("MersRadialSmall")
        local tw = surface.GetTextSize(translate.adMelonbomberBy)
        surface.SetTextPos(w - tw - 10, h / 2 - 10)
        surface.DrawText(translate.adMelonbomberBy)
    end

    function add:DoClick()
        gui.OpenURL("https://discord.gg/7FnEfXC")
        surface.PlaySound("UI/buttonclick.wav")
    end
end

net.Receive("reopen_round_board", function()
    if IsValid(menu) then
        menu:SetVisible(true)
    end
end)