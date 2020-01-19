THEME.Component.Page = "LoryPage"

local page = {}
page.OutLineSize = 3
page.ContainerPadding = 20

function page:Init()
    gui.EnableScreenClicker(true)
    self.StartTime = SysTime()
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
    gui.EnableScreenClicker(false)
    self:Remove()
end

function page:Paint(w, h)
    Derma_DrawBackgroundBlur(self, self.StartTime)
    surface.SetDrawColor(THEME.Color.Primary)
    surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(THEME.Color.Secondary)
    surface.DrawRect(self.OutLineSize, self.OutLineSize, w - self.OutLineSize * 2, h - self.OutLineSize * 2)
end

vgui.Register(THEME.Component.Page, page)