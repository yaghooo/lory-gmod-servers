THEME.Component.Page = "LoryPage"
local openedPages = 0
local page = {}
page.OutLineSize = 3
page.ContainerPadding = 20
page.HeaderSize = page.ContainerPadding * 2 + 28 / 2

function page:Init()
    openedPages = openedPages + 1

    gui.EnableScreenClicker(true)

    self._startTime = SysTime()

    -- This turns off the engine drawing
    self:SetPaintBackgroundEnabled(false)
    self:SetPaintBorderEnabled(false)
end

function page:OnSizeChanged(w, h)
    self:SetPos((ScrW() / 2) - (self:GetWide() / 2), (ScrH() / 2) - (self:GetTall() / 2))
    local close = vgui.Create(THEME.Component.Button2, self)
    close:SetSize(100, 34)
    close:SetPos(self:GetWide() - self.ContainerPadding - close:GetWide(), self.OutLineSize or 0)
    close:SetText("Fechar")
    close.Page = self

    function close:DoClick()
        self.Page:Close()
    end
end

function page:Close()
    openedPages = openedPages - 1

    if openedPages == 0 then
        gui.EnableScreenClicker(false)
    end

    if self.OnClose then
        self:OnClose()
    end

    self:Remove()
end

function page:Paint(w, h)
    Derma_DrawBackgroundBlur(self, self._startTime)
    surface.SetDrawColor(THEME.Color.Primary)
    surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(THEME.Color.Secondary)
    surface.DrawRect(self.OutLineSize, self.OutLineSize, w - self.OutLineSize * 2, h - self.OutLineSize * 2)
end

vgui.Register(THEME.Component.Page, page, "EditablePanel")