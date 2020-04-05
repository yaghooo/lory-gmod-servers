function REWARDS:OpenPage()
    local page = vgui.Create(THEME.Component.Page)
    page:SetSize(math.min(968, ScrW()), math.min(518, ScrH()))

    local i = 1
    for k, v in pairs(REWARDS.Prizes) do
        local item = vgui.Create("RewardsItem", page)
        item:SetPos(page.ContainerPadding, page.ContainerPadding * 1.5 + item:GetTall() * (i - 1) + page.ContainerPadding * i)
        item:SetItem(v)
        i = i + 1
    end

    return page
end

REWARD_ITEM = {}

function REWARD_ITEM:Init()
    local parent = self:GetParent()
    self:SetSize(parent:GetWide() - parent.ContainerPadding * 2, 73)
end

function REWARD_ITEM:Paint(w, h)
    surface.SetDrawColor(THEME.Color.LightSecondary)
    surface.DrawRect(0, 0, w, h)
end

function REWARD_ITEM:SetItem(item)
    local image = vgui.Create("DImage", self)
    image:SetPos(15, 10)
    local imageSize = self:GetTall() - 10 * 2
    image:SetSize(imageSize, imageSize)
    image:SetMaterial(Material("rewards/" .. item.Image .. ".png"))

    local title = vgui.Create("DLabel", self)
    title:SetFont(THEME.Font.Coolvetica20)
    title:SetPos(imageSize + 20 + 10, 10)
    title:SetText(item.Title)
    title:SetSize(title:GetTextSize(), 30)
    title:SetColor(color_white)

    local description = vgui.Create("DLabel", self)
    description:SetFont(THEME.Font.Coolvetica20)
    description:SetPos(imageSize + 20 + 10, 10 + 30)
    description:SetText(item.Description)
    description:SetSize(description:GetTextSize(), 30)
    description:SetColor(color_white)

    if not item.Id then return end
    local button = vgui.Create(THEME.Component.Button1, self)
    button:SetSize(170, 40)
    button:SetPos(self:GetWide() - button:GetWide() - self:GetParent().ContainerPadding, self:GetTall() / 2 - button:GetTall() / 2)

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

            if REWARDS.Prizes[item.Id].Status == "ELEGIVEL" then
                button:SetBackgroundColor(THEME.Color.Success)
            end
        end
    end
end

vgui.Register("RewardsItem", REWARD_ITEM)