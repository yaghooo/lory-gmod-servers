THEME.Component.Toggle = "LoryToggle"
local toggle = {}

function toggle:Init()
    self.state = false
    self.t = 0

    self:SetText("")

    function self:SetText(text)
        self.text = text
    end

    function self:GetText()
        return self.text
    end
end

function toggle:Think()
    if not self.state then
        if self.t > 0 then
            self.t = self.t - FrameTime() * 2
        else
            self.t = 0
        end
    else
        if self.t < 1 then
            self.t = self.t + FrameTime() * 2
        else
            self.t = 1
        end
    end
end

function toggle:Paint(w, h)
    THEME:DrawFullCircle(16, h / 2, 8, THEME.Color.Primary)
    THEME:DrawFullCircle(16, h / 2, 6, color_white)
    THEME:DrawFullCircle(16, h / 2, 4 * (1 - (self.state and QuadLerp(self.t, 1, 0) or QuadLerp(1 - self.t, 0, 1))), THEME.Color.Primary)
    THEME:DrawShadowText(self:GetText(), self:GetFont(), 8 + 16 + 8, h / 2, THEME.Color.Primary, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1)
end

function toggle:Toggle()
    self.state = not self.state

    if self.convar then
        RunConsoleCommand(self.convar:GetName(), tostring(self.state == true and 1 or 0))
    end

    if self.DoToggle then
        self:DoToggle(not self.state, self.state)
    end
end

function toggle:SetConVar(s)
    self.convar = GetConVar(s)
    self.state = self.convar:GetBool()
end

function toggle:SetValue(b)
    self.state = b
end

function toggle:SizeToContents()
    surface.SetFont(self:GetFont())
    local tw, th = 0, 0
    local fw, _ = surface.GetTextSize(self:GetText())
    tw = 16 + 8 + 8 + fw + 8
    th = self:GetTall()
    self:SetSize(tw, th)
end

vgui.Register(THEME.Component.Toggle, toggle, "DButton")