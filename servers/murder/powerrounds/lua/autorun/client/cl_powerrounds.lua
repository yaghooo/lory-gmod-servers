if not PowerRounds then
    PowerRounds = {}
end

local DrawingInfo = false
local DescriptionLower = 0
PowerRounds.CurrentPR = false
PowerRounds.CurrentDescription = ""
PowerRounds.CurrentName = ""
PowerRounds.RoundsLeft = 0

local function CharWrap(Text, CurLine, Width)
    Text = Text:gsub(".", function(Char)
        local CharLen = surface.GetTextSize(Char)
        CurLine = CurLine + CharLen

        if CurLine >= Width then
            CurLine = CharLen

            return "\n" .. Char
        end

        return Char
    end)

    return Text, CurLine
end

local function CutText(Text, Length, Font)
    local function Wrap(DFont)
        surface.SetFont(DFont)
        local CurLine = 0

        local SText = Text:gsub("(%s?[%S]+)", function(Word)
            local Char = string.sub(Word, 1, 1)

            if Char == "\n" then
                CurLine = 0
            end

            local WordLen = surface.GetTextSize(Word)

            if CurLine + WordLen >= Length then
                local Prefix = ""

                if (CurLine + WordLen < Length * 1.25 and WordLen < Length) or CurLine > Length * 0.65 then
                    CurLine = 0
                    Prefix = "\n"
                    Word = string.gsub(Word, " ", "")
                end

                local SplitWord, NewCurLine = CharWrap(Word, CurLine, Length)
                CurLine = NewCurLine

                return Prefix .. SplitWord
            elseif CurLine + WordLen < Length then
                CurLine = CurLine + WordLen

                return Word
            end
        end)

        return SText
    end

    return Wrap(Font)
end

net.Receive("PowerRoundsRoundStart", function()
    PowerRounds.CurrentPR = PowerRounds.Rounds[PowerRounds.CurrentGM][net.ReadUInt(7)]
    local Late = net.ReadBool()
    if Late then return end
    PowerRounds.CurrentName = PowerRounds.CurrentPR.Name
    PowerRounds.CurrentDescription = CutText(PowerRounds.CurrentPR.Description, PowerRounds.MaxInfoWidth, "PowerRoundsDescriptionFont")
    DescriptionLower = draw.GetFontHeight("PowerRoundsNameFont")

    if isfunction(PowerRounds.CurrentPR.ClientStart) then
        PowerRounds.CurrentPR.ClientStart()
    end

    for n, j in pairs(PowerRounds.CurrentPR) do
        if string.StartWith(n, "CHOOK_") then
            HookName = string.TrimLeft(n, "CHOOK_")
            hook.Add(HookName, HookName .. "_PowerRoundHook", j)
        elseif string.StartWith(n, "CTIMER_") then
            for Time, Repeat, Name in string.gmatch(n, "_(%d+%.?%d*)_?(%d*)_(.+)") do
                Time = tonumber(Time)
                Repeat = tonumber(Repeat) or 0

                if Time > 0 then
                    timer.Create("PowerRoundsTimer_" .. Name, Time, Repeat, j)
                end

                break
            end
        end
    end

    DrawingInfo = true

    timer.Simple(PowerRounds.InfoShowTime, function()
        DrawingInfo = false
    end)
end)

net.Receive("PowerRoundsRoundEnd", function()
    if isfunction(PowerRounds.CurrentPR.ClientEnd) then
        PowerRounds.CurrentPR.ClientEnd()
    end

    for n, j in pairs(PowerRounds.CurrentPR) do
        if string.StartWith(n, "CHOOK_") then
            HookName = string.TrimLeft(n, "CHOOK_")
            hook.Remove(HookName, HookName .. "_PowerRoundHook")
        elseif string.StartWith(n, "CTIMER_") then
            for Name in string.gmatch(n, "_%d+%.?%d*_(.+)") do
                timer.Remove("PowerRoundsTimer_" .. Name)
                break
            end
        end
    end

    DrawingInfo = false
    PowerRounds.CurrentPR = false
    PowerRounds.CurrentName = ""
    PowerRounds.CurrentDescription = ""
end)

net.Receive("PowerRoundsRoundsLeft", function()
    PowerRounds.RoundsLeft = net.ReadUInt(7) - 1
end)

hook.Add("HUDPaint", "PowerRoundsHUDPaint", function()
    if DrawingInfo then
        draw.DrawText(PowerRounds.CurrentName, "PowerRoundsNameFont", PowerRounds.InfoPos.W, PowerRounds.InfoPos.H, Color(191, 12, 12), TEXT_ALIGN_CENTER)
        draw.DrawText(PowerRounds.CurrentDescription, "PowerRoundsDescriptionFont", PowerRounds.InfoPos.W, PowerRounds.InfoPos.H + DescriptionLower, Color(191, 12, 12) or Color(255, 255, 255), TEXT_ALIGN_CENTER)
    end

    if PowerRounds.CurrentPR and isfunction(PowerRounds.CurrentPR.HUDPaint) then
        PowerRounds.CurrentPR.HUDPaint()
    end

    if PowerRounds.ShowUntilNext and (not GAMEMODE or GAMEMODE.RoundStage == 1) then
        local DrawText = ""
        local color = PowerRounds.NextClr

        if PowerRounds.RoundsLeft == 0 then
            DrawText = PowerRounds.CurrentPR.Name or PowerRounds.NextTextCurrent
            color = Color(255, 0, 0)
        elseif PowerRounds.RoundsLeft == 1 then
            DrawText = string.gsub(PowerRounds.NextTextOne, "{Num}", PowerRounds.RoundsLeft)
        elseif PowerRounds.RoundsLeft == -1 then
            DrawText = PowerRounds.CurrentPR.Name or PowerRounds.NextTextForced
            color = Color(255, 0, 0)
        else
            DrawText = string.gsub(PowerRounds.NextTextMultiple, "{Num}", PowerRounds.RoundsLeft)
        end

        local shadowColor = color_black
        shadowColor.a = color.a
        draw.SimpleText(DrawText, "PowerRoundsNextFont", PowerRounds.NextPos.W + 1, PowerRounds.NextPos.H + 1, shadowColor, PowerRounds.NextPos.TextAllignW, PowerRounds.NextPos.TextAllignH)
        draw.SimpleText(DrawText, "PowerRoundsNextFont", PowerRounds.NextPos.W, PowerRounds.NextPos.H, color, PowerRounds.NextPos.TextAllignW, PowerRounds.NextPos.TextAllignH)
    end
end)

function ForcePRRound(ID)
    net.Start("PowerRoundsForcePR")
    net.WriteUInt(ID, 7)
    net.SendToServer()
end

PRMenu = PowerRounds.Menu

function PowerRounds.OpenMenu()
    local ForceAccess = PowerRounds.Access(LocalPlayer(), "PowerRounds_Force")

    if not ForceAccess then
        PowerRounds.Chat(nil, PowerRounds.NoAccessChatColor or Color(255, 0, 0), PowerRounds.NoAccessChatText or "Text not set in config!")

        return
    end

    PRMenu.Frame = vgui.Create("DFrame")
    PRMenu.Frame:SetSize(520, 320)
    PRMenu.Frame:SetPos(ScrW() / 2 - 260, ScrH() / 2 - 16)
    PRMenu.Frame:SetTitle("")
    PRMenu.Frame:MakePopup()
    PRMenu.Frame:ShowCloseButton(false)
    PRMenu.Frame.Paint = function() end
    PRMenu.MainPanel = vgui.Create("DPanel", PRMenu.Frame)
    PRMenu.MainPanel:SetPos(0, 0)
    PRMenu.MainPanel:SetPaintBackground(false)
    PRMenu.MainPanel:SetSize(PRMenu.Frame:GetSize())
    PRMenu.MainPanel:SetBackgroundColor(Color(120, 120, 120, 0))

    PRMenu.MainPanel.Paint = function(self)
        surface.SetDrawColor(PRMenu.BGColor)
        self:DrawFilledRect()
        draw.SimpleText("Power Rounds", "PowerRoundsMenu30", 10, 23, PowerRounds.Menu.TitleColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    PRMenu.CloseBtn = vgui.Create("DButton", PRMenu.MainPanel)
    PRMenu.CloseBtn:SetPos(PRMenu.MainPanel:GetWide() - 67, 6)
    PRMenu.CloseBtn:SetSize(60, 30)
    PRMenu.CloseBtn:SetText("")

    PRMenu.CloseBtn.Paint = function(self)
        surface.SetDrawColor(PRMenu.CloseBtnBorderColor)
        surface.DrawRect(0, 0, self:GetSize())
        surface.SetDrawColor(PRMenu.CloseBtnColor)
        surface.DrawRect(1, 1, self:GetWide() - 2, self:GetTall() - 2)
        draw.SimpleText("Close", "PowerRoundsMenu22", self:GetWide() / 2, self:GetTall() / 2, PowerRounds.Menu.CloseBtnTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    PRMenu.CloseBtn.DoClick = function()
        PRMenu.Frame:Close()
    end

    PRMenu.ForcePanel = vgui.Create("DPanel", PRMenu.MainPanel)
    PRMenu.ForcePanel:SetPos(6, 42)
    PRMenu.ForcePanel:SetPaintBackground(false)
    PRMenu.ForcePanel:SetSize(PRMenu.MainPanel:GetWide() - 12, PRMenu.MainPanel:GetTall() - 48)
    PRMenu.ForcePanel:SetBackgroundColor(Color(120, 120, 120, 0))

    PRMenu.ForcePanel.Paint = function(self)
        surface.SetDrawColor(PRMenu.FGColor)
        self:DrawFilledRect()
    end

    PRMenu.RoundList = vgui.Create("DListView", PRMenu.ForcePanel)
    PRMenu.RoundList:SetPos(6, 6)
    PRMenu.RoundList:SetSize(PRMenu.ForcePanel:GetWide() - 12, PRMenu.ForcePanel:GetTall() - 48)
    PRMenu.RoundList:SetMultiSelect(false)
    PRMenu.RoundList:AddColumn("Name"):SetWidth(PRMenu.RoundList:GetWide() * 0.3)
    PRMenu.RoundList:AddColumn("Description"):SetWidth(PRMenu.RoundList:GetWide() * 0.7)

    if PowerRounds.Rounds[PowerRounds.CurrentGM] and table.Count(PowerRounds.Rounds[PowerRounds.CurrentGM]) > 0 then
        for _, j in pairs(PowerRounds.Rounds[PowerRounds.CurrentGM]) do
            local Line = PRMenu.RoundList:AddLine(j.Name, j.Description)
            Line.PRID = j.ID
        end
    end

    PRMenu.RoundList:SelectFirstItem()

    if ForceAccess then
        PRMenu.ForceBtn = vgui.Create("DButton", PRMenu.ForcePanel)
        PRMenu.ForceBtn:SetPos(6, PRMenu.ForcePanel:GetTall() - 36)
        PRMenu.ForceBtn:SetSize(PRMenu.ForcePanel:GetWide() - 12, 30)
        PRMenu.ForceBtn:SetText("")

        PRMenu.ForceBtn.Paint = function(self)
            surface.SetDrawColor(PRMenu.ForceBtnBorderColor)
            surface.DrawRect(0, 0, self:GetSize())
            surface.SetDrawColor(PRMenu.ForceBtnColor)
            surface.DrawRect(1, 1, self:GetWide() - 2, self:GetTall() - 2)
            draw.SimpleText("Force selected PR", "PowerRoundsMenu22", self:GetWide() / 2, self:GetTall() / 2, PowerRounds.Menu.ForceeBtnTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        PRMenu.ForceBtn.DoClick = function()
            local SelectedLine = PRMenu.RoundList:GetLine(PRMenu.RoundList:GetSelectedLine())
            ForcePRRound(SelectedLine.PRID)
            PRMenu.Frame:Close()
        end
    end
end

concommand.Add("PowerRounds", PowerRounds.OpenMenu)