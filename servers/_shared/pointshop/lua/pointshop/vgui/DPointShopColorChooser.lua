local COLOR = {}

function COLOR:Init()
    self:SetSize(400, 400)

    self.colorChooser = vgui.Create("DColorMixer", self)
    self.colorChooser:SetSize(self:GetWide() - self.ContainerPadding * 2, self:GetTall() - self.HeaderSize - self.ContainerPadding)
    self.colorChooser:SetPos(self.ContainerPadding, self.HeaderSize)

    self:MakePopup()
end

function COLOR:SetColor(color)
    self.colorChooser:SetColor(color or color_white)
end

function COLOR:OnClose()
    self.OnChoose(self.colorChooser:GetColor())
end

function COLOR:OnChoose()
    --loot at me, i'm useless, but necessary
end

vgui.Register("DPointShopColorChooser", COLOR, THEME.Component.Page)