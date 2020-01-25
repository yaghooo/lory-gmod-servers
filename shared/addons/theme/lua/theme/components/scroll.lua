THEME.Component.Scroll = "LoryScroll"

local scroll = {}

function scroll:Init()
    self.VBar.Paint = function(s, w, h)
        draw.RoundedBox(4, 3, 13, 8, h - 24, ColorAlpha(color_black, 100))
    end

    self.VBar.btnUp.Paint = function(s, w, h) end
    self.VBar.btnDown.Paint = function(s, w, h) end

    self.VBar.btnGrip.Paint = function(s, w, h)
        draw.RoundedBox(4, 5, 0, 4, h + 22, THEME.Color.Primary)
    end
end

vgui.Register(THEME.Component.Scroll, scroll, "DScrollPanel")