function THEME:DrawFullCircle(x, y, r, color)
    local segments = 45
    local poly = {}

    for i = 1, segments do
        local temp = {}
        temp["x"] = math.cos((math.ceil(i * (360 / segments))) * (math.pi / 180)) * r + x
        temp["y"] = math.sin((math.ceil(i * (360 / segments))) * (math.pi / 180)) * r + y
        table.insert(poly, temp)
    end

    draw.NoTexture()
    surface.SetDrawColor(color)
    surface.DrawPoly(poly)
end

function THEME:DrawShadowText(text, font, x, y, col, alignX, alignY, distance)
    distance = distance or 1

    if distance ~= 0 and distance ~= nil then
        draw.SimpleText(text, font, x + distance * 2, y + distance * 2, ColorAlpha(color_black, col.a / 4), alignX, alignY)
        draw.SimpleText(text, font, x + distance, y + distance, ColorAlpha(color_black, col.a / 2), alignX, alignY)
    end

    draw.SimpleText(text, font, x, y, col, alignX, alignY)
end