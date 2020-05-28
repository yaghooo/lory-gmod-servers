local PANEL = {}

function PANEL:Init()
    self:SetSize(400, 200)
    self:MakePopup()
    self:SetDrawOnTop(true)
    self:RenderPlayerInput()
    self:RenderPointsInput()
    self:RenderSubmitButton()
end

function PANEL:RenderPlayerInput()
    local playerLabel = vgui.Create("DLabel", self)
    playerLabel:SetText("Jogador:")
    playerLabel:Dock(TOP)
    playerLabel:DockMargin(self.ContainerPadding, self.HeaderSize - 10, self.ContainerPadding, 4)
    playerLabel:SizeToContents()
    self.SelectedUserUniqueId = nil
    local players = vgui.Create("DComboBox", self)
    players:SetValue("Selecionar jogador")
    players:SetTall(24)
    players:DockMargin(self.ContainerPadding, 0, self.ContainerPadding, 4)
    players:Dock(TOP)

    players.OnSelect = function(s, i, val, data)
        if data then
            self.SelectedUserUniqueId = data
        end

        self:Update()
    end

    for _, ply in pairs(player.GetAll()) do
        if ply ~= LocalPlayer() then
            players:AddChoice(ply:Nick(), ply:SteamID64())
        end
    end
end

function PANEL:RenderPointsInput()
    local pointsLabel = vgui.Create("DLabel", self)
    pointsLabel:SetText(PS.Config.PointsName .. ":")
    pointsLabel:Dock(TOP)
    pointsLabel:DockMargin(self.ContainerPadding, 10, self.ContainerPadding, 4)
    pointsLabel:SizeToContents()
    self.PointsInput = vgui.Create("DNumberWang", self)
    self.PointsInput:SetTextColor(color_black)
    self.PointsInput:SetTall(24)
    self.PointsInput:DockMargin(self.ContainerPadding, 0, self.ContainerPadding, 4)
    self.PointsInput:Dock(TOP)
    self.PointsInput:SetKeyboardInputEnabled(true)

    self.PointsInput.OnValueChanged = function(s, value)
        self.SelectedValue = tonumber(value)
        self:Update()
    end
end

function PANEL:RenderSubmitButton()
    local submitContainer = vgui.Create("DPanel", self)
    submitContainer:SetPaintBackground(false)
    submitContainer:DockMargin(0, 0, self.ContainerPadding, self.ContainerPadding)
    submitContainer:Dock(BOTTOM)
    self.SubmitButton = vgui.Create("DButton", submitContainer)
    self.SubmitButton:SetText("")
    self.SubmitButton:SetDisabled(true)
    self.SubmitButton:Dock(RIGHT)
    self.SubmitButton:SetSize(100, self.SubmitButton:GetTall())

    self.SubmitButton.DoClick = function()
        local other = player.GetBySteamID64(self.SelectedUserUniqueId)
        if not IsValid(other) then return end -- player could have left
        net.Start("PS_SendPoints")
        net.WriteEntity(other)
        net.WriteInt(self.SelectedValue, 32)
        net.SendToServer()
        self:Close()
    end

    function self.SubmitButton:Paint(w, h)
        local opc = self:GetDisabled() and 50 or 150
        draw.RoundedBox(0, 0, 0, w, h, ColorAlpha(THEME.Color.Success, opc))
        draw.RoundedBox(0, 1, 1, w - 2, h - 2, ColorAlpha(color_white, 10))
        draw.RoundedBox(0, 2, 2, w - 4, h - 4, ColorAlpha(THEME.Color.Success, opc))
        draw.SimpleText("Enviar", THEME.Font.Coolvetica20, w / 2, h / 2, ColorAlpha(color_white, opc), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

function PANEL:Update()
    if not self.SelectedUserUniqueId then
        self.SubmitButton:SetDisabled(true)
    elseif not self.SelectedValue or self.SelectedValue < 1 or self.SelectedValue > LocalPlayer():PS_GetPoints() then
        self.PointsInput:SetTextColor(Color(180, 0, 0, 255))
        self.SubmitButton:SetDisabled(true)
    else
        self.PointsInput:SetTextColor(color_black)
        self.SubmitButton:SetDisabled(false)
    end
end

vgui.Register("DPointShopGivePoints", PANEL, THEME.Component.Page)