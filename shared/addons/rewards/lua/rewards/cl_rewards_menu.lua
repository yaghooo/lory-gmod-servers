THEME = THEME or {}
THEME.PrimaryColor = THEME.PrimaryColor or Color(255, 68, 80)
THEME.SecondaryColor = THEME.SecondaryColor or Color(35, 35, 35)
THEME.LightSecondaryColor = THEME.LightSecondaryColor or Color(46, 46, 46)

PANEL = {}

PANEL.Width = 968
PANEL.Heigth = 518
PANEL.OutLineSize = 3
PANEL.ElementPadding = 20

surface.CreateFont("Coolvetica-14", {
    font = "coolvetica",
    size = 14
})

surface.CreateFont("Coolvetica-20", {
    font = "coolvetica",
    size = 20
})

surface.CreateFont("Coolvetica-30", {
    font = "coolvetica",
    size = 30
})

function PANEL:Init()
    local w, h = ScrW(), ScrH()
    self:SetSize(math.min(self.Width, w), math.min(self.Heigth, h))
    self:SetPos((w / 2) - (self:GetWide() / 2), (h / 2) - (self:GetTall() / 2))

    local close = vgui.Create("RewardsClose", self)
    function close:DoClick()
        REWARDS:ToggleRewardsMenu()
    end

    local i = 1
    for k, v in pairs(REWARDS.Prizes) do
        local item = vgui.Create("RewardsItem", self)
        item:SetItem(i, v)
        i = i + 1
    end
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(THEME.PrimaryColor)
    surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(THEME.SecondaryColor)
    surface.DrawRect(self.OutLineSize, self.OutLineSize, w - self.OutLineSize * 2, h - self.OutLineSize * 2)
end

vgui.Register("RewardsMenu", PANEL)

CLOSE = {}

CLOSE.Width = 100
CLOSE.Heigth = 34
CLOSE.OutLineSize = 1

function CLOSE:Init()
    local parent = self:GetParent()
    self:SetSize(self.Width, self.Heigth)
    self:SetPos(parent:GetWide() - 20 - self:GetWide(), parent.OutLineSize or 0)
    self:SetText("FECHAR")
    self:SetTextColor(color_white)
    self:SetFont("Coolvetica-18")
end

function CLOSE:Paint(w, h)
    surface.SetDrawColor(ColorAlpha(color_white, 12))
    surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(THEME.LightSecondaryColor)
    surface.DrawRect(self.OutLineSize, self.OutLineSize, w - self.OutLineSize * 2, h - self.OutLineSize * 2)
end

vgui.Register("RewardsClose", CLOSE, "DButton")

REWARD_ITEM = {}

function REWARD_ITEM:Init()
    local parent = self:GetParent()
    self:SetSize(parent:GetWide() - parent.ElementPadding * 2, 73)
end

function REWARD_ITEM:Paint(w, h)
    surface.SetDrawColor(THEME.LightSecondaryColor)
    surface.DrawRect(0, 0, w, h)
end

function REWARD_ITEM:SetItem(index, item)
    local parent = self:GetParent()
    self:SetPos(parent.ElementPadding, CLOSE.Heigth + self:GetTall() * (index - 1) + parent.ElementPadding * index)

    local image = vgui.Create("DImage", self)
    image:SetPos(15, 10)
    local imageSize = self:GetTall() - 10 * 2
    image:SetSize(imageSize, imageSize)
    image:SetMaterial(Material("rewards/" .. item.Image .. ".png"))

    local title = vgui.Create("DLabel", self)
    title:SetFont("Coolvetica-30")
    title:SetPos(imageSize + 20 + 10, 10)
    title:SetText(item.Title)
    title:SetSize(title:GetTextSize(), 30)
    title:SetColor(color_white)

    local description = vgui.Create("DLabel", self)
    description:SetFont("Coolvetica-20")
    description:SetPos(imageSize + 20 + 10, 10 + 30)
    description:SetText(item.Description)
    description:SetSize(description:GetTextSize(), 30)
    description:SetColor(color_white)

    if not item.Id then return end
    local button = vgui.Create("RewardsButton", self)
    button:SetSize(170, 40)
    button:SetPos(self:GetWide() - button:GetWide() - parent.ElementPadding, self:GetTall() / 2 - button:GetTall() / 2)

    function button:DoClick()
        if item.Passive then return end

        REWARDS.Prizes[item.Id].Waiting = true
        net.Start("rewards_redeem")
            net.WriteString(item.Id)
        net.SendToServer()
    end

    function button:Think()
        if REWARDS.Prizes[item.Id].Status == "RESGATAR" and REWARDS.Prizes[item.Id].Waiting then
            button:SetEnabled(false)
        else
            button:SetText(REWARDS.Prizes[item.Id].Status)
            button:SetEnabled(REWARDS.Prizes[item.Id].Status == "RESGATAR" or REWARDS.Prizes[item.Id].Status == "ELEGIVEL")
        end
    end
end

vgui.Register("RewardsItem", REWARD_ITEM)

REWARD_BUTTON = {}

function REWARD_BUTTON:Init()
    self:SetTextColor(color_white)
    self:SetFont("Coolvetica-20")
end

function REWARD_BUTTON:Paint(w, h)
    local color = self:IsEnabled() and THEME.PrimaryColor or ColorAlpha(THEME.PrimaryColor, 25)
    surface.SetDrawColor(color)
    surface.DrawRect(0, 0, w, h)
end

vgui.Register("RewardsButton", REWARD_BUTTON, "DButton")