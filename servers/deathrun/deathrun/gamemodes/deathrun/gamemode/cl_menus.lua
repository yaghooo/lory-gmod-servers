DR.DeathrunSettings = {{"header", "Configurações de HUD"}, {"number", "deathrun_hud_position", 0, 8, "Posição da HUD (HP, Velocidade, Tempo)"}, {"number", "deathrun_hud_ammo_position", 0, 8, "Posição da HUD de munição"}, {"header", "Configurações de 3ª pessoa"}, {"boolean", "deathrun_thirdperson_enabled", "Modo terceira pessoa"}, {"number", "deathrun_thirdperson_opacity", 5, 255, "Transparencia do personagem"}, {"number", "deathrun_thirdperson_offset_x", -40, 40, "Posição horintal"}, {"number", "deathrun_thirdperson_offset_y", -40, 40, "Posição vertical"}, {"number", "deathrun_thirdperson_offset_z", -75, 75, "Distancia"}, {"number", "deathrun_thirdperson_offset_pitch", -75, 75, "Posição horizontal da camêra"}, {"number", "deathrun_thirdperson_offset_yaw", -75, 75, "Posição vertical da camêra"}, {"number", "deathrun_thirdperson_offset_roll", -75, 75, "Rotação da camêra"}, {"header", "Outras configurações"}, {"number", "deathrun_teammate_fade_distance", 0, 512, "Distancia de fade dos amigos"}}

function DR:OpenSettings()
    local frame = vgui.Create(THEME.Component.Page)
    frame:SetSize(480, 640)
    frame:Center()
    frame:MakePopup()
    local controls = vgui.Create("DPanel", frame)
    controls:SetSize(frame:GetWide() - 8, frame:GetTall() - 44)
    controls:SetPos(4, 32)
    controls.Paint = function() end
    local scr = vgui.Create(THEME.Component.Scroll, controls)
    scr:SetSize(controls:GetWide() - 16, controls:GetTall() - 16)
    scr:SetPos(8, 8)
    local dlist = vgui.Create("DIconLayout", scr)
    dlist:SetSize(scr:GetSize())
    dlist:SetPos(0, 0)
    dlist:SetSpaceX(0)
    dlist:SetSpaceY(8)

    for k, v in pairs(DR.DeathrunSettings) do
        local ty = v[1] -- convar type

        if ty == "header" then
            local pnl = vgui.Create("DPanel") -- spacer
            pnl:SetWide(dlist:GetWide())
            pnl:SetTall(24)

            function pnl:Paint()
            end

            dlist:Add(pnl)
            local lbl = vgui.Create("DLabel")
            lbl:SetFont(THEME.Font.Coolvetica24)
            lbl:SetTextColor(THEME.Color.Primary)
            lbl:SetText(v[2])
            lbl:SizeToContents()
            lbl:SetWide(dlist:GetWide())
            dlist:Add(lbl)
        elseif ty == "boolean" then
            local pnl = vgui.Create("DPanel") -- spacer
            pnl:SetWide(dlist:GetWide())
            pnl:SetTall(4)

            function pnl:Paint()
            end

            dlist:Add(pnl)
            local lbl = vgui.Create("DLabel") -- label
            lbl:SetFont(THEME.Font.Coolvetica20)
            lbl:SetTextColor(color_white)
            lbl:SetText(v[3])
            lbl:SizeToContents()
            lbl:SetWide(dlist:GetWide())
            dlist:Add(lbl)
            local check = vgui.Create(THEME.Component.Toggle)
            check:SetText("Enabled")
            check:SetTextColor(color_white)
            check:SizeToContents()
            check:SetConVar(v[2])
            dlist:Add(check)
        elseif ty == "number" then
            local pnl = vgui.Create("DPanel") -- spacer
            pnl:SetWide(dlist:GetWide())
            pnl:SetTall(4)

            function pnl:Paint()
            end

            dlist:Add(pnl)
            local lbl = vgui.Create("DLabel") -- label
            lbl:SetFont(THEME.Font.Coolvetica20)
            lbl:SetTextColor(color_white)
            lbl:SetText(v[5])
            lbl:SizeToContents()
            lbl:SetWide(dlist:GetWide())
            dlist:Add(lbl)
            -- slider
            local sl = vgui.Create("Slider")
            sl:SetMin(v[3])
            sl:SetMax(v[4])
            sl:SetWide(dlist:GetWide())
            sl:SetTall(12)
            sl:SetValue(GetConVar(v[2]):GetFloat())
            sl.convarname = v[2]

            function sl:OnValueChanged()
                RunConsoleCommand(self.convarname, self:GetValue())
            end

            dlist:Add(sl)
        end
    end

    local pnl = vgui.Create("DPanel") -- spacer
    pnl:SetWide(dlist:GetWide())
    pnl:SetTall(24)

    function pnl:Paint()
    end

    dlist:Add(pnl)
end

concommand.Add("deathrun_open_settings", function()
    DR:OpenSettings()
end)

function DR:OpenZoneEditor()
    local frame = vgui.Create(THEME.Component.Page)
    frame:SetSize(320, 480)
    frame:Center()
    frame:MakePopup()
    local panel = vgui.Create("DPanel", frame)
    panel:SetSize(frame:GetWide() - 8, frame:GetTall() - 44)
    panel:SetPos(4, 32)
    panel.Paint = function() end
    local scr = vgui.Create(THEME.Component.Scroll, panel)
    scr:SetSize(panel:GetWide() - 12, panel:GetTall() - 16)
    scr:SetPos(8, 8)

    local dlist = vgui.Create("DIconLayout", scr)
    dlist:SetSize(scr:GetWide() - 6, scr:GetTall())
    dlist:SetPos(0, 0)
    dlist:SetSpaceX(4)
    dlist:SetSpaceY(8)
    local lbl = vgui.Create("DLabel")
    lbl:SetFont(THEME.Font.Coolvetica24)
    lbl:SetTextColor(THEME.Color.Primary)
    lbl:SetText("Create Zone")
    lbl:SizeToContents()
    lbl:SetWide(dlist:GetWide())
    dlist:Add(lbl)
    lbl = vgui.Create("DLabel")
    lbl:SetFont(THEME.Font.Coolvetica20)
    lbl:SetTextColor(color_white)
    lbl:SetText("Zone Name:")
    lbl:SizeToContents()
    lbl:SetWide(dlist:GetWide() / 2 - 2)
    dlist:Add(lbl)
    local te = vgui.Create("DTextEntry")
    te:SetSize(dlist:GetWide() / 2 - 2, 18)
    te:SetText("new_zone")
    dlist:Add(te)
    lbl = vgui.Create("DLabel")
    lbl:SetFont(THEME.Font.Coolvetica20)
    lbl:SetTextColor(color_white)
    lbl:SetText("Zone Type:")
    lbl:SizeToContents()
    lbl:SetWide(dlist:GetWide() / 2 - 2)
    dlist:Add(lbl)
    local dd = vgui.Create("DComboBox")
    dd:SetSize(dlist:GetWide() / 2 - 2, 18)
    dd:SetValue("end")

    for i = 1, #ZONE.ZoneTypes do
        dd:AddChoice(ZONE.ZoneTypes[i])
    end

    dlist:Add(dd)
    local sbmt = vgui.Create(THEME.Component.Button1)
    sbmt:SetSize(dlist:GetWide(), 18)
    sbmt:SetText("Create Zone")
    sbmt:SetFont(THEME.Font.Coolvetica20)
    dlist:Add(sbmt)
    sbmt.te = te
    te.sbmt = sbmt
    sbmt.dd = dd

    function te:OnTextChanged()
        self.sbmt:SetText("Create Zone '" .. self:GetText() .. "'")
    end

    function sbmt:DoClick()
        LocalPlayer():ConCommand("zone_create " .. self.te:GetText() .. " " .. self.dd:GetValue() .. " ")
    end

    --edit zones
    lbl = vgui.Create("DLabel")
    lbl:SetFont(THEME.Font.Coolvetica24)
    lbl:SetTextColor(THEME.Color.Primary)
    lbl:SetText("Modify Zone")
    lbl:SizeToContents()
    lbl:SetWide(dlist:GetWide())
    dlist:Add(lbl)
    dd = vgui.Create("DComboBox")
    dd:SetSize(dlist:GetWide(), 18)
    dd:SetValue(LocalPlayer().LastSelectZone or "Select Zone")

    for name, z in pairs(ZONE.zones) do
        if z.type then
            dd:AddChoice(name)
        end
    end

    function dd:OnSelect(index, value)
        LocalPlayer().LastSelectZone = value
    end

    dlist:Add(dd)
    local pnl = vgui.Create("DPanel")
    pnl:SetSize(dlist:GetWide(), 85)
    dlist:Add(pnl)
    pnl.dd = dd

    function pnl:Paint(w, h)
        local zone = ZONE.zones[self.dd:GetValue()] or nil

        if zone ~= nil and zone.type then
            local col = zone.color
            local info = {"Zone Name: " .. self.dd:GetValue(), "Zone Type: " .. zone.type, "Pos1: " .. tostring(zone.pos1), "Pos2: " .. tostring(zone.pos2), "Color:" .. " " .. tostring(col.r) .. " " .. tostring(col.g) .. " " .. tostring(col.b) .. " " .. tostring(col.a)}

            for i = 1, #info do
                local k = i - 1
                draw.SimpleText(info[i], THEME.Font.Coolvetica20, 0, 14 * k, color_white)
            end
        end
    end

    -- ripped from wiki lmao
    local Mixer = vgui.Create("DColorMixer")
    Mixer:SetSize(dlist:GetWide(), 196)
    Mixer:SetPalette(true) --Show/hide the palette			DEF:true
    Mixer:SetAlphaBar(true) --Show/hide the alpha bar		DEF:true
    Mixer:SetWangs(true) --Show/hide the R G B A indicators 	DEF:true
    Mixer:SetColor(Color(255, 255, 255)) --Set the default color
    Mixer.dd = dd
    dlist:Add(Mixer)
    local but = vgui.Create(THEME.Component.Button1)
    but:SetSize(dlist:GetWide(), 18)
    but:SetText("Set zone color")
    but:SetFont(THEME.Font.Coolvetica20)
    but.dd = dd
    but.mixer = Mixer
    dlist:Add(but)

    function but:DoClick()
        local col = self.mixer:GetColor()
        LocalPlayer():ConCommand("zone_setcolor " .. self.dd:GetValue() .. " " .. tostring(col.r) .. " " .. tostring(col.g) .. " " .. tostring(col.b) .. " " .. tostring(col.a))
    end

    but = vgui.Create(THEME.Component.Button1)
    but:SetSize(dlist:GetWide(), 18)
    but:SetText("Set Pos1 to eyetrace")
    but:SetFont(THEME.Font.Coolvetica20)
    but.dd = dd
    dlist:Add(but)

    function but:DoClick()
        LocalPlayer():ConCommand("zone_setpos1 " .. self.dd:GetValue() .. " eyetrace")
    end

    but = vgui.Create(THEME.Component.Button1)
    but:SetSize(dlist:GetWide(), 18)
    but:SetText("Set Pos2 to eyetrace")
    but:SetFont(THEME.Font.Coolvetica20)
    but.dd = dd
    dlist:Add(but)

    function but:DoClick()
        LocalPlayer():ConCommand("zone_setpos2 " .. self.dd:GetValue() .. " eyetrace")
    end

    but = vgui.Create(THEME.Component.Button1)
    but:SetSize(dlist:GetWide(), 18)
    but:SetText("Remove this zone")
    but:SetFont(THEME.Font.Coolvetica20)
    but.dd = dd
    dlist:Add(but)

    function but:DoClick()
        LocalPlayer():ConCommand("zone_remove " .. self.dd:GetValue())
    end
end

concommand.Add("deathrun_open_zone_editor", function(ply, cmd)
    if DR:CanAccessCommand(ply, cmd) then
        DR:OpenZoneEditor()
    end
end)