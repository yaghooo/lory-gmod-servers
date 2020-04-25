DR.MapRecordsDrawPos = Vector(0, 0, 0)
DR.MapRecordsCache = {}
DR.MapPBCache = 0

net.Receive("deathrun_send_map_records", function()
    DR.MapRecordsDrawPos = net.ReadVector()
    DR.MapRecordsCache = util.JSONToTable(net.ReadString())
end)

net.Receive("deathrun_send_map_pb", function()
    DR.MapPBCache = net.ReadFloat()
end)

hook.Add("PostDrawTranslucentRenderables", "statsdisplay", function()
    if DR.MapRecordsDrawPos ~= Vector(0, 0, 0) and DR.MapRecordsDrawPos ~= nil then
        local dist = LocalPlayer():GetPos():Distance(DR.MapRecordsDrawPos)

        if dist < 1000 then
            local recordsAng = LocalPlayer():EyeAngles()
            recordsAng:RotateAroundAxis(LocalPlayer():EyeAngles():Right(), 90)
            recordsAng:RotateAroundAxis(LocalPlayer():EyeAngles():Forward(), 90)
            recordsAng.roll = 90
            cam.Start3D2D(DR.MapRecordsDrawPos, recordsAng, 0.10)
            rectY = not rectY and -400 or plus and rectY + 1 or rectY - 1

            if rectY == -400 then
                plus = true
            elseif rectY == -200 then
                plus = false
            end

            surface.SetDrawColor(THEME.Color.Primary)
            surface.DrawRect(-700, rectY, 1400, 80)
            THEME:DrawShadowText("TOP 3 RECORDES", THEME.Font.Coolvetica60, 0, rectY, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2)

            if DR.MapRecordsCache[1] ~= nil and #DR.MapRecordsCache >= 3 then
                for i = 1, 5 do
                    local k = i - 1

                    if i <= 3 then
                        local v = DR.MapRecordsCache[i]
                        THEME:DrawShadowText(tostring(i) .. ". " .. string.sub(v["nickname"] or "", 1, 24), THEME.Font.Coolvetica60, -700, rectY / 2 + 100 * k, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2)
                        THEME:DrawShadowText(v["value"] or "0", THEME.Font.Coolvetica60, 700, rectY / 2 + 100 * k, THEME.Color.Primary, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 2)
                        surface.SetDrawColor(THEME.Color.Primary)
                        surface.DrawRect(-700, rectY / 2 + 100 * k + 80, 1400, 2)
                    elseif i == 5 and DR.MapPBCache ~= 0 then
                        THEME:DrawShadowText("SEU RECORDE", THEME.Font.Coolvetica60, -700, rectY / 2 + 100 * k, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2)
                        THEME:DrawShadowText(string.ToMinutesSecondsMilliseconds(DR.MapPBCache or 0), THEME.Font.Coolvetica60, 700, rectY / 2 + 100 * k, THEME.Color.Primary, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 2)
                        surface.SetDrawColor(THEME.Color.Primary)
                        surface.DrawRect(-700, rectY / 2 + 100 * k + 80, 1400, 2)
                    end
                end
            else
                THEME:DrawShadowText("Sem recordes ainda!", THEME.Font.Coolvetica60, 0, rectY + 100, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2)
            end

            cam.End3D2D()
        end
    end
end)