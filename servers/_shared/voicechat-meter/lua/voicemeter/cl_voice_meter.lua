surface.CreateFont("VoiceFont", {
    font = "Arial",
    size = VoiceChatMeter.FontSize or 17,
    weight = 550,
    shadow = true,
    outline = true
})

local VoiceChat = {}
VoiceChat.Talking = {}

function VoiceChat.StartVoice(ply)
    if not ply:IsValid() or not ply.Team then return end

    for k, v in pairs(VoiceChat.Talking) do
        if v.Owner == ply then
            v:Remove()
            VoiceChat.Talking[k] = nil
            break
        end
    end

    local CurID = 1
    local W, H = VoiceChatMeter.SizeX or 250, VoiceChatMeter.SizeY or 40
    local userColor = team.GetColor(ply:Team())
    local rank = (ply:GetUserGroup() == "user" and ply == LocalPlayer() and "self") or ply:GetUserGroup()

    for _, v in pairs(VoiceChatMeter.MemberColors) do
        local found = table.HasValue(v.Rank, rank)

        if found then
            userColor = v.Color
            break
        end
    end

    -- The name panel itself
    local ToAdd = 0

    if #VoiceChat.Talking ~= 0 then
        for i = 1, #VoiceChat.Talking + 3 do
            if not VoiceChat.Talking[i] or not VoiceChat.Talking[i]:IsValid() then
                ToAdd = -(i - 1) * (H + 4)
                CurID = i
                break
            end
        end
    end

    if not VoiceChatMeter.StackUp then
        ToAdd = -ToAdd
    end

    local NameBar, Fade, Go = vgui.Create("DPanel"), 0, 1
    NameBar:SetSize(W, H)
    local StartPos = (VoiceChatMeter.SlideOut and ((VoiceChatMeter.PosX < .5 and -W) or ScrW())) or (ScrW() * VoiceChatMeter.PosX - (VoiceChatMeter.Align == 1 and 0 or W))
    NameBar:SetPos(StartPos, ScrH() * VoiceChatMeter.PosY + ToAdd)

    if VoiceChatMeter.SlideOut then
        NameBar:MoveTo(ScrW() * VoiceChatMeter.PosX - (VoiceChatMeter.Align == 1 and 0 or W), ScrH() * VoiceChatMeter.PosY + ToAdd, VoiceChatMeter.SlideTime)
    end

    NameBar.Paint = function(s, w, h)
        userColor.a = 180 * Fade
        draw.RoundedBox(VoiceChatMeter.Radius, 0, 0, w, h, userColor)
        draw.RoundedBox(VoiceChatMeter.Radius, 2, 2, w - 4, h - 4, Color(0, 0, 0, 180 * Fade))
    end

    NameBar.Owner = ply
    -- Initialize stuff for this think function
    local NameTxt, Av = vgui.Create("DLabel", NameBar), vgui.Create("AvatarImage", NameBar)

    -- How the voice volume meters work
    function NameBar:Think()
        if not ply:IsValid() then
            NameBar:Remove()
            VoiceChat.Talking[CurID] = nil

            return false
        end

        if not VoiceChat.Talking[CurID] then
            NameBar:Remove()

            return false
        end

        if VoiceChat.Talking[CurID].fade then
            if Go ~= 0 then
                Go = 0
            end

            if Fade <= 0 then
                VoiceChat.Talking[CurID]:Remove()
                VoiceChat.Talking[CurID] = nil
            end
        end

        if Fade < Go and Fade ~= 1 then
            Fade = Fade + VoiceChatMeter.FadeAm
            NameTxt:SetAlpha(Fade * 255)
            Av:SetAlpha(Fade * 255)
        elseif Fade > Go and Go ~= 1 then
            Fade = Fade - VoiceChatMeter.FadeAm
            NameTxt:SetAlpha(Fade * 255)
            Av:SetAlpha(Fade * 255)
        end

        local CurVol = ply:VoiceVolume() * 1.05
        local VolBar, Clr = vgui.Create("DPanel", NameBar), Color(255 * CurVol, 255 * (1 - CurVol), 0, 190)
        VolBar:SetSize(5, (self:GetTall() - 6) * CurVol)
        VolBar:SetPos(self:GetTall() - 6, (self:GetTall() - 6) * (1 - CurVol) + 3)

        function VolBar:Think()
            local X, Y = self:GetPos()

            if X > NameBar:GetWide() + 14 then
                self:Remove()

                return
            end

            self:SetPos(X + 6, Y)
        end

        function VolBar:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(Clr.r, Clr.g, Clr.b, Clr.a * Fade))
        end

        VolBar:MoveToBack()
        VolBar:SetZPos(5)
    end

    -- The player's avatar
    Av:SetPos(4, 4)
    Av:SetSize(NameBar:GetTall() - 8, NameBar:GetTall() - 8)
    Av:SetPlayer(ply)
    local NameStr = ply:Name()
    -- The player's name
    NameTxt:SetPos(NameBar:GetTall() + 4, H * .25)
    NameTxt:SetAlpha(0)
    NameTxt:SetFont("VoiceFont")
    NameTxt:SetText(NameStr)
    NameTxt:SetSize(W - NameBar:GetTall() - 9, 20)
    NameTxt:SetColor(Color(255, 255, 255, 240))
    NameTxt:SetZPos(8)
    NameTxt:MoveToFront()

    NameTxt.Paint = function()
        if ply:IsSuperAdmin() then
            NameTxt:SetColor(HSVToColor(RealTime() % 6 * 60, 1, 1))
        end
    end

    NameBar:MoveToBack()

    -- Hand up-to-face animation
    if VOICE and (not (ply:IsActiveTraitor() and (not ply.traitor_gvoice))) then
        ply:AnimPerformGesture(ACT_GMOD_IN_CHAT)
    end

    VoiceChat.Talking[CurID] = NameBar

    return false
end

hook.Add("PlayerStartVoice", "PlayerStartedVoicing", VoiceChat.StartVoice)

function VoiceChat.EndVoice(ply)
    for k, v in pairs(VoiceChat.Talking) do
        if v.Owner == ply then
            VoiceChat.Talking[k].fade = true
            break
        end
    end
end

hook.Add("PlayerEndVoice", "PlayerEndedVoicing", VoiceChat.EndVoice)

hook.Add("HUDShouldDraw", "RemoveOldVoiceChat", function(elem)
    if elem == "CHudVoiceStatus" or elem == "CHudVoiceSelfStatus" then return false end
end)