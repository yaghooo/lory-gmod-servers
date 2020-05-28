hook.Add("PlayerSay", "CrosshairMenu", function(ply, text)
    text = string.lower(text)

    if text == "!cross" or text == "!crosshair" then
        ply:ConCommand("open_crosshair_menu")
    end
end)